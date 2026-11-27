# Install the packages used by the pipeline.
# The published analysis used R 4.3.2 and bibliometrix 5.1.1.
# The rebuild was tested with R 4.4 and bibliometrix 5.1.1 (see output/sessionInfo.txt).
pkgs <- c("bibliometrix", "igraph", "Matrix", "dplyr", "stringr", "tm", "SnowballC", "readr")
install.packages(setdiff(pkgs, rownames(installed.packages())))

# To pin bibliometrix to the version used in the paper:
# install.packages("remotes")
# remotes::install_version("bibliometrix", version = "5.1.1")
