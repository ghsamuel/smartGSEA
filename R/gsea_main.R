#' Run GSEA from DESeq2 Results (with automatic reporting)
#'
#' @param output_report Path for HTML report, or NULL to skip. Default: "GSEA_report.html"
#' @param open_report Logical, whether to open report in browser. Default: TRUE
#'
#' @return A list containing:
#'   - gsea_result: The gseaResult object
#'   - metadata: Analysis parameters and QC metrics
#'
#' @export
gsea_from_deseq <- function(dds,
                            contrast,
                            organism = "auto",
                            ranking = "log2fc",
                            custom_pathways = NULL,
                            padj_cutoff = 0.05,
                            output_report = "GSEA_report.html",
                            open_report = TRUE,
                            ...) {

  # [Previous validation code stays the same...]

  # Track metadata for report
  metadata <- list(
    contrast = contrast,
    organism = organism,
    ranking = ranking,
    padj_cutoff = padj_cutoff,
    timestamp = Sys.time()
  )

  # Extract DESeq2 results
  message("Extracting DESeq2 results...")
  res <- DESeq2::results(dds, contrast = contrast)
  res_df <- as.data.frame(res)
  res_df$gene_id <- rownames(res_df)

  # Store total genes
  metadata$n_genes_input <- nrow(res_df)

  # Branch: custom pathways or standard organisms
  if (!is.null(custom_pathways)) {
    message("Using custom pathways for non-model organism...")
    result <- run_gsea_custom(res_df, ranking, custom_pathways, padj_cutoff, ...)
    metadata$pathway_source <- "custom"
  } else {
    message("Using standard organism database...")

    # Capture organism detection
    if (organism == "auto") {
      organism <- detect_organism(res_df$gene_id)
      message("Auto-detected organism: ", organism)
    }
    metadata$organism <- organism

    # Run GSEA and capture mapping stats
    result_list <- run_gsea_standard_with_stats(res_df, organism, ranking, padj_cutoff, ...)
    result <- result_list$gsea_result
    metadata$n_genes_analyzed <- result_list$n_genes_analyzed
    metadata$mapping_rate <- result_list$mapping_rate
    metadata$pathway_source <- "GO:BP"
  }

  # Add pathway counts to metadata
  metadata$n_pathways_significant <- nrow(result)
  if (nrow(result) > 0) {
    metadata$n_pathways_up <- sum(result@result$NES > 0)
    metadata$n_pathways_down <- sum(result@result$NES < 0)
  }

  # Generate report if requested
  if (!is.null(output_report)) {
    if (requireNamespace("base64enc", quietly = TRUE)) {

      message("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      message("Generating professional HTML dashboard...")
      message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

      tryCatch({
        generate_gsea_html_report(
          gsea_result = result,
          metadata = metadata,
          output_file = output_report,
          open_report = open_report
        )
      }, error = function(e) {
        warning("Could not generate report: ", e$message, "\nReturning results object only.")
      })
    } else {
      message("\n⚠ Report generation skipped:")
      message("  Missing package: base64enc")
      message("  Install with: install.packages('base64enc')")
      message("  Returning results object only.")
    }
  }

  # Return both result and metadata
  output <- list(
    gsea_result = result,
    metadata = metadata
  )

  class(output) <- c("smartGSEA_result", class(output))

  # Print summary
  message("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  message("✓ Analysis complete!")
  message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  message("Significant pathways: ", metadata$n_pathways_significant, " (FDR < ", padj_cutoff, ")")
  if (metadata$n_pathways_significant > 0) {
    message("  ↑ Upregulated: ", metadata$n_pathways_up)
    message("  ↓ Downregulated: ", metadata$n_pathways_down)
  }
  message("Genes analyzed: ", metadata$n_genes_analyzed)
  if (!is.null(metadata$mapping_rate)) {
    message("Mapping success: ", round(metadata$mapping_rate * 100, 1), "%")
  }
  message("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

  return(output)
}


# Helper function that returns mapping stats
run_gsea_standard_with_stats <- function(res_df, organism, ranking, padj_cutoff, ...) {

  ranking_col <- ifelse(ranking == "log2fc", "log2FoldChange", "stat")

  # Get organism database
  orgdb_name <- get_orgdb(organism)
  orgdb <- get(orgdb_name, envir = loadNamespace(orgdb_name))

  # Rank genes
  res_clean <- rank_genes(res_df, ranking_col)
  n_genes_input <- nrow(res_clean)

  # Convert gene IDs
  message("Converting gene IDs...")
  res_ids <- clusterProfiler::bitr(
    res_clean$gene_id_clean,
    fromType = "ENSEMBL",
    toType = "ENTREZID",
    OrgDb = orgdb
  )

  # Calculate mapping rate
  mapping_rate <- nrow(res_ids) / n_genes_input

  # Merge
  res_merged <- res_clean %>%
    dplyr::left_join(res_ids, by = c("gene_id_clean" = "ENSEMBL")) %>%
    dplyr::filter(!is.na(ENTREZID))

  # Handle duplicates
  res_merged <- res_merged %>%
    dplyr::group_by(ENTREZID) %>%
    dplyr::arrange(dplyr::desc(abs(!!rlang::sym(ranking_col)))) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup()

  n_genes_final <- nrow(res_merged)

  # Create ranked gene list
  gene_list <- res_merged[[ranking_col]]
  names(gene_list) <- res_merged$ENTREZID
  gene_list <- sort(gene_list, decreasing = TRUE)

  message("Running GSEA on ", length(gene_list), " genes...")

  # Run GSEA
  gsea_all <- clusterProfiler::gseGO(
    geneList = gene_list,
    OrgDb = orgdb,
    ont = "BP",
    pvalueCutoff = 1.0,
    pAdjustMethod = "BH",
    ...
  )

  # Filter
  if (nrow(gsea_all) > 0) {
    gsea_result <- gsea_all
    gsea_result@result <- gsea_all@result %>%
      dplyr::filter(p.adjust < padj_cutoff)
  } else {
    gsea_result <- gsea_all
  }

  message("Found ", nrow(gsea_result), " significant pathways (padj < ", padj_cutoff, ")")

  return(list(
    gsea_result = gsea_result,
    n_genes_analyzed = n_genes_final,
    mapping_rate = mapping_rate
  ))
}
