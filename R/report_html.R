#' Generate Professional HTML GSEA Report
#'
#' Creates a beautiful, interactive HTML dashboard report from GSEA results
#'
#' @param gsea_result A gseaResult object from clusterProfiler
#' @param metadata List containing analysis metadata (contrast, organism, etc.)
#' @param output_file Path where HTML report should be saved
#' @param open_report Logical, whether to open report in browser (default: TRUE)
#'
#' @return Invisibly returns the path to the generated HTML file
#' @export
generate_gsea_html_report <- function(gsea_result, 
                                      metadata, 
                                      output_file = "GSEA_report.html",
                                      open_report = TRUE) {
  
  # Extract results
  result_df <- gsea_result@result
  n_total <- nrow(result_df)
  n_up <- sum(result_df$NES > 0)
  n_down <- sum(result_df$NES < 0)
  
  # Calculate percentages
  pct_up <- round(100 * n_up / n_total, 1)
  pct_down <- round(100 * n_down / n_total, 1)
  mapping_pct <- round(metadata$mapping_rate * 100, 1)
  
  # Format numbers
  n_genes_fmt <- formatC(metadata$n_genes_analyzed, format = "d", big.mark = ",")
  
  # Generate timestamp
  timestamp <- format(Sys.time(), '%B %d, %Y at %H:%M %Z')
  date_only <- format(Sys.time(), '%B %d, %Y')
  
  # Create temporary directory for plot
  temp_dir <- tempdir()
  dotplot_file <- file.path(temp_dir, "dotplot.png")
  
  # Generate and save dotplot
  p <- generate_dotplot(result_df)
  ggplot2::ggsave(dotplot_file, p, width = 12, height = 9, dpi = 150, bg = "white")
  
  # Convert plot to base64
  dotplot_b64 <- base64enc::base64encode(dotplot_file)
  
  # Prepare top pathways HTML - ENSURE IT'S A SINGLE STRING
  top_pathways_html <- generate_top_pathways_html(result_df, n = 5, organism = metadata$organism)
  
  # Prepare full results table HTML - ENSURE IT'S A SINGLE STRING  
  results_table_html <- generate_results_table_html(result_df, organism = metadata$organism)
  
  # Read HTML template
  html_template <- get_html_template()
  
  # Safe replacement helper
  replace_tag <- function(html, tag, value) {
    if (is.null(value)) value <- ""
    if (length(value) > 1) value <- paste(value, collapse = "")
    value <- as.character(value)
    gsub(paste0("{{", tag, "}}"), value, html, fixed = TRUE)
  }
  
  # Replace all placeholders safely
  html_content <- html_template
  html_content <- replace_tag(html_content, "DATE", date_only)
  html_content <- replace_tag(html_content, "TIMESTAMP", timestamp)
  html_content <- replace_tag(html_content, "ORGANISM", metadata$organism)
  html_content <- replace_tag(html_content, "CONTRAST_1", metadata$contrast[2])
  html_content <- replace_tag(html_content, "CONTRAST_2", metadata$contrast[3])
  html_content <- replace_tag(html_content, "RANKING", metadata$ranking)
  html_content <- replace_tag(html_content, "N_TOTAL", n_total)
  html_content <- replace_tag(html_content, "N_UP", n_up)
  html_content <- replace_tag(html_content, "N_DOWN", n_down)
  html_content <- replace_tag(html_content, "PCT_UP", pct_up)
  html_content <- replace_tag(html_content, "PCT_DOWN", pct_down)
  html_content <- replace_tag(html_content, "N_GENES", n_genes_fmt)
  html_content <- replace_tag(html_content, "MAPPING_PCT", mapping_pct)
  html_content <- replace_tag(html_content, "DOTPLOT_BASE64", dotplot_b64)
  html_content <- replace_tag(html_content, "TOP_PATHWAYS", top_pathways_html)
  html_content <- replace_tag(html_content, "RESULTS_TABLE", results_table_html)
  
  # Write HTML file
  writeLines(html_content, output_file)
  
  # Open in browser
  if (open_report) {
    browseURL(output_file)
  }
  
  invisible(output_file)
}


