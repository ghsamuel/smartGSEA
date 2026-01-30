#' Run GSEA from DESeq2 Results
#'
#' Simplified Gene Set Enrichment Analysis that handles DESeq2 results directly.
#' Automatically converts gene IDs, ranks genes, and runs GSEA with proper
#' adjusted p-value filtering.
#'
#' @param dds A DESeqDataSet object from DESeq2
#' @param contrast Character vector specifying the contrast, e.g.
#'   c("condition", "treated", "control")
#' @param organism Character string specifying organism. Options: "auto"
#'   (default, auto-detect), "human", "mouse", "rat", "fly", "zebrafish",
#'   "worm", "yeast". Use "auto" to detect from gene IDs.
#' @param ranking Character string specifying ranking method. Options:
#'   "log2fc" (default, rank by log2 fold change) or "wald" (rank by Wald
#'   statistic). log2fc is recommended for standard analyses.
#' @param custom_pathways Optional path to custom pathway file (CSV or GMT
#'   format) for non-model organisms. See vignette for format details.
#' @param padj_cutoff Adjusted p-value cutoff for pathway significance.
#'   Default: 0.05. Note: This is ALWAYS adjusted p-value, never nominal.
#' @param ... Additional arguments passed to clusterProfiler::gseGO or
#'   clusterProfiler::GSEA
#'
#' @return A gseaResult object from clusterProfiler containing significant
#'   pathways (padj < cutoff)
#'
#' @examples
#' \dontrun{
#' # Basic usage with auto-detection
#' results <- gsea_from_deseq(dds,
#'                            contrast = c("condition", "treated", "control"))
#'
#' # Specify organism explicitly
#' results <- gsea_from_deseq(dds,
#'                            contrast = c("condition", "KO", "WT"),
#'                            organism = "mouse")
#'
#' # Use Wald statistic for ranking
#' results <- gsea_from_deseq(dds,
#'                            contrast = c("genotype", "mutant", "wildtype"),
#'                            ranking = "wald")
#'
#' # Non-model organism with custom pathways
#' results <- gsea_from_deseq(dds,
#'                            contrast = c("treatment", "treated", "control"),
#'                            custom_pathways = "my_pathways.csv")
#' }
#'
#' @export
gsea_from_deseq <- function(dds,
                            contrast,
                            organism = "auto",
                            ranking = "log2fc",
                            custom_pathways = NULL,
                            padj_cutoff = 0.05,
                            ...) {

  # Input validation
  if (!methods::is(dds, "DESeqDataSet")) {
    stop("dds must be a DESeqDataSet object from DESeq2")
  }

  if (length(contrast) != 3) {
    stop("contrast must be a character vector of length 3, e.g. c('condition', 'treated', 'control')")
  }

  if (!ranking %in% c("log2fc", "wald")) {
    stop("ranking must be either 'log2fc' or 'wald'")
  }

  # Extract DESeq2 results
  message("Extracting DESeq2 results...")
  res <- DESeq2::results(dds, contrast = contrast)

  # Convert to data frame with gene IDs
  res_df <- as.data.frame(res)
  res_df$gene_id <- rownames(res_df)

  # Branch: custom pathways or standard organisms
  if (!is.null(custom_pathways)) {
    message("Using custom pathways for non-model organism...")
    result <- run_gsea_custom(res_df, ranking, custom_pathways, padj_cutoff, ...)
  } else {
    message("Using standard organism database...")
    result <- run_gsea_standard(res_df, organism, ranking, padj_cutoff, ...)
  }

  return(result)
}
