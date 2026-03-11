# Run GSEA from DESeq2 Results

Simplified Gene Set Enrichment Analysis that handles DESeq2 results
directly. Automatically converts gene IDs, ranks genes, and runs GSEA
with proper adjusted p-value filtering.

## Usage

``` r
gsea_from_deseq(
  dds,
  contrast,
  organism = "auto",
  ranking = "log2fc",
  custom_pathways = NULL,
  padj_cutoff = 0.05,
  ...
)
```

## Arguments

- dds:

  A DESeqDataSet object from DESeq2

- contrast:

  Character vector specifying the contrast, e.g. c("condition",
  "treated", "control")

- organism:

  Character string specifying organism. Options: "auto" (default,
  auto-detect), "human", "mouse", "rat", "fly", "zebrafish", "worm",
  "yeast". Use "auto" to detect from gene IDs.

- ranking:

  Character string specifying ranking method. Options: "log2fc"
  (default, rank by log2 fold change) or "wald" (rank by Wald
  statistic). log2fc is recommended for standard analyses.

- custom_pathways:

  Optional path to custom pathway file (CSV or GMT format) for non-model
  organisms. See vignette for format details.

- padj_cutoff:

  Adjusted p-value cutoff for pathway significance. Default: 0.05. Note:
  This is ALWAYS adjusted p-value, never nominal.

- ...:

  Additional arguments passed to clusterProfiler::gseGO or
  clusterProfiler::GSEA

## Value

A gseaResult object from clusterProfiler containing significant pathways
(padj \< cutoff)

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage with auto-detection
results <- gsea_from_deseq(dds,
                           contrast = c("condition", "treated", "control"))

# Specify organism explicitly
results <- gsea_from_deseq(dds,
                           contrast = c("condition", "KO", "WT"),
                           organism = "mouse")

# Use Wald statistic for ranking
results <- gsea_from_deseq(dds,
                           contrast = c("genotype", "mutant", "wildtype"),
                           ranking = "wald")

# Non-model organism with custom pathways
results <- gsea_from_deseq(dds,
                           contrast = c("treatment", "treated", "control"),
                           custom_pathways = "my_pathways.csv")
} # }
```
