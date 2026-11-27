# =============================================================================
# 08_record_ids.R  -  shareable list of the 135 records
# Database exports cannot be redistributed under the Scopus and Web of Science
# licences. This file lists the record identifiers so anyone with access can
# download the same records (see data/README.md).
# Output: data/record_ids.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

ids <- data.frame(
  source      = ifelse(M$DB_Original == "SCOPUS", "Scopus", "Web of Science"),
  id          = M$UT,                     # Scopus EID or WoS accession number
  doi         = ifelse(is.na(M$DI), "", M$DI),
  year        = M$PY,
  first_author = sub(";.*$", "", M$AU),
  title       = M$TI,
  document_type = M$DT,
  thematic_cluster = M$Cluster,
  coupling_cluster = M$BC_Cluster)
ids <- ids[order(ids$source, ids$id), ]
write.csv(ids, file.path(DATA, "record_ids.csv"), row.names = FALSE)
cat("Wrote", nrow(ids), "records:", paste(names(table(ids$source)), table(ids$source), collapse = "; "), "\n")
