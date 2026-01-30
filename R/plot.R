#' Plot GSEA Results
#'
#' Create publication-ready plots from GSEA results.
#'
#' @param x A gseaResult object from gsea_from_deseq()
#' @param type Plot type: "dotplot" (default), "barplot", or "enrichment"
#' @param top_n Number of top pathways to show (default: 20)
#' @param ... Additional arguments passed to clusterProfiler plotting functions
#'
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
#' plot_gsea(results)
#' plot_gsea(results, type = "barplot", top_n = 15)
#' }
#'
#' @export
plot_gsea <- function(x, type = "dotplot", top_n = 20, ...) {

  if (nrow(x) == 0) {
    stop("No significant pathways to plot")
  }

  type <- match.arg(type, c("dotplot", "barplot", "enrichment"))

  if (type == "dotplot") {
    p <- enrichplot::dotplot(x, showCategory = top_n, ...)
  } else if (type == "barplot") {
    p <- ggplot2::ggplot(
      head(x@result, top_n),
      ggplot2::aes(x = setSize, y = reorder(Description, abs(NES)), fill = NES)
    ) +
      ggplot2::geom_col() +
      ggplot2::scale_fill_gradient2(
        low = "blue3",
        mid = "white",
        high = "red3",
        midpoint = 0
      ) +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = "Gene Set Size", y = "", title = "Top GSEA Pathways")
  } else if (type == "enrichment") {
    # Show top pathway enrichment plot
    top_pathway <- x@result$ID[1]
    p <- enrichplot::gseaplot2(x, geneSetID = top_pathway, ...)
  }

  return(p)
}

#' Plot Comparison Between Two GSEA Results
#'
#' Create side-by-side comparison plot showing common pathways between
#' two conditions.
#'
#' @param comparison A gsea_comparison object from compare_gsea()
#' @param top_n Number of top common pathways to show (default: 20)
#' @param show_all Logical, if TRUE shows all pathways not just common (default: FALSE)
#'
#' @return A ggplot2 object
#'
#' @examples
#' \dontrun{
#' comparison <- compare_gsea(gsea1, gsea2, label1 = "M1", label2 = "M2")
#' plot_comparison(comparison)
#' plot_comparison(comparison, top_n = 30)
#' }
#'
#' @export
plot_comparison <- function(comparison, top_n = 20, show_all = FALSE) {

  # Get pathways to plot
  if (show_all) {
    plot_data <- comparison$pathways
  } else {
    plot_data <- comparison$pathways[comparison$pathways$Status == "Common", ]
  }

  if (nrow(plot_data) == 0) {
    stop("No pathways to plot")
  }

  # Limit to top N by average absolute NES
  label1 <- names(comparison$pathways)[3]  # NES_label1
  label2 <- names(comparison$pathways)[5]  # NES_label2

  plot_data$avg_abs_NES <- rowMeans(
    abs(cbind(plot_data[[label1]], plot_data[[label2]])),
    na.rm = TRUE
  )

  plot_data <- plot_data %>%
    dplyr::arrange(dplyr::desc(avg_abs_NES)) %>%
    head(top_n)

  # Reshape for plotting
  library(ggplot2)

  # Extract condition labels
  cond1 <- sub("NES_", "", label1)
  cond2 <- sub("NES_", "", label2)

  # Create long format
  plot_long <- rbind(
    data.frame(
      Description = plot_data$Description,
      Condition = cond1,
      NES = plot_data[[label1]],
      padj = plot_data[[sub("NES_", "padj_", label1)]],  # FIX HERE
      Status = plot_data$Status
    ),
    data.frame(
      Description = plot_data$Description,
      Condition = cond2,
      NES = plot_data[[label2]],
      padj = plot_data[[sub("NES_", "padj_", label2)]],  # FIX HERE
      Status = plot_data$Status
    )
  )

  # Order pathways by average NES
  plot_long$Description <- factor(
    plot_long$Description,
    levels = rev(plot_data$Description)
  )

  # Create plot
  p <- ggplot(plot_long, aes(x = NES, y = Description, color = NES)) +
    geom_point(aes(size = -log10(padj)), alpha = 0.7) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    scale_color_gradient2(
      low = "blue3",
      mid = "white",
      high = "red3",
      midpoint = 0,
      name = "NES"
    ) +
    scale_size_continuous(
      name = "-log10(padj)",
      range = c(2, 8)
    ) +
    facet_wrap(~ Condition, ncol = 2) +
    theme_bw() +
    theme(
      axis.text.y = element_text(size = 9),
      strip.text = element_text(face = "bold", size = 11),
      strip.background = element_rect(fill = "gray90"),
      legend.position = "right"
    ) +
    labs(
      x = "Normalized Enrichment Score (NES)",
      y = "",
      title = paste("GSEA Comparison:", cond1, "vs", cond2)
    )

  return(p)
}

#' Plot All Standard GSEA Visualizations
#'
#' Generate all standard plots at once and save to directory.
#'
#' @param x A gseaResult object
#' @param output_dir Directory to save plots (default: "gsea_plots")
#' @param format File format: "pdf" or "png" (default: "pdf")
#' @param width Plot width in inches (default: 12)
#' @param height Plot height in inches (default: 8)
#'
#' @return Invisible NULL (plots saved to files)
#'
#' @examples
#' \dontrun{
#' results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
#' plot_all(results, output_dir = "my_gsea_plots")
#' }
#'
#' @export
plot_all <- function(x, output_dir = "gsea_plots", format = "pdf",
                     width = 12, height = 8) {

  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  message("Generating plots in: ", output_dir)

  # Generate plots
  p1 <- plot_gsea(x, type = "dotplot")
  p2 <- plot_gsea(x, type = "barplot")

  # Save plots
  ggsave(
    file.path(output_dir, paste0("dotplot.", format)),
    p1, width = width, height = height
  )

  ggsave(
    file.path(output_dir, paste0("barplot.", format)),
    p2, width = width, height = height
  )

  message("✓ Saved 2 plots to: ", output_dir)

  invisible(NULL)
}
