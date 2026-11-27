# Data

## Shareable files (in this folder)

| File | Content |
|---|---|
| `record_ids.csv` | The 135 records in the final sample: source database, record ID (Scopus EID or WoS accession number), DOI, year, first author, title, document type, thematic cluster, coupling cluster |
| `thematic_clusters.csv` | Thematic cluster of every paper and whether it came from the keyword rule or was assigned by hand |
| `thematic_clusters_manual.csv` | The 29 papers assigned by hand, with reasons |
| `coupling_clusters.csv` | Walktrap coupling cluster and degree of every paper |

After removing duplicates, 86 records come from Web of Science and 49 from Scopus.

## Raw data (not shared)

The full records with abstracts and cited references come from Scopus and Web of Science Core Collection. Their licences do not allow redistribution. To rebuild them you need institutional access to both databases.

- **Search strings:** see the paper's Supplementary Appendix A. The same strings are in `search_strings.txt`.
- **Search date:** 6 October 2025.
- **Filters:** 2014 to 2025, journal articles and reviews.

Because database contents change, running the searches today will give a slightly different set. To get exactly the published sample:

1. **Scopus.** Use Advanced search with `EID(<id1>) OR EID(<id2>) ...`, taking the IDs that start with `2-S2.0-` in `record_ids.csv`, and fetching in batches of about 50. Export as CSV with all fields, including references. Save as `data-raw/Scopus.csv`.
2. **Web of Science.** Use Advanced search with `UT=(<id1> OR <id2> ...)`, taking the IDs that start with `WOS` with that prefix removed. Export as BibTeX with "Full record and cited references". Save as `data-raw/WoS.bib`.

Note that re-downloading only the 135 final records skips the duplicate removal step. To rerun step 01 exactly, export the full original result sets, 115 Scopus and 87 WoS records, using the search strings above.
