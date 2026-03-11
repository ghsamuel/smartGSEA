# Plot All Standard GSEA Visualizations

Generate all standard plots at once and save to directory.

## Usage

``` r
plot_all(x, output_dir = "gsea_plots", format = "pdf", width = 12, height = 8)
```

## Arguments

- x:

  A gseaResult object

- output_dir:

  Directory to save plots (default: "gsea_plots")

- format:

  File format: "pdf" or "png" (default: "pdf")

- width:

  Plot width in inches (default: 12)

- height:

  Plot height in inches (default: 8)

## Value

Invisible NULL (plots saved to files)

## Examples

``` r
if (FALSE) { # \dontrun{
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
plot_all(results, output_dir = "my_gsea_plots")
} # }
```