#' Generate dotplot for GSEA results
#' @keywords internal
generate_dotplot <- function(result_df, n = 30) {
  
  # Prepare data
  plot_data <- result_df %>%
    dplyr::arrange(p.adjust) %>%
    head(n) %>%
    dplyr::mutate(
      Description = stringr::str_wrap(Description, width = 50),
      Description = factor(Description, levels = rev(Description)),
      GeneRatio = sapply(strsplit(as.character(core_enrichment), "/"), length) / setSize
    )
  
  # Create plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = GeneRatio, y = Description)) +
    ggplot2::geom_point(ggplot2::aes(size = setSize, color = p.adjust)) +
    ggplot2::scale_color_gradient(
      low = "#dc2626",
      high = "#3b82f6",
      name = "Adjusted\np-value",
      trans = "log10",
      labels = scales::label_scientific()
    ) +
    ggplot2::scale_size_continuous(
      name = "Gene Set\nSize",
      range = c(4, 12)
    ) +
    ggplot2::labs(
      x = "Gene Ratio",
      y = NULL,
      title = paste0("Top ", n, " Enriched Pathways")
    ) +
    ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_text(size = 11, color = "#334155"),
      axis.text.x = ggplot2::element_text(size = 11, color = "#334155"),
      axis.title.x = ggplot2::element_text(size = 13, face = "bold", margin = ggplot2::margin(t = 10)),
      plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0, color = "#0f172a"),
      legend.title = ggplot2::element_text(size = 11, face = "bold"),
      legend.text = ggplot2::element_text(size = 10),
      panel.grid.major.y = ggplot2::element_line(color = "#f1f5f9", size = 0.5),
      panel.grid.major.x = ggplot2::element_line(color = "#e2e8f0", size = 0.5),
      panel.grid.minor = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA)
    )
  
  return(p)
}


#' Convert ENTREZ IDs to gene symbols
#' @keywords internal
convert_entrez_to_symbols <- function(entrez_ids, organism) {
  
  # Determine organism database
  if (tolower(organism) == "human" || tolower(organism) == "homo sapiens") {
    orgdb <- "org.Hs.eg.db"
  } else if (tolower(organism) == "mouse" || tolower(organism) == "mus musculus") {
    orgdb <- "org.Mm.eg.db"
  } else {
    # If unknown organism, just return ENTREZ IDs
    return(entrez_ids)
  }
  
  # Convert ENTREZ to SYMBOL
  tryCatch({
    conversion <- clusterProfiler::bitr(
      entrez_ids,
      fromType = "ENTREZID",
      toType = "SYMBOL",
      OrgDb = orgdb
    )
    
    # Create named vector for lookup
    entrez_to_symbol <- setNames(conversion$SYMBOL, conversion$ENTREZID)
    
    # Replace IDs with symbols, keep original if no match
    result <- sapply(entrez_ids, function(id) {
      symbol <- entrez_to_symbol[as.character(id)]
      if (is.na(symbol)) return(id) else return(symbol)
    })
    
    return(unname(result))
    
  }, error = function(e) {
    # If conversion fails, return original IDs
    return(entrez_ids)
  })
}


#' Convert ENTREZ IDs to gene symbols
#' @keywords internal
convert_to_symbols <- function(entrez_ids, organism) {
  # Split if it's a concatenated string
  if (length(entrez_ids) == 1 && grepl("/", entrez_ids)) {
    entrez_ids <- unlist(strsplit(as.character(entrez_ids), "/"))
  }
  
  # Get organism database
  orgdb <- switch(
    tolower(organism),
    "human" = "org.Hs.eg.db",
    "homo sapiens" = "org.Hs.eg.db",
    "mouse" = "org.Mm.eg.db",
    "mus musculus" = "org.Mm.eg.db",
    "rat" = "org.Rn.eg.db",
    "rattus norvegicus" = "org.Rn.eg.db",
    "org.Hs.eg.db"  # default to human
  )
  
  # Try to convert
  tryCatch({
    conversion <- clusterProfiler::bitr(
      entrez_ids,
      fromType = "ENTREZID",
      toType = "SYMBOL",
      OrgDb = orgdb
    )
    
    # Match order and return symbols
    matched <- match(entrez_ids, conversion$ENTREZID)
    symbols <- conversion$SYMBOL[matched]
    
    # Replace NAs with original ENTREZ IDs
    symbols[is.na(symbols)] <- entrez_ids[is.na(symbols)]
    
    return(symbols)
  }, error = function(e) {
    # If conversion fails, return original IDs
    return(entrez_ids)
  })
}


