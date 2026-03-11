# Plot GSEA Results

Create publication-ready plots from GSEA results.

## Usage

``` r
plot_gsea(x, type = "dotplot", top_n = 20, ...)
```

## Arguments

- x:

  A gseaResult object from gsea_from_deseq()

- type:

  Plot type: "dotplot" (default), "barplot", or "enrichment"

- top_n:

  Number of top pathways to show (default: 20)

- ...:

  Additional arguments passed to clusterProfiler plotting functions

## Value

A ggplot2 object

## Examples

``` r
if (FALSE) { # \dontrun{
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
plot_gsea(results)
plot_gsea(results, type = "barplot", top_n = 15)
} # }
```
