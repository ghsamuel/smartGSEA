<div align="center">

# easyGSEA

### Stop fighting with GSEA. Start getting results.

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue)](https://www.r-project.org/)

[Documentation](https://ghsamuel.github.io/easyGSEA/) • [Getting Started](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html) • [Report Bug](https://github.com/ghsamuel/easyGSEA/issues)

</div>

---

## Overview

easyGSEA eliminates the confusion and common mistakes in Gene Set Enrichment Analysis. **One line of code. Correct p-values. Publication-ready plots.**
```r
# That's it. Really.
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
```

<br>

## The Problem

Standard GSEA workflows are error-prone:

| Issue | Impact |
|-------|--------|
| **P-value confusion** | Filtering on nominal p-values → hundreds of false positives |
| **Complex preprocessing** | 20+ lines of gene ID conversion and setup |
| **No comparison tools** | Manually comparing conditions is tedious |
| **Cryptic errors** | Hours wasted debugging |

<br>

## The Solution

**What just happened in that one line:**
```mermaid
graph LR
    A[DESeq2 object] --> B[Auto-detect organism]
    B --> C[Convert gene IDs]
    C --> D[Rank by log2FC]
    D --> E[Run GSEA]
    E --> F[Filter on adjusted p-values]
    F --> G[Return results]
```

✓ Auto-detected your organism (human/mouse/rat/etc.)  
✓ Converted gene IDs automatically  
✓ Ranked genes by log2 fold change  
✓ **Filtered on adjusted p-values** (the right way!)  
✓ Found significant pathways  

<br>

## Installation
```r
# Install from GitHub
devtools::install_github("ghsamuel/easyGSEA")

# Install organism database (if needed)
BiocManager::install("org.Hs.eg.db")  # Human
BiocManager::install("org.Mm.eg.db")  # Mouse
```

<br>

## Quick Start

### Basic GSEA
```r
library(easyGSEA)

# Run GSEA
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))

# Visualize
plot_gsea(results)
```

### Compare Two Conditions
```r
# Run both
m1_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M1", "control"))
m2_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M2", "control"))

# Compare
comparison <- compare_gsea(m1_gsea, m2_gsea, label1 = "M1", label2 = "M2")

# See statistics
comparison$summary
#   M1 pathways: 230
#   M2 pathways: 676
#   Common: 130
#   Jaccard: 0.168
#   Concordance: 100%

# Plot side-by-side
plot_comparison(comparison)
```

<br>

## Features

<table>
<tr>
<td width="50%">

### Core Functionality

| Feature | easyGSEA | Standard |
|---------|----------|----------|
| Lines of code | **1** | 20-50 |
| P-value filtering | **Always adjusted** | Usually wrong |
| Organism detection | **Automatic** | Manual |
| Gene ID conversion | **Handled** | You debug it |
| Comparison | **Built-in** | DIY |
| Non-model organisms | **Supported** | Good luck |

</td>
<td width="50%">

### What You Get

**Correct statistics**  
Always uses adjusted p-values (FDR < 0.05)

**Auto-detection**  
Recognizes 7+ model organisms

**Custom pathways**  
Works with any organism (CSV/GMT)

**Easy comparison**  
Overlap, concordance, Jaccard index

**Publication plots**  
Professional figures ready to go

**Clear docs**  
Examples that actually work

</td>
</tr>
</table>

<br>

## Documentation

| Resource | Description |
|----------|-------------|
| [**Getting Started**](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html) | 5-minute tutorial |
| [**Custom Pathways**](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.html) | For non-model organisms |
| [**Function Reference**](https://ghsamuel.github.io/easyGSEA/reference/index.html) | Complete API documentation |

<br>

## Why This Exists

> Debugging the same GSEA mistakes in every analysis, seeing papers with 1500+ "significant" pathways (nominal p-values!), writing 50 lines of code to compare two clones, and helping people set up GSEA for the 100th time.
> 
> So I built the tool I wished existed.

<br>

## Contributing

Found a bug? Have a feature request?

[**Open an issue**](https://github.com/ghsamuel/easyGSEA/issues) or submit a PR!

<br>

## Citation

If easyGSEA helps your research, please cite:
```bibtex
@Manual{easyGSEA,
  title = {easyGSEA: Simplified Gene Set Enrichment Analysis},
  author = {Glady Hazitha Samuel},
  year = {2026},
  note = {R package version 0.1.0},
  url = {https://github.com/ghsamuel/easyGSEA}
}
```

**Also cite clusterProfiler** (the engine under the hood):
```bibtex
@Article{clusterProfiler,
  title = {clusterProfiler: an R package for comparing biological themes among gene clusters},
  author = {Guangchuang Yu and Li-Gen Wang and Yanyan Han and Qing-Yu He},
  journal = {OMICS},
  year = {2012},
  volume = {16},
  number = {5},
  pages = {284-287}
}
```

<br>

---

<div align="center">

### License

MIT © [Glady Hazitha Samuel](https://github.com/ghsamuel)

Built on the excellent [clusterProfiler](https://bioconductor.org/packages/clusterProfiler/) by Guangchuang Yu

**Inspired by everyone who's ever struggled with GSEA** 

</div>
