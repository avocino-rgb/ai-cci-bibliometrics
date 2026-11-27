# =============================================================================
# 00_setup.R  -  packages, paths, options shared by all scripts
# Project: Mapping AI Research in the Cultural and Creative Industries
#          (Vocino et al., Technovation)
# =============================================================================

# --- Locale ------------------------------------------------------------------
# IMPORTANT: run in a UTF-8 locale. In a non-UTF-8 locale bibliometrix 5.1.1
# handles accented and non-Latin titles differently, mergeDbSources() then
# finds 68 duplicates instead of 67 and the sample has 134 records, not 135.
if (!grepl("UTF-8|utf8", Sys.getlocale("LC_CTYPE"), ignore.case = TRUE)) {
  ok <- suppressWarnings(Sys.setlocale("LC_ALL", "C.UTF-8"))
  if (ok == "") ok <- suppressWarnings(Sys.setlocale("LC_ALL", "en_US.UTF-8"))
  if (ok == "") stop("Please run R in a UTF-8 locale (see README).")
}

# --- Packages ----------------------------------------------------------------
pkgs <- c("bibliometrix", "igraph", "Matrix", "dplyr", "stringr", "tm", "readr")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install missing packages first: ", paste(missing, collapse = ", "),
                          "  (see install.R)")
suppressPackageStartupMessages({
  library(bibliometrix); library(igraph); library(Matrix)
  library(dplyr); library(stringr); library(tm)
})
if (packageVersion("bibliometrix") != "5.1.1")
  warning("The paper used bibliometrix 5.1.1; you have ", packageVersion("bibliometrix"),
          ". Results may differ slightly.")

# --- Paths -------------------------------------------------------------------
RAW     <- "data-raw"        # licensed exports (not in the repo, see data/README.md)
PRIV    <- "data-private"    # intermediate files with full records (not in the repo)
DATA    <- "data"            # shareable derived data
VOS     <- "vosviewer"       # VOSviewer map files used for the figures
TABLES  <- file.path("output", "tables")
for (d in c(PRIV, TABLES)) dir.create(d, showWarnings = FALSE, recursive = TRUE)

# --- Options -----------------------------------------------------------------
# The published coupling statistics (75 papers) came from a join that silently
# dropped 11 connected papers (see README, "Known issues"). TRUE reproduces the
# published numbers; FALSE gives the corrected 86-paper network.
REPLICATE_PUBLISHED <- TRUE

set.seed(20251006)   # data extraction date; walktrap itself is deterministic

source(file.path("R", "functions.R"))
