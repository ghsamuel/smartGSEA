# Run GSEA from DESeq2 Results (with automatic reporting)

Run GSEA from DESeq2 Results (with automatic reporting)

## Usage

``` r
gsea_from_deseq(
  dds,
  contrast,
  organism = "auto",
  ranking = "log2fc",
  custom_pathways = NULL,
  padj_cutoff = 0.05,
  output_report = "GSEA_report.html",
  open_report = TRUE,
  ...
)
```

## Arguments

- output_report:

  Path for HTML report, or NULL to skip. Default: "GSEA_report.html"

- open_report:

  Logical, whether to open report in browser. Default: TRUE

## Value

A list containing:

- gsea_result: The gseaResult object

- metadata: Analysis parameters and QC metrics
