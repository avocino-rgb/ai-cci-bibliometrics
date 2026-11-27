# =============================================================================
# 01_import_merge.R  -  import Scopus + WoS, remove duplicates, repair fields
# Input : data-raw/Scopus.csv, data-raw/WoS.bib   (see data/README.md)
# Output: data-private/M.rds  (135 records), output/tables/Table1_PRISMA.csv
# =============================================================================
source(file.path("R", "00_setup.R"))

# 1. Import --------------------------------------------------------------------
S <- convert2df(file.path(RAW, "Scopus.csv"), dbsource = "scopus", format = "csv")
W <- convert2df(file.path(RAW, "WoS.bib"),    dbsource = "wos",    format = "bibtex")

# 2. Merge and remove duplicates ------------------------------------------------
M <- mergeDbSources(S, W, remove.duplicated = TRUE)

# 3. Restore cited references ---------------------------------------------------
# Take CR straight from each source export, so co-citation and coupling use the
# references exactly as exported (matched on title + source database).
src <- rbind(data.frame(key = paste(S$TI, "SCOPUS"), CR = S$CR),
             data.frame(key = paste(W$TI, "ISI"),    CR = W$CR))
M$CR <- src$CR[match(paste(M$TI, M$DB_Original), src$key)]

# 4. Repair Scopus author names (see functions.R) and rebuild labels -----------
is_scopus <- M$DB_Original == "SCOPUS"
M$AU[is_scopus] <- fix_scopus_au(M$AU[is_scopus])
M$SR_FULL <- make_sr(M)
M$SR      <- make.unique(M$SR_FULL, sep = "-")

# Keep the merge order: later network results (walktrap) follow this order
saveRDS(M, file.path(PRIV, "M.rds"))

# 5. PRISMA counts ---------------------------------------------------------------
prisma <- data.frame(
  stage = c("Identified - Scopus", "Identified - Web of Science", "Identified - total",
            "Duplicates removed", "Included"),
  n = c(nrow(S), nrow(W), nrow(S) + nrow(W), nrow(S) + nrow(W) - nrow(M), nrow(M)))
write.csv(prisma, file.path(TABLES, "Table1_PRISMA.csv"), row.names = FALSE)
print(prisma)

cat("\nChecks against the paper (Section 3.3)\n")
check("Scopus records", nrow(S), 115)
check("WoS records", nrow(W), 87)
check("Duplicates removed", nrow(S) + nrow(W) - nrow(M), 67)
check("Final sample", nrow(M), 135)
cat("  Records with empty cited references:", sum(is.na(M$CR) | M$CR == ""), "\n")
