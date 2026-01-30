# Internal GSEA execution functions

#' Run GSEA with standard organism database
#' @noRd
run_gsea_standard <- function(res_df, organism, ranking, padj_cutoff, ...) {

  # Determine ranking column
  ranking_col <- ifelse(ranking == "log2fc", "log2FoldChange", "stat")

  # Auto-detect organism if needed
  if (organism == "auto") {
    organism <- detect_organism(res_df$gene_id)
    message("Auto-detected organism: ", organism)
  }

  # Get organism database
  orgdb_name <- get_orgdb(organism)
  orgdb <- get(orgdb_name, envir = loadNamespace(orgdb_name))

  # Rank genes
  res_clean <- rank_genes(res_df, ranking_col)

  # Convert gene IDs (ENSEMBL to ENTREZ)
  message("Converting gene IDs...")
  res_ids <- clusterProfiler::bitr(
    res_clean$gene_id_clean,
    fromType = "ENSEMBL",
    toType = "ENTREZID",
    OrgDb = orgdb
  )

  # Merge
  res_merged <- res_clean %>%
    dplyr::left_join(res_ids, by = c("gene_id_clean" = "ENSEMBL")) %>%
    dplyr::filter(!is.na(ENTREZID))

  # Handle duplicates - keep highest absolute value
  res_merged <- res_merged %>%
    dplyr::group_by(ENTREZID) %>%
    dplyr::arrange(dplyr::desc(abs(!!rlang::sym(ranking_col)))) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()

  # Create ranked gene list
  gene_list <- res_merged[[ranking_col]]
  names(gene_list) <- res_merged$ENTREZID
  gene_list <- sort(gene_list, decreasing = TRUE)

  message("Running GSEA on ", length(gene_list), " genes...")
  message("Range: ", round(min(gene_list), 2), " to ", round(max(gene_list), 2))

  # Run GSEA with proper filtering
  gsea_all <- clusterProfiler::gseGO(
    geneList = gene_list,
    OrgDb = orgdb,
    ont = "BP",
    pvalueCutoff = 1.0,  # Get all results
    pAdjustMethod = "BH",
    ...
  )

  # Filter to significant (adjusted p-value)
  if (nrow(gsea_all) > 0) {
    gsea_result <- gsea_all
    gsea_result@result <- gsea_all@result %>%
      dplyr::filter(p.adjust < padj_cutoff)
  } else {
    gsea_result <- gsea_all
  }

  message("Found ", nrow(gsea_result), " significant pathways (padj < ", padj_cutoff, ")")

  if (nrow(gsea_result) == 0) {
    warning("No significant pathways found. Try relaxing padj_cutoff or check your data.")
  }

  return(gsea_result)
}

#' Run GSEA with custom pathways
#' @noRd
run_gsea_custom <- function(res_df, ranking, custom_pathways, padj_cutoff, ...) {

  # Determine ranking column
  ranking_col <- ifelse(ranking == "log2fc", "log2FoldChange", "stat")

  # Rank genes
  res_clean <- rank_genes(res_df, ranking_col)

  # Read custom pathways
  message("Reading custom pathway file...")
  pathways <- read_custom_pathways(custom_pathways)

  # Create ranked gene list (using gene IDs as-is)
  gene_list <- res_clean[[ranking_col]]
  names(gene_list) <- res_clean$gene_id
  gene_list <- sort(gene_list, decreasing = TRUE)

  message("Running GSEA on ", length(gene_list), " genes with custom pathways...")

  # Run GSEA
  gsea_all <- clusterProfiler::GSEA(
    geneList = gene_list,
    TERM2GENE = pathways,
    pvalueCutoff = 1.0,
    pAdjustMethod = "BH",
    ...
  )

  # Filter to significant
  if (nrow(gsea_all) > 0) {
    gsea_result <- gsea_all
    gsea_result@result <- gsea_all@result %>%
      dplyr::filter(p.adjust < padj_cutoff)
  } else {
    gsea_result <- gsea_all
  }

  message("Found ", nrow(gsea_result), " significant pathways (padj < ", padj_cutoff, ")")

  return(gsea_result)
}

#' Read custom pathway file
#' @noRd
read_custom_pathways <- function(filepath) {

  if (!file.exists(filepath)) {
    stop("Custom pathway file not found: ", filepath)
  }

  # Try to read as CSV
  if (grepl("\\.csv$", filepath, ignore.case = TRUE)) {
    pathways <- utils::read.csv(filepath, stringsAsFactors = FALSE)

    # Expected format: pathway, gene_id
    if (!all(c("pathway", "gene_id") %in% colnames(pathways))) {
      stop("CSV file must have columns: 'pathway' and 'gene_id'")
    }

    # Convert to TERM2GENE format
    term2gene <- pathways[, c("pathway", "gene_id")]

  } else if (grepl("\\.gmt$", filepath, ignore.case = TRUE)) {
    # GMT format
    term2gene <- clusterProfiler::read.gmt(filepath)

  } else {
    stop("Custom pathway file must be .csv or .gmt format")
  }

  message("Loaded ", length(unique(term2gene[,1])), " pathways")

  return(term2gene)
}
