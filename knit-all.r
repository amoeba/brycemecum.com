setwd("~/src/amoeba.github.io/")

# Ensure we're in a Jekyll folder
# Do this by ensuring there's a _posts folder
if(!("_posts" %in% list.files(".", "*")))
{
  cat("This script is not being run from a Jekyll blog directory.\n")
  cat("Change directories and re-run.\n")
  quit()
}

# Collect list of .Rmd files in the _rmd directory
rmd_files <- list.files("_rmd", "*.Rmd")

# Check whether --all flag is set
# When not set, Rmd files with a corresponding .md file in the _posts
# folder will not be rebuilt
args <- commandArgs(trailing=TRUE)

if(!("--all" %in% args))
{
  md_files <- list.files("_posts", "*.md")
  md_noext <- gsub("\\.md$", "", md_files)
  rmd_noext <- gsub("\\.Rmd$", "", rmd_files)
  rmd_files <- rmd_files[!(rmd_noext %in% md_noext)]
}

# Exit if there aren't any files
if(length(rmd_files) == 0)
{
  cat("No posts to knit. Quitting.\n")
  quit()
}

# Process files
library(knitr)
opts_knit$set(base.url = "/")

nfiles <- length(rmd_files)

for(i in 1:nfiles)
{
  input_filename <- rmd_files[i]
  output_filename <- sub("\\.Rmd$", "\\.md", input_filename)
  
  cat(paste0("Processing .Rmd file ", i, " of ", nfiles, ":\n"))
  cat(paste0("\tfilename: ", input_filename, "\n"))
  
  fig_path <- paste0("images/", sub(".Rmd$", "", basename(input_filename)), "/")
  opts_chunk$set(fig.path = fig_path)
  
  render_jekyll(highlight="pygments")
  
  knit(
    input=paste0("_rmd/", input_filename), 
    output=paste0("_posts/", output_filename), 
    quiet=TRUE, 
    envir=new.env()
  )
}