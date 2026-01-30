#' Compare GSEA Results Between Two Conditions
#'
#' Compares two GSEA results to identify common and condition-specific pathways.
#' Calculates overlap statistics, direction concordance, and identifies
#' discordant pathways.
#'
#' @param gsea1 A gseaResult object from first condition
#' @param gsea2 A gseaResult object from second condition
#' @param label1 Character string label for first condition (default: "Condition1")
#' @param label2 Character string label for second condition (default: "Condition2")
#'
#' @return A list containing:
#'   \item{common_pathways}{Data frame of pathways significant in both conditions}
#'   \item{specific1}{Data frame of pathways only in condition 1}
#'   \item{specific2}{Data frame of pathways only in condition 2}
#'   \item{stats}{List of summary statistics (overlap, concordance, etc.)}
#'   \item{labels}{Named vector of condition labels}
#'
#' @examples
#' \dontrun{
#' # Compare M1 vs M2 clones
#' m1_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M1", "S1"))
#' m2_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M2", "S1"))
#'
#' comparison <- compare_gsea(m1_gsea, m2_gsea,
#'                            label1 = "M1", label2 = "M2")
#'
#' # View statistics
#' comparison$stats
#'
#' # View common pathways
#' head(comparison$common_pathways)
#' }
#'
#' @export
compare_gsea <- function(gsea1, gsea2,
                         label1 = "Condition1",
                         label2 = "Condition2") {

  # Extract pathway IDs
  paths1 <- gsea1@result$ID
  paths2 <- gsea2@result$ID

  # Find overlaps
  common_ids <- intersect(paths1, paths2)
  specific1_ids <- setdiff(paths1, paths2)
  specific2_ids <- setdiff(paths2, paths1)

  # Calculate statistics
  n1 <- length(paths1)
  n2 <- length(paths2)
  n_common <- length(common_ids)
  n_union <- length(union(paths1, paths2))

  jaccard <- n_common / n_union
  overlap_pct1 <- (n_common / n1) * 100
  overlap_pct2 <- (n_common / n2) * 100

  message("\n=== GSEA Comparison: ", label1, " vs ", label2, " ===")
  message(label1, " pathways: ", n1)
  message(label2, " pathways: ", n2)
  message("Common pathways: ", n_common)
  message("Jaccard index: ", round(jaccard, 3))
  message("Overlap: ", round(overlap_pct1, 1), "% of ", label1,
          ", ", round(overlap_pct2, 1), "% of ", label2)

  # Extract common pathway data
  if (n_common > 0) {
    common_data1 <- gsea1@result[gsea1@result$ID %in% common_ids, ]
    common_data2 <- gsea2@result[gsea2@result$ID %in% common_ids, ]

    # Match order
    common_data2 <- common_data2[match(common_ids, common_data2$ID), ]

    # Create comparison data frame
    common_pathways <- data.frame(
      ID = common_data1$ID,
      Description = common_data1$Description,
      NES_1 = common_data1$NES,
      padj_1 = common_data1$p.adjust,
      NES_2 = common_data2$NES,
      padj_2 = common_data2$p.adjust,
      direction_concordant = sign(common_data1$NES) == sign(common_data2$NES),
      stringsAsFactors = FALSE
    )

    # Name columns with labels
    names(common_pathways)[3:6] <- c(
      paste0("NES_", label1),
      paste0("padj_", label1),
      paste0("NES_", label2),
      paste0("padj_", label2)
    )

    # Direction concordance
    n_concordant <- sum(common_pathways$direction_concordant)
    concordance_pct <- (n_concordant / n_common) * 100

    message("\nDirection concordance: ", round(concordance_pct, 1),
            "% (", n_concordant, "/", n_common, " pathways)")

    # Identify discordant pathways
    n_discordant <- n_common - n_concordant
    if (n_discordant > 0) {
      message("⚠ Warning: ", n_discordant, " pathways show opposite regulation")
    }

  } else {
    common_pathways <- data.frame()
    concordance_pct <- NA
    message("\n⚠ No common pathways found!")
  }

  # Extract condition-specific data
  if (length(specific1_ids) > 0) {
    specific1 <- gsea1@result[gsea1@result$ID %in% specific1_ids,
                              c("ID", "Description", "NES", "p.adjust")]
  } else {
    specific1 <- data.frame()
  }

  if (length(specific2_ids) > 0) {
    specific2 <- gsea2@result[gsea2@result$ID %in% specific2_ids,
                              c("ID", "Description", "NES", "p.adjust")]
  } else {
    specific2 <- data.frame()
  }

  # Create single pathways table
  all_pathways <- data.frame()

  # Add common pathways
  if (n_common > 0) {
    common_for_table <- common_pathways
    common_for_table$Status <- "Common"
    all_pathways <- rbind(all_pathways, common_for_table)
  }

  # Add specific pathways
  if (nrow(specific1) > 0) {
    spec1_for_table <- data.frame(
      ID = specific1$ID,
      Description = specific1$Description,
      NES_1 = specific1$NES,
      padj_1 = specific1$p.adjust,
      NES_2 = NA,
      padj_2 = NA,
      direction_concordant = NA,
      Status = paste0(label1, "-specific")
    )
    names(spec1_for_table)[3:6] <- c(
      paste0("NES_", label1), paste0("padj_", label1),
      paste0("NES_", label2), paste0("padj_", label2)
    )
    all_pathways <- rbind(all_pathways, spec1_for_table)
  }

  if (nrow(specific2) > 0) {
    spec2_for_table <- data.frame(
      ID = specific2$ID,
      Description = specific2$Description,
      NES_1 = NA,
      padj_1 = NA,
      NES_2 = specific2$NES,
      padj_2 = specific2$p.adjust,
      direction_concordant = NA,
      Status = paste0(label2, "-specific")
    )
    names(spec2_for_table)[3:6] <- c(
      paste0("NES_", label1), paste0("padj_", label1),
      paste0("NES_", label2), paste0("padj_", label2)
    )
    all_pathways <- rbind(all_pathways, spec2_for_table)
  }

  # Create summary table
  summary_table <- data.frame(
    Metric = c(
      paste0(label1, " total pathways"),
      paste0(label2, " total pathways"),
      "Common pathways",
      "Union (total unique)",
      "Jaccard similarity index",
      paste0("Overlap (% of ", label1, ")"),
      paste0("Overlap (% of ", label2, ")"),
      "Direction concordance (%)"
    ),
    Value = c(
      n1,
      n2,
      n_common,
      n_union,
      round(jaccard, 3),
      round(overlap_pct1, 1),
      round(overlap_pct2, 1),
      ifelse(is.na(concordance_pct), NA, round(concordance_pct, 1))
    )
  )

  # Return simplified structure
  result <- list(
    summary = summary_table,
    pathways = all_pathways
  )

  class(result) <- c("gsea_comparison", "list")
  return(result)
}
