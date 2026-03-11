# Plot Comparison Between Two GSEA Results

Create side-by-side comparison plot showing common pathways between two
conditions.

## Usage

``` r
plot_comparison(comparison, top_n = 20, show_all = FALSE)
```

## Arguments

- comparison:

  A gsea_comparison object from compare_gsea()

- top_n:

  Number of top common pathways to show (default: 20)

- show_all:

  Logical, if TRUE shows all pathways not just common (default: FALSE)

## Value

A ggplot2 object

## Examples

``` r
if (FALSE) { # \dontrun{
comparison <- compare_gsea(gsea1, gsea2, label1 = "M1", label2 = "M2")
plot_comparison(comparison)
plot_comparison(comparison, top_n = 30)
} # }
```
