# =============================================================================
# 02_thematic_clusters.R  -  assign papers to the five thematic clusters
#
# The five clusters are the VOSviewer keyword co-occurrence clusters
# (30 author keywords, min. 3 occurrences, association strength; see
# vosviewer/keyword_cooccurrence_map.txt). Each paper is assigned to the
# cluster that holds most of its author keywords (ties: lowest cluster number).
# Papers with none of the 30 mapped keywords (29 of 135) were assigned by the
# authors after reading title and abstract; those decisions are recorded in
# data/thematic_clusters_manual.csv.
#
# Output: data-private/M.rds (adds Cluster, Cluster_Label),
#         data/thematic_clusters.csv, output/tables/Table2_Clusters.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

labels <- c("1" = "Technology & Innovation", "2" = "Art & Digital Creativity",
            "3" = "Creative Industries Practice", "4" = "Legal & IP",
            "5" = "Cultural Heritage")

kw <- read.delim(file.path(VOS, "keyword_cooccurrence_map.txt"), fileEncoding = "UTF-8-BOM")
kw$label <- tolower(trimws(kw$label))

rule <- vapply(M$DE, function(x) {
  k  <- tolower(trimws(strsplit(ifelse(is.na(x), "", x), ";")[[1]]))
  cl <- kw$cluster[match(k, kw$label)]
  cl <- cl[!is.na(cl)]
  if (!length(cl)) return(NA_integer_)
  tb <- table(cl)
  as.integer(names(tb)[which.max(tb)])
}, integer(1), USE.NAMES = FALSE)

manual <- read.csv(file.path(DATA, "thematic_clusters_manual.csv"))
M$Cluster <- rule
M$Cluster_method <- ifelse(is.na(rule), "manual", "keyword rule")
i <- match(M$UT, manual$UT)
M$Cluster[is.na(rule)] <- manual$cluster[i[is.na(rule)]]
stopifnot(!anyNA(M$Cluster))
M$Cluster_Label <- unname(labels[as.character(M$Cluster)])
saveRDS(M, file.path(PRIV, "M.rds"))

write.csv(data.frame(UT = M$UT, DI = M$DI, cluster = M$Cluster,
                     cluster_label = M$Cluster_Label, method = M$Cluster_method),
          file.path(DATA, "thematic_clusters.csv"), row.names = FALSE)

t2 <- cluster_summary(M, M$Cluster) |> arrange(cl) |>
  mutate(name = labels[as.character(cl)], .after = cl)
write.csv(t2, file.path(TABLES, "Table2_Clusters.csv"), row.names = FALSE)
print(t2)

cat("\nChecks against the paper (Table 2)\n")
check("Keywords in VOSviewer map", nrow(kw), 30)
check("Keyword clusters", length(unique(kw$cluster)), 5)
check("Papers per cluster (1-5)", as.integer(table(M$Cluster)), c(33, 71, 22, 8, 1))
check("Total citations per cluster", t2$total_citations, c(88, 554, 128, 70, 1))
cat("  Assigned by keyword rule:", sum(!is.na(rule)), " manual:", sum(is.na(rule)), "\n")
