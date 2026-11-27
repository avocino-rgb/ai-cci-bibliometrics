# =============================================================================
# functions.R  -  helpers used across the pipeline
# =============================================================================

# Rebuild Scopus author names.
# In bibliometrix 5.1.1, Scopus AU comes through as repeating triplets
# "INITIALS;SURNAME;GIVEN" (e.g. "P;MEHTA;PRASHANT;R;C;RESHMA").
# This turns each triplet into "Surname I" (e.g. "Mehta P;C R").
fix_scopus_au <- function(au) {
  vapply(au, function(x) {
    if (is.na(x) || x == "") return(NA_character_)
    t <- trimws(strsplit(x, ";")[[1]])
    n <- length(t) %/% 3
    out <- vapply(seq_len(n), function(k) {
      sur <- str_to_title(tolower(t[3 * k - 1]))
      sur <- sub("^Van ", "van ", sur)
      trimws(paste(sur, substr(t[3 * k], 1, 1)))
    }, character(1))
    # a trailing single token (author with one name only)
    if (length(t) %% 3 == 1) out <- c(out, str_to_title(tolower(t[length(t)])))
    paste(out, collapse = ";")
  }, character(1), USE.NAMES = FALSE)
}

# Short document label "FIRSTAUTHOR, YEAR, JOURNAL" as bibliometrix builds it
make_sr <- function(M) {
  au1 <- vapply(strsplit(M$AU, ";"), function(z) trimws(z[1]), character(1))
  paste(au1, M$PY, M$JI, sep = ", ")
}

# Summarise a set of papers grouped by a cluster variable
cluster_summary <- function(M, cl, n_total = nrow(M)) {
  data.frame(cl = cl, PY = M$PY, TC = M$TC) |>
    filter(!is.na(cl)) |>
    group_by(cl) |>
    summarise(papers = n(),
              pct = round(100 * n() / n_total, 1),
              year_start = min(PY), year_end = max(PY),
              total_citations = sum(TC, na.rm = TRUE),
              mean_citations = round(mean(TC, na.rm = TRUE), 1),
              .groups = "drop") |>
    arrange(desc(papers))
}

# Simple check that prints PASS/FAIL against the published value
check <- function(label, got, expected) {
  ok <- isTRUE(all.equal(got, expected, check.attributes = FALSE))
  cat(sprintf("  [%s] %-55s got %s | published %s\n", if (ok) "PASS" else "DIFF",
              label, paste(format(got), collapse = ","), paste(format(expected), collapse = ",")))
  invisible(ok)
}
