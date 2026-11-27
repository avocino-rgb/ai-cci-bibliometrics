# Mapping AI Research in the Cultural and Creative Industries

Code and shareable data for

> Vocino, A. (2026). Mapping Artificial Intelligence Research in the Cultural and Creative Industries: A Systematic Bibliometric Review. *Technovation*, 103551. https://doi.org/10.1016/j.technovation.2026.103551

The pipeline rebuilds the 135-paper dataset from the Scopus and Web of Science exports. It then reproduces the performance analysis, the five thematic clusters, bibliographic coupling, co-citation centrality and the abstract term analysis reported in the paper. Every script ends by checking its results against the published figures.

## What is in this repository

```
R/
  00_setup.R                   packages, paths, locale, options
  functions.R                  helpers
  01_import_merge.R            import, merge, remove duplicates (PRISMA counts)
  02_thematic_clusters.R       five thematic clusters (Table 2)
  03_performance.R             annual output, journals, authors, countries, most cited
  04_bibliographic_coupling.R  coupling network and walktrap communities
  05_cocitation_centrality.R   co-citation network centrality (Table 6)
  06_text_analysis.R           term frequencies in abstracts by cluster
  07_vosviewer.R               VOSviewer input file and checks on the saved maps
  08_record_ids.R              list of the 135 records
run_all.R                      runs everything in order
data/
  record_ids.csv               the 135 records: database ID, DOI, year, title, clusters
  thematic_clusters.csv        thematic cluster of each paper and how it was assigned
  thematic_clusters_manual.csv the 29 papers assigned by hand
  coupling_clusters.csv        coupling cluster and degree of each paper
  README.md                    how to get the raw data
vosviewer/                     VOSviewer map and network files used for the figures
output/tables/                 tables produced by the scripts
```

The raw database exports are **not** included. Scopus and Web of Science licences do not allow them to be redistributed. `data/README.md` explains how to download the same records yourself.

## How to run

1. Install R (4.3 or later) and the packages in `install.R`. The paper used bibliometrix 5.1.1.
2. Put the two exports in `data-raw/` as `Scopus.csv` and `WoS.bib` (see `data/README.md`).
3. From the project folder run `Rscript run_all.R`.

Run R in a **UTF-8 locale**. `00_setup.R` tries to switch to one automatically. Without it bibliometrix treats some accented and non-Latin titles differently, `mergeDbSources()` removes 68 duplicates instead of 67, and you get 134 records instead of 135.

Each script prints a list of `PASS` / `DIFF` checks against the paper.

## Method notes

- **Import and merge.** `convert2df()` reads both files and `mergeDbSources(remove.duplicated = TRUE)` merges them, giving 115 + 87 records, 67 duplicates removed and 135 kept. Cited references are then taken straight from each source export. Scopus author names, which bibliometrix 5.1.1 reads as `INITIALS;SURNAME;GIVEN` triplets, are rebuilt as `Surname I`.
- **Thematic clusters.** These are the five clusters of the VOSviewer keyword co-occurrence map: 30 author keywords occurring at least 3 times, with association-strength normalisation. Each paper goes to the cluster that holds most of its author keywords. Twenty-nine papers contain none of the 30 mapped keywords. The author assigned those after reading the title and abstract, and the decisions are in `data/thematic_clusters_manual.csv`.
- **Bibliographic coupling.** `biblioNetwork(analysis = "coupling", network = "references")`. Papers with no shared references are dropped, then weighted walktrap community detection is run (igraph defaults).
- **Co-citation centrality.** The network covers references cited by at least two sample papers, minus isolates, which leaves 218 references. Degree, normalised betweenness, eigenvector and PageRank are weighted. The composite score is the mean of the four after min-max scaling.
- **Text analysis.** Abstracts are processed with tm: lower case, punctuation and numbers removed, English stopwords removed, plus a few domain-general words listed in `06_text_analysis.R`.
- **VOSviewer maps.** The keyword, co-citation, country and coupling figures were made in VOSviewer 1.6.19. The saved map files are in `vosviewer/` and open directly in VOSviewer. `07_vosviewer.R` also writes a Web of Science format file for rebuilding them from scratch.

## Known issues

The scripts were rebuilt after publication from the saved data and outputs. With `REPLICATE_PUBLISHED <- TRUE` in `00_setup.R` they reproduce the published numbers exactly. Setting it to `FALSE` corrects two small problems found during the rebuild.

1. **Coupling network size.** The paper reports 75 connected papers in 24 clusters. In fact 86 papers share references with at least one other paper. Eleven were dropped when results were joined back to the data by an `AUTHOR, YEAR` key, which failed for suffixed duplicate labels and for authors with a middle initial. The corrected network still has 24 walktrap clusters, and the clusters of the other 75 papers are unchanged. Some cluster sizes in the coupling table grow.
2. **Most productive authors.** Names were counted as written, so a Scopus `Alam M` and a WoS `ALAM M` counted as two people. Counted case-insensitively and once per paper, 14 authors have two papers each, not 9.

The sample also contains one record that Web of Science marks as a retracted publication. Its document type is listed in `data/record_ids.csv`.

## Licence

Code: MIT (see `LICENSE`). Derived data in `data/`, `vosviewer/` and `output/`: CC BY 4.0.

## Citation

If you use this code or data, please cite the article above.
