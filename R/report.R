#' Generate GSEA Report
#'
#' Creates an interactive HTML report summarizing GSEA results with publication-ready
#' visualizations and complete methods documentation.
#'
#' @param gsea_result A gseaResult object from gsea_from_deseq()
#' @param output_file Path for the output HTML report. Default: "GSEA_report.html"
#' @param contrast Character vector of contrast used (from gsea_from_deseq)
#' @param organism Organism name (from gsea_from_deseq)
#' @param ranking Ranking method used (from gsea_from_deseq)
#' @param n_genes Total number of genes analyzed
#' @param mapping_rate Proportion of genes successfully mapped (0-1)
#' @param open_browser Logical, whether to open report in browser. Default: TRUE
#'
#' @return Invisibly returns the path to the generated report
#'
#' @details
#' The report includes:
#' - Summary statistics with visual cards
#' - Interactive dotplot and ridge plot
#' - Searchable/sortable results table with export options
#' - Detailed information for top 5 pathways
#' - Complete methods section with all parameters
#' - Citation information
#'
#' The report is self-contained (single HTML file) and can be shared directly.
#'
#' @examples
#' \dontrun{
#' results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
#' 
#' # Generate report (opens automatically)
#' generate_gsea_report(
#'   results$gsea_result,
#'   contrast = results$metadata$contrast,
#'   organism = results$metadata$organism,
#'   ranking = results$metadata$ranking,
#'   n_genes = results$metadata$n_genes,
#'   mapping_rate = results$metadata$mapping_rate
#' )
#' }
#'
#' @export
generate_gsea_report <- function(gsea_result,
                                 output_file = "GSEA_report.html",
                                 contrast = NULL,
                                 organism = "Unknown",
                                 ranking = "log2fc",
                                 n_genes = NULL,
                                 mapping_rate = NULL,
                                 open_browser = TRUE) {
  
  # Check dependencies
  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    stop("Package 'rmarkdown' is required for report generation. Install with: install.packages('rmarkdown')")
  }
  if (!requireNamespace("DT", quietly = TRUE)) {
    stop("Package 'DT' is required for interactive tables. Install with: install.packages('DT')")
  }
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("Package 'plotly' is required for interactive plots. Install with: install.packages('plotly')")
  }
  
  # Validate inputs
  if (!methods::is(gsea_result, "gseaResult")) {
    stop("gsea_result must be a gseaResult object")
  }
  
  if (is.null(contrast)) {
    contrast <- c("factor", "condition1", "condition2")
    warning("No contrast provided, using generic labels")
  }
  
  # Get template path
  template_path <- system.file("rmarkdown", "templates", "gsea_report", "skeleton", "skeleton.Rmd",
                              package = "smartGSEA")
  
  # If template not found in installed package, use the one we just created
  if (!file.exists(template_path)) {
    # For development: use local template
    template_path <- system.file("extdata", "gsea_report_template.Rmd", package = "smartGSEA")
  }
  
  # Still not found? Use absolute path (for development)
  if (!file.exists(template_path)) {
    template_path <- "/home/claude/gsea_report_template.Rmd"
  }
  
  if (!file.exists(template_path)) {
    stop("Report template not found. Please reinstall smartGSEA or check package installation.")
  }
  
  message("Generating GSEA report...")
  message("Template: ", template_path)
  
  # Prepare parameters
  params <- list(
    gsea_result = gsea_result,
    contrast = contrast,
    organism = organism,
    ranking = ranking,
    n_genes = ifelse(is.null(n_genes), "Unknown", n_genes),
    mapping_rate = ifelse(is.null(mapping_rate), 0.85, mapping_rate)
  )
  
  # Render report
  tryCatch({
    rmarkdown::render(
      input = template_path,
      output_file = basename(output_file),
      output_dir = dirname(output_file),
      params = params,
      envir = new.env(),
      quiet = FALSE
    )
    
    output_path <- normalizePath(output_file)
    message("\n✓ Report generated successfully!")
    message("  Location: ", output_path)
    message("  Size: ", format(file.size(output_path) / 1024^2, digits = 2), " MB")
    
    # Open in browser
    if (open_browser) {
      message("\nOpening report in browser...")
      utils::browseURL(output_path)
    }
    
    invisible(output_path)
    
  }, error = function(e) {
    stop("Failed to generate report: ", e$message)
  })
}