#' Generate HTML for top pathways section
#' @keywords internal
generate_top_pathways_html <- function(result_df, n = 5, organism = "human") {
  
  top_paths <- result_df %>%
    dplyr::arrange(p.adjust) %>%
    head(n)
  
  # Build HTML for each pathway - CRITICAL: paste() at the end to make single string
  html_parts <- sapply(1:nrow(top_paths), function(i) {
    row <- top_paths[i, ]
    
    # Direction badge
    if (row$NES > 0) {
      badge <- '<span class="badge badge-up">↑ Upregulated</span>'
      border_color <- "#dc2626"
    } else {
      badge <- '<span class="badge badge-down">↓ Downregulated</span>'
      border_color <- "#3b82f6"
    }
    
    # Gene list (first 20) - convert to symbols
    genes_entrez <- unlist(strsplit(as.character(row$core_enrichment), "/"))
    genes_symbols <- convert_to_symbols(genes_entrez, organism)
    n_genes <- length(genes_symbols)
    genes_display <- paste(genes_symbols[1:min(20, n_genes)], collapse = ", ")
    if (n_genes > 20) {
      genes_display <- paste0(genes_display, ", ... (", n_genes - 20, " more)")
    }
    
    # Gene ratio
    gene_ratio_text <- paste0(n_genes, " / ", row$setSize)
    
    paste0('
    <div class="pathway-detail" style="border-left-color: ', border_color, ';">
        <div class="pathway-detail-header">
            <h3 class="pathway-detail-title">
                <span class="pathway-number">', i, '</span>
                ', row$Description, '
            </h3>
            ', badge, '
        </div>
        
        <div class="pathway-meta-grid">
            <div class="pathway-meta-item">
                <div class="pathway-meta-label">Pathway ID</div>
                <div class="pathway-meta-value">', row$ID, '</div>
            </div>
            <div class="pathway-meta-item">
                <div class="pathway-meta-label">NES Score</div>
                <div class="pathway-meta-value" style="color: ', border_color, ';">', 
                  sprintf("%.3f", row$NES), '</div>
            </div>
            <div class="pathway-meta-item">
                <div class="pathway-meta-label">Adjusted p-value</div>
                <div class="pathway-meta-value">', formatC(row$p.adjust, format = "e", digits = 2), '</div>
            </div>
            <div class="pathway-meta-item">
                <div class="pathway-meta-label">Core Enrichment</div>
                <div class="pathway-meta-value">', gene_ratio_text, '</div>
            </div>
        </div>

        <div class="gene-chip-container">
            <div class="gene-chip-label">Core Enrichment Genes</div>
            <div class="gene-chips">', 
              paste(sapply(genes_symbols[1:min(20, n_genes)], function(g) {
                paste0('<span class="gene-chip">', g, '</span>')
              }), collapse = "\n"),
              if (n_genes > 20) paste0('<span class="gene-chip" style="background: #f1f5f9; border: none;">+ ', 
                                       n_genes - 20, ' more</span>') else '',
            '</div>
        </div>
    </div>
    ')
  })
  
  # CRITICAL: Collapse vector into single string
  paste(html_parts, collapse = "\n")
}


#' Generate HTML table for all results
#' @keywords internal  
generate_results_table_html <- function(result_df, organism = "human") {
  
  # Prepare table data
  table_data <- result_df %>%
    dplyr::mutate(
      Direction = ifelse(NES > 0, "↑ Up", "↓ Down"),
      GeneRatio = paste0(
        sapply(strsplit(as.character(core_enrichment), "/"), length),
        " / ",
        setSize
      ),
      p.adjust_fmt = formatC(p.adjust, format = "e", digits = 2),
      pvalue_fmt = formatC(pvalue, format = "e", digits = 2),
      NES_fmt = sprintf("%.2f", NES)
    ) %>%
    dplyr::arrange(p.adjust)
  
  # Build table rows
  rows_html <- sapply(1:nrow(table_data), function(i) {
    row <- table_data[i, ]
    
    # Direction badge styling
    if (row$NES > 0) {
      dir_style <- 'background: #fef2f2; color: #991b1b; padding: 4px 10px; border-radius: 6px; font-weight: 500;'
    } else {
      dir_style <- 'background: #eff6ff; color: #1e40af; padding: 4px 10px; border-radius: 6px; font-weight: 500;'
    }
    
    # Get genes (limit display) - convert to symbols
    genes_entrez <- unlist(strsplit(as.character(row$core_enrichment), "/"))
    genes_symbols <- convert_to_symbols(genes_entrez, organism)
    genes_display <- paste(genes_symbols[1:min(10, length(genes_symbols))], collapse = ", ")
    if (length(genes_symbols) > 10) {
      genes_display <- paste0(genes_display, ", ...")
    }
    
    paste0('
    <tr>
        <td>', row$ID, '</td>
        <td><strong>', row$Description, '</strong></td>
        <td><span style="', dir_style, '">', row$Direction, '</span></td>
        <td>', row$GeneRatio, '</td>
        <td>', row$setSize, '</td>
        <td>', row$NES_fmt, '</td>
        <td>', row$pvalue_fmt, '</td>
        <td>', row$p.adjust_fmt, '</td>
        <td style="font-family: monospace; font-size: 12px;">', genes_display, '</td>
    </tr>
    ')
  })
  
  # CRITICAL: Collapse into single string and wrap in table tags
  paste0('
  <table id="results-table" class="results-table display" style="width:100%">
      <thead>
          <tr>
              <th>Pathway ID</th>
              <th>Description</th>
              <th>Direction</th>
              <th>Gene Ratio</th>
              <th>Set Size</th>
              <th>NES</th>
              <th>p-value</th>
              <th>Adj. p-value</th>
              <th>Genes</th>
          </tr>
      </thead>
      <tbody>
          ', paste(rows_html, collapse = "\n"), '
      </tbody>
  </table>
  ')
}
#' Get HTML template for GSEA report
#' @keywords internal
get_html_template <- function() {
  # Read template from package inst directory
  template_file <- system.file("templates", "gsea_report_template.html", package = "smartGSEA")
  
  if (template_file == "") {
    stop("HTML template file not found. Please reinstall the package.")
  }
  
  # Read and return template
  paste(readLines(template_file, warn = FALSE), collapse = "\n")
}

