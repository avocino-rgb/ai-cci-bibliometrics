# =============================================================================
# 05_cocitation_centrality.R  -  reference co-citation network and centrality
#                                (Table 6, co-citation centrality)
# Network: references cited by at least 2 papers in the sample, isolates
# removed (218 references). Measures are weighted (igraph defaults).
# Composite = mean of degree, betweenness, eigenvector and PageRank, each
# min-max scaled to 0-1.
# Output: output/tables/Table6_CoCitation_Centrality.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

N <- biblioNetwork(M, analysis = "co-citation", network = "references", sep = ";")
freq <- Matrix::diag(N); names(freq) <- rownames(N)   # times each reference is cited
sel <- names(freq)[freq >= 2]
g <- graph_from_adjacency_matrix(N[sel, sel], mode = "undirected", weighted = TRUE, diag = FALSE)
g <- delete_vertices(g, which(degree(g) == 0))

cen <- data.frame(
  Reference   = V(g)$name,
  Citations   = as.numeric(freq[V(g)$name]),
  Degree      = degree(g),
  Betweenness = betweenness(g, normalized = TRUE),
  Eigenvector = eigen_centrality(g)$vector,
  PageRank    = page_rank(g)$vector)
sc <- function(x) (x - min(x)) / (max(x) - min(x))   # min-max scaling
cen$Composite <- rowMeans(cbind(sc(cen$Degree), sc(cen$Betweenness),
                                sc(cen$Eigenvector), sc(cen$PageRank)))
cen <- cen[order(-cen$Composite), ]
cen$Rank <- seq_len(nrow(cen))
write.csv(cen, file.path(TABLES, "Table6_CoCitation_Centrality.csv"), row.names = FALSE)
print(head(cen, 10), row.names = FALSE)

cat("\nChecks against the paper (Table 6)\n")
check("References in network", vcount(g), 218)
check("Top reference", cen$Reference[1], "ANANTRASIRICHAI N 2022")
check("Top degree", cen$Degree[1], 83)
check("Top composite score", round(cen$Composite[1], 4), 0.7873)
check("Composite, ranks 2-4", round(cen$Composite[2:4], 4), c(0.4608, 0.4460, 0.4391))
