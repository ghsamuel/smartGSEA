# Getting Started with easyGSEA

## Introduction

easyGSEA simplifies Gene Set Enrichment Analysis (GSEA) by handling
DESeq2 results directly. No more manual gene ID conversion, confusing
p-value filtering, or complex workflows.

## Installation

``` r
# Install from GitHub
devtools::install_github("ghsamuel/easyGSEA")

# Install organism databases (if needed)
BiocManager::install("org.Hs.eg.db")  # Human
BiocManager::install("org.Mm.eg.db")  # Mouse
```

## Basic Usage

### Step 1: Run DESeq2

``` r
library(DESeq2)
library(easyGSEA)

# Assume you have a DESeqDataSet object
dds <- DESeq(dds)
```

### Step 2: Run GSEA (one line!)

``` r
# Auto-detect organism and run GSEA
results <- gsea_from_deseq(
  dds = dds,
  contrast = c("condition", "treated", "control")
)

# See how many pathways found
nrow(results)

# View top pathways
head(results@result[, c("Description", "NES", "p.adjust")])
```

### Step 3: Plot Results

``` r
# Dotplot (default)
plot_gsea(results)

# Barplot
plot_gsea(results, type = "barplot")

# Save all plots
plot_all(results, output_dir = "my_gsea_results")
```

## Comparing Two Conditions

A common use case is comparing two experimental conditions (e.g., two
clones, two treatments, two time points).

``` r
# Run GSEA on both conditions
condition1 <- gsea_from_deseq(dds, contrast = c("treatment", "A", "control"))
condition2 <- gsea_from_deseq(dds, contrast = c("treatment", "B", "control"))

# Compare them
comparison <- compare_gsea(condition1, condition2,
                          label1 = "Treatment A",
                          label2 = "Treatment B")

# View summary statistics
comparison$summary

# View common pathways
head(comparison$pathways[comparison$pathways$Status == "Common", ])

# Plot comparison
plot_comparison(comparison)
```

### Interpreting Comparison Results

The comparison provides:

- **Common pathways**: Present in both conditions (highest confidence)
- **Condition-specific pathways**: May reflect real biological
  differences OR technical artifacts (off-targets, integration sites,
  batch effects)
- **Jaccard index**: Similarity metric (0 = no overlap, 1 = identical)
- **Direction concordance**: % of common pathways going same direction

**For replicate/clone comparisons**: High concordance (\>80%) expected.
Low overlap may indicate technical artifacts.

**For different treatment comparisons**: Low overlap expected - you’re
comparing different biology!

## Specifying Organism

By default, easyGSEA auto-detects organism from gene IDs:

``` r
# Auto-detect (recommended)
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
```

You can also specify explicitly:

``` r
# Human
results <- gsea_from_deseq(dds, 
                          contrast = c("condition", "treated", "control"),
                          organism = "human")

# Mouse
results <- gsea_from_deseq(dds,
                          contrast = c("condition", "KO", "WT"),
                          organism = "mouse")
```

Supported organisms: `human`, `mouse`, `rat`, `fly`, `zebrafish`,
`worm`, `yeast`

## Ranking Methods

Two ranking methods are available:

### log2 Fold Change (default, recommended)

``` r
results <- gsea_from_deseq(dds,
                          contrast = c("condition", "treated", "control"),
                          ranking = "log2fc")
```

**Use when:** Standard RNA-seq analysis. Emphasizes biological effect
size.

### Wald Statistic

``` r
results <- gsea_from_deseq(dds,
                          contrast = c("condition", "treated", "control"),
                          ranking = "wald")
```

**Use when:** Want to emphasize statistical confidence. Finds more
pathways (including subtle but consistent changes).

**Note:** Wald ranking typically finds 2-3x more pathways than log2FC
because it favors consistent changes even if effect size is moderate.

## Non-Model Organisms

For organisms without annotation databases, provide custom pathways:

``` r
# Create custom pathway file (CSV format)
# Columns: pathway, gene_id
# Example: "DNA_repair", "gene_001"

results <- gsea_from_deseq(dds,
                          contrast = c("condition", "treated", "control"),
                          custom_pathways = "my_pathways.csv")
```

See
[`vignette("custom-pathways")`](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.md)
for details.

## Important Notes

### Always Uses Adjusted P-Values

easyGSEA **always** filters on adjusted p-values (padj \< 0.05 by
default), never nominal p-values. This is critical for avoiding false
positives when testing thousands of pathways.

``` r
# Change significance threshold if needed
results <- gsea_from_deseq(dds,
                          contrast = c("condition", "treated", "control"),
                          padj_cutoff = 0.01)  # More stringent
```

### Gene ID Conversion

Genes are automatically converted from ENSEMBL to ENTREZ IDs. Some genes
(~10-20%) may fail to map - this is normal.

### Number of Pathways

**Typical ranges:** - Weak perturbation: 10-50 pathways - Moderate
perturbation: 100-400 pathways  
- Strong perturbation: 400-800 pathways - Very strong: 800+ pathways

If you get \>1000 pathways, consider using more stringent threshold
(`padj_cutoff = 0.01`).

## Next Steps

- See
  [`?gsea_from_deseq`](https://ghsamuel.github.io/easyGSEA/reference/gsea_from_deseq.md)
  for full parameter details
- See `vignette("model-organisms")` for organism-specific guidance
- See
  [`vignette("custom-pathways")`](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.md)
  for non-model organisms
- See `vignette("comparison")` for detailed comparison examples

## Citation

If you use easyGSEA, please cite both this package and clusterProfiler:

- **easyGSEA**: Samuel GH (2026). easyGSEA: Simplified Gene Set
  Enrichment Analysis. R package version 0.1.0.
  <https://github.com/ghsamuel/easyGSEA>

- **clusterProfiler**: Yu G, Wang LG, Han Y, He QY (2012).
  “clusterProfiler: an R package for comparing biological themes among
  gene clusters.” OMICS: A Journal of Integrative Biology, 16(5),
  284-287. <doi:10.1089/omi.2011.0118>
