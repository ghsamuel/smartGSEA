# Internal helper functions for easyGSEA
# Not exported to users

# Suppress R CMD check notes about dplyr/ggplot2 variables
utils::globalVariables(c("padj", "p.adjust", "ENTREZID"))

#' Detect organism from gene IDs
#' @noRd
detect_organism <- function(gene_ids) {

  # Sample first 100 genes
  sample_genes <- head(gene_ids, 100)

  # Check patterns
  if (any(grepl("^ENSG0", sample_genes))) {
    return("human")
  } else if (any(grepl("^ENSMUSG0", sample_genes))) {
    return("mouse")
  } else if (any(grepl("^ENSRNOG0", sample_genes))) {
    return("rat")
  } else if (any(grepl("^FBgn", sample_genes))) {
    return("fly")
  } else if (any(grepl("^ENSDARG0", sample_genes))) {
    return("zebrafish")
  } else if (any(grepl("^WBGene", sample_genes))) {
    return("worm")
  } else if (any(grepl("^Y[A-Z]", sample_genes))) {
    return("yeast")
  }

  # Cannot detect
  stop("Cannot auto-detect organism from gene IDs. Please specify 'organism' parameter.\n",
       "Example gene IDs found: ", paste(head(sample_genes, 3), collapse = ", "))
}

#' Get organism database package name
#' @noRd
get_orgdb <- function(organism) {

  db_map <- c(
    "human" = "org.Hs.eg.db",
    "mouse" = "org.Mm.eg.db",
    "rat" = "org.Rn.eg.db",
    "fly" = "org.Dm.eg.db",
    "zebrafish" = "org.Dr.eg.db",
    "worm" = "org.Ce.eg.db",
    "yeast" = "org.Sc.sgd.db"
  )

  if (!organism %in% names(db_map)) {
    stop("Organism '", organism, "' not supported.\n",
         "Supported organisms: ", paste(names(db_map), collapse = ", "), "\n",
         "For other organisms, use 'custom_pathways' parameter.")
  }

  pkg_name <- db_map[organism]

  # Check if installed
  if (!requireNamespace(pkg_name, quietly = TRUE)) {
    stop("Package '", pkg_name, "' is required but not installed.\n",
         "Install with: BiocManager::install('", pkg_name, "')")
  }

  return(pkg_name)
}

#' Rank genes by chosen method
#' @noRd
rank_genes <- function(res_df, ranking_column) {

  # Filter valid data
  res_filtered <- res_df %>%
    dplyr::filter(!is.na(!!rlang::sym(ranking_column)) & !is.na(padj))

  # Remove version numbers from ENSEMBL IDs
  res_filtered$gene_id_clean <- sub("\\..*", "", res_filtered$gene_id)

  message("Ranking ", nrow(res_filtered), " genes by ", ranking_column)

  return(res_filtered)
}
