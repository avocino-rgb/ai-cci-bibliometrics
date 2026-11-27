# =============================================================================
# 04_bibliographic_coupling.R  -  document coupling network and walktrap
#                                 communities (Section 3.4, Table 7 BC)
# Output: data/coupling_clusters.csv, output/tables/Table7_BC_Clusters.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

NetMatrix <- biblioNetwork(M, analysis = "coupling", network = "references", sep = ";")
g <- graph_from_adjacency_matrix(NetMatrix, mode = "undirected", weighted = TRUE, diag = FALSE)

# Drop papers that share no reference with any other paper
deg <- degree(g)
g_conn <- delete_vertices(g, which(deg == 0))
wt <- cluster_walktrap(g_conn)              # weighted, default steps = 4
mem <- membership(wt)

# Rows of NetMatrix follow the rows of M, so attach results by position
M$BC_Degree  <- ifelse(deg > 0, deg, NA)
M$BC_Cluster <- NA_integer_
M$BC_Cluster[deg > 0] <- as.integer(mem)

if (REPLICATE_PUBLISHED) {
  # The original analysis attached results by matching network labels such as
  # "CUNNINGHAM J, 2025-1" to "AUTHOR, YEAR" keys. Eleven labels (suffixed
  # duplicates, and authors with a middle initial) did not match, so those
  # papers were dropped. This reproduces that step.
  key <- paste0(sub(",.*$", "", sub(";.*$", "", M$SR_FULL)), ", ", M$PY)
  lost <- !(rownames(NetMatrix) %in% key) & deg > 0
  M$BC_Cluster[lost] <- NA; M$BC_Degree[lost] <- NA
  cat("Replicating published join:", sum(lost), "connected papers dropped\n")
}

saveRDS(M, file.path(PRIV, "M.rds"))
write.csv(data.frame(UT = M$UT, DI = M$DI, bc_cluster = M$BC_Cluster, bc_degree = M$BC_Degree),
          file.path(DATA, "coupling_clusters.csv"), row.names = FALSE)

n_net <- sum(!is.na(M$BC_Cluster))
t7 <- cluster_summary(M, M$BC_Cluster, n_total = n_net)
write.csv(t7, file.path(TABLES, "Table7_BC_Clusters.csv"), row.names = FALSE)
print(head(t7, 13))

cat("\nChecks against the paper (Section 3.4)\n")
check("Connected papers in coupling network", n_net, 75)
check("Walktrap clusters", length(unique(na.omit(M$BC_Cluster))), 24)
check("Largest clusters (papers)", head(t7$papers, 3), c(12, 10, 9))
cat("  Corrected network (all connected papers):", vcount(g_conn), "papers,",
    length(sizes(wt)), "clusters\n")
