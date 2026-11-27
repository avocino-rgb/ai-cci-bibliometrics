# =============================================================================
# 06_text_analysis.R  -  term frequencies in abstracts by thematic cluster
#                        (Section 3.5)
# Output: output/tables/term_frequencies_by_cluster.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

# Domain-general words removed in addition to tm's English stopwords
extra_stop <- c("research", "study", "artificial", "intelligence", "use",
                "also", "paper", "using", "may", "can")

top_terms <- function(ab, n = 20) {
  ab <- ab[!is.na(ab)]
  co <- VCorpus(VectorSource(ab))
  co <- tm_map(co, content_transformer(tolower))
  co <- tm_map(co, removePunctuation)
  co <- tm_map(co, removeNumbers)
  co <- tm_map(co, removeWords, c(stopwords("english"), extra_stop))
  co <- tm_map(co, stripWhitespace)
  f <- sort(rowSums(as.matrix(TermDocumentMatrix(co))), decreasing = TRUE)
  data.frame(Rank = seq_len(n), Term = names(f)[1:n], Frequency = unname(f[1:n]))
}

tf <- do.call(rbind, lapply(sort(unique(M$Cluster)), function(k)
  cbind(Cluster_ID = k, Cluster_Name = M$Cluster_Label[M$Cluster == k][1],
        top_terms(M$AB[M$Cluster == k]))))
write.csv(tf, file.path(TABLES, "term_frequencies_by_cluster.csv"), row.names = FALSE)

cat("\nTop 5 terms per cluster\n")
for (k in unique(tf$Cluster_ID)) cat(" ", k, ":", paste(head(tf$Term[tf$Cluster_ID == k], 5), collapse = ", "), "\n")

cat("\nChecks against the saved analysis\n")
check("Cluster 1 top term and count", c(tf$Term[1], tf$Frequency[1]), c("creative", "52"))
