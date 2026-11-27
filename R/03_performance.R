# =============================================================================
# 03_performance.R  -  performance analysis (annual output, sources, authors,
#                      countries, most cited documents)
# Output: Figure1_AnnualProduction.csv, Table3_MostCited.csv,
#         Table6_Journals.csv, Table7_Authors.csv, CountryData.csv
# =============================================================================
source(file.path("R", "00_setup.R"))
M <- readRDS(file.path(PRIV, "M.rds"))

res <- biblioAnalysis(M, sep = ";")
saveRDS(res, file.path(PRIV, "biblioAnalysis.rds"))
print(summary(res, k = 10, pause = FALSE, verbose = FALSE)$MainInformation)

# Annual scientific production (Figure 1)
annual <- as.data.frame(table(Year = M$PY), responseName = "Papers")
write.csv(annual, file.path(TABLES, "Figure1_AnnualProduction.csv"), row.names = FALSE)

# Most productive sources (Table 6, journals). Two records have no source title.
so <- gsub("\\\\&", "&", M$SO)
journals <- as.data.frame(sort(table(so[so != ""]), decreasing = TRUE), stringsAsFactors = FALSE)
names(journals) <- c("Journal", "Papers")
journals$Pct <- round(100 * journals$Papers / nrow(M), 1)
write.csv(head(journals, 15), file.path(TABLES, "Table6_Journals.csv"), row.names = FALSE)

# Most productive authors (Table 7, authors)
# Published version: names counted as written, so a Scopus "Alam M" and a WoS
# "ALAM M" counted as two people. Corrected version: case-insensitive, each
# name counted once per paper.
au_list <- lapply(strsplit(M$AU, ";"), trimws)
au <- if (REPLICATE_PUBLISHED) unlist(au_list) else unlist(lapply(au_list, function(z) unique(toupper(z))))
au <- au[!is.na(au) & au != ""]
authors <- as.data.frame(sort(table(au), decreasing = TRUE), stringsAsFactors = FALSE)
names(authors) <- c("Author", "Papers")
write.csv(subset(authors, Papers >= 2), file.path(TABLES, "Table7_Authors.csv"), row.names = FALSE)

# Countries: first author's country
M <- metaTagExtraction(M, Field = "AU1_CO", sep = ";")
countries <- as.data.frame(sort(table(M$AU1_CO), decreasing = TRUE), stringsAsFactors = FALSE)
names(countries) <- c("Country", "Papers")
write.csv(countries, file.path(TABLES, "CountryData.csv"), row.names = FALSE)

# Most cited documents (Table 3)
top <- M[order(-M$TC), c("Cluster_Label", "AU", "TI", "SO", "PY", "TC", "DI")][1:20, ]
write.csv(top, file.path(TABLES, "Table3_MostCited.csv"), row.names = FALSE)

cat("\nChecks against the paper\n")
check("Papers per year 2014-2025",
      as.integer(annual$Papers), c(1, 1, 1, 1, 2, 2, 4, 12, 12, 29, 70))
check("Top journal (AI & Society) papers", journals$Papers[1], 4)
check("Authors with 2 papers", sum(authors$Papers == 2), 9)
check("Top 5 countries (first author)", countries$Papers[1:5], c(13, 9, 6, 6, 6))
check("Top 3 citation counts", top$TC[1:3], c(201, 60, 54))
