# Generate Professional HTML GSEA Report

Creates a beautiful, interactive HTML dashboard report from GSEA results

## Usage

``` r
generate_gsea_html_report(
  gsea_result,
  metadata,
  output_file = "GSEA_report.html",
  open_report = TRUE
)
```

## Arguments

- gsea_result:

  A gseaResult object from clusterProfiler

- metadata:

  List containing analysis metadata (contrast, organism, etc.)

- output_file:

  Path where HTML report should be saved

- open_report:

  Logical, whether to open report in browser (default: TRUE)

## Value

Invisibly returns the path to the generated HTML file
