# Run the full pipeline from the project root:  Rscript run_all.R
scripts <- c("01_import_merge.R", "02_thematic_clusters.R", "03_performance.R",
             "04_bibliographic_coupling.R", "05_cocitation_centrality.R",
             "06_text_analysis.R", "07_vosviewer.R", "08_record_ids.R")
for (s in scripts) {
  cat("\n=====================", s, "=====================\n")
  source(file.path("R", s), echo = FALSE, local = new.env())
}
writeLines(capture.output(sessionInfo()), file.path("output", "sessionInfo.txt"))
