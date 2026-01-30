# easyGSEA

Simplified Gene Set Enrichment Analysis from DESeq2 results.

## Why easyGSEA?

Standard GSEA workflows are confusing:
- ❌ Filtering on nominal p-values instead of adjusted (common mistake!)
- ❌ Complex gene ID conversion
- ❌ No easy way to compare conditions
- ❌ Unclear which ranking method to use

easyGSEA solves this with a simple interface that does it right.

## Installation
```r
# Install from GitHub
devtools::install_github("ghsamuel/easyGSEA")
```

## Quick Start
```r
library(easyGSEA)

# Run GSEA directly from DESeq2 results
results <- gsea_from_deseq(
  dds = dds,
  contrast = c("condition", "treated", "control")
)

# Plot results
plot_all(results)

# Compare two conditions
comparison <- compare_gsea(results_m1, results_m2)
plot_comparison(comparison)
```

## Features

- ✅ Works directly with DESeq2 results (no preprocessing needed)
- ✅ Auto-detects organism from gene IDs
- ✅ **Always uses adjusted p-values** (never nominal)
- ✅ Supports custom pathways for non-model organisms
- ✅ Easy condition comparison
- ✅ Publication-ready plots

## Status

🚧 Under active development - check back soon!

## Citation

If you use easyGSEA, please cite both this package and clusterProfiler:

- easyGSEA: Samuel GH (2026). easyGSEA: Simplified Gene Set Enrichment Analysis. R package version 0.1.0. https://github.com/ghsamuel/easyGSEA
- clusterProfiler: Yu G et al. (2012). clusterProfiler: an R package for comparing biological themes among gene clusters. OMICS 16(5):284-287. doi:10.1089/omi.2011.0118
