# =============================================================================
# 07_vosviewer.R  -  VOSviewer input file and checks on the published maps
#
# The keyword, co-citation, country and coupling figures were drawn in
# VOSviewer 1.6.19 (association strength normalisation). The saved map files
# are in vosviewer/ and can be opened directly in VOSviewer
# (File > Open > Map file + Network file).
#
# This script (a) writes the sample in Web of Science plain-text format so the
# maps can be rebuilt from scratch in VOSviewer, and (b) checks the saved maps
# against the counts reported in Section 3.4.
# Output: data-private/vosviewer_input.txt (full records, not for sharing)
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

# (a) Web of Science plain-text export -----------------------------------------
tag <- function(t, x, split = TRUE) {
  if (is.na(x) || x == "") return(character(0))
  v <- if (split) trimws(strsplit(x, ";")[[1]]) else x
  v <- v[v != ""]
  c(paste0(t, " ", v[1]), if (length(v) > 1) paste0("   ", v[-1]))
}
rec <- lapply(seq_len(nrow(M)), function(i) with(M[i, ], c(
  "PT J", tag("AU", AU), tag("TI", TI, FALSE), tag("SO", SO, FALSE),
  tag("DE", DE), tag("ID", ID), tag("AB", AB, FALSE), tag("C1", C1), tag("CR", CR),
  paste("TC", TC), paste("PY", PY), tag("DI", DI, FALSE), tag("UT", UT, FALSE), "ER", "")))
writeLines(c("FN Clarivate Analytics Web of Science", "VR 1.0", unlist(rec), "EF"),
           file.path(PRIV, "vosviewer_input.txt"), useBytes = TRUE)

# (b) Checks on the saved VOSviewer maps --------------------------------------------
rd <- function(f) read.delim(file.path(VOS, f), fileEncoding = "UTF-8-BOM", quote = "\"")
maps <- list(
  keywords   = list(rd("keyword_cooccurrence_map.txt"),   30, 5),
  cocitation = list(rd("cocitation_map.txt"),             36, 5),
  countries  = list(rd("country_collaboration_map.txt"),  27, 9),
  coupling   = list(rd("bibliographic_coupling_map.txt"), 25, 7))

cat("\nChecks against the paper (Section 3.4)\n")
for (n in names(maps)) {
  m <- maps[[n]]
  check(paste(n, "- items"), nrow(m[[1]]), m[[2]])
  check(paste(n, "- clusters"), length(unique(m[[1]]$cluster)), m[[3]])
}
