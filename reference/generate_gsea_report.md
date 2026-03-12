# Generate GSEA Report

Creates an interactive HTML report summarizing GSEA results with
publication-ready visualizations and complete methods documentation.

## Usage

``` r
generate_gsea_report(
  gsea_result,
  output_file = "GSEA_report.html",
  contrast = NULL,
  organism = "Unknown",
  ranking = "log2fc",
  n_genes = NULL,
  mapping_rate = NULL,
  open_browser = TRUE
)
```

## Arguments

- gsea_result:

  A gseaResult object from gsea_from_deseq()

- output_file:

  Path for the output HTML report. Default: "GSEA_report.html"

- contrast:

  Character vector of contrast used (from gsea_from_deseq)

- organism:

  Organism name (from gsea_from_deseq)

- ranking:

  Ranking method used (from gsea_from_deseq)

- n_genes:

  Total number of genes analyzed

- mapping_rate:

  Proportion of genes successfully mapped (0-1)

- open_browser:

  Logical, whether to open report in browser. Default: TRUE

## Value

Invisibly returns the path to the generated report

## Details

The report includes:

- Summary statistics with visual cards

- Interactive dotplot and ridge plot

- Searchable/sortable results table with export options

- Detailed information for top 5 pathways

- Complete methods section with all parameters

- Citation information

The report is self-contained (single HTML file) and can be shared
directly.

## Examples

``` r
if (FALSE) { # \dontrun{
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))

# Generate report (opens automatically)
generate_gsea_report(
  results$gsea_result,
  contrast = results$metadata$contrast,
  organism = results$metadata$organism,
  ranking = results$metadata$ranking,
  n_genes = results$metadata$n_genes,
  mapping_rate = results$metadata$mapping_rate
)
} # }
```
