# easyGSEA <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->
![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![R](https://img.shields.io/badge/R-%3E%3D4.0-blue)
<!-- badges: end -->

<<<<<<< HEAD
**Stop fighting with GSEA. Start getting results.**
=======
> **Stop fighting with GSEA. Start getting results.**
>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397

easyGSEA eliminates the confusion and common mistakes in Gene Set Enrichment Analysis. One line of code. Correct p-values. Publication-ready plots.

---
<<<<<<< HEAD

## The Problem

Standard GSEA workflows are error-prone:

- **P-value confusion** — Filtering on nominal instead of adjusted p-values creates false positives
- **Complex preprocessing** — 20+ lines of gene ID conversion and setup
- **No comparison tools** — Manually comparing conditions is tedious
- **Cryptic errors** — Debugging failures wastes hours

Sound familiar?

---

## The Solution
```r
# One line. That's it.
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
```

**What just happened:**
- Auto-detected your organism (human/mouse/rat/etc.)
- Converted gene IDs automatically
- Ranked genes by log2 fold change
- **Filtered on adjusted p-values** (the right way!)
- Found significant pathways

---
=======
>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397

## 🎯 The Problem

Standard GSEA workflows are a minefield:

- ❌ **Everyone makes the p-value mistake** - Filtering on nominal p-values creates hundreds of false positives
- ❌ **20+ lines of preprocessing** - Gene ID conversion, ranking, organism setup
- ❌ **No standard way to compare** - Clones, treatments, time points—all manual
- ❌ **Cryptic errors** - "unused argument", "mapping failed", mysterious crashes

Sound familiar?

---

## ✨ The Solution
```r
# One line. That's it.
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))
```

**What just happened:**
- ✅ Auto-detected your organism (human/mouse/rat/etc.)
- ✅ Converted gene IDs automatically
- ✅ Ranked genes by log2FC
- ✅ **Filtered on adjusted p-values** (the right way!)
- ✅ Found 247 significant pathways

---

## 📦 Installation
```r
# Install from GitHub
devtools::install_github("ghsamuel/easyGSEA")

# Install organism database (if needed)
BiocManager::install("org.Hs.eg.db")  # Human
BiocManager::install("org.Mm.eg.db")  # Mouse
```

---

<<<<<<< HEAD
## Quick Start

### Basic GSEA
=======
## 🚀 Quick Start

### Basic GSEA (3 lines)
>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397
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
<<<<<<< HEAD
#   M1 pathways: 230
#   M2 pathways: 676
#   Common: 130
#   Jaccard: 0.168
#   Concordance: 100%
=======
#   Metric                    Value
#   M1 total pathways         230
#   M2 total pathways         676
#   Common pathways           130
#   Jaccard similarity        0.168
#   Direction concordance (%) 100
>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397

# Plot side-by-side
plot_comparison(comparison)
```

---

<<<<<<< HEAD
## Features

### Core Functionality

| Feature | easyGSEA | Standard Workflow |
|---------|----------|-------------------|
| **Lines of code** | 1 | 20-50 |
| **P-value filtering** | Always adjusted | Usually wrong |
| **Organism detection** | Automatic | Manual setup |
| **Gene ID conversion** | Handled | You debug it |
| **Comparison** | Built-in | Write it yourself |
| **Non-model organisms** | Supported | Good luck |

### What You Get

**Correct statistics** — Always uses adjusted p-values (FDR < 0.05)

**Auto-detection** — Recognizes human, mouse, rat, fly, zebrafish, worm, yeast

**Custom pathways** — Works with any organism (CSV or GMT format)

**Easy comparison** — Overlap, concordance, Jaccard index built-in

**Publication plots** — Professional figures ready for papers

**Clear documentation** — Examples that actually work

---

## Learn More

- [Getting Started](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html) — 5-minute tutorial
- [Custom Pathways](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.html) — For non-model organisms
- [Function Reference](https://ghsamuel.github.io/easyGSEA/reference/index.html) — Complete documentation

---

## Why This Exists

I got tired of:
- Debugging the same GSEA mistakes in every analysis
- Seeing papers with 1500+ "significant" pathways (nominal p-values!)
- Writing 50 lines of code to compare two clones
- Helping people set up GSEA for the 100th time

So I built the tool I wished existed.

---

## Found a Bug?

[Open an issue](https://github.com/ghsamuel/easyGSEA/issues) or submit a PR!

=======
## 🎨 Features

### Core Functionality

| Feature | easyGSEA | Standard Workflow |
|---------|----------|-------------------|
| **Lines of code** | 1 | 20-50 |
| **P-value filtering** | ✅ Always adjusted | ❌ Usually wrong |
| **Organism detection** | ✅ Automatic | ❌ Manual setup |
| **Gene ID conversion** | ✅ Handled | ❌ You debug it |
| **Comparison** | ✅ Built-in | ❌ Write it yourself |
| **Non-model organisms** | ✅ Supported | ❌ Good luck |

### What You Get

✅ **Correct statistics** - Always uses adjusted p-values (FDR < 0.05)  
✅ **Auto-detection** - Recognizes human, mouse, rat, fly, zebrafish, worm, yeast  
✅ **Custom pathways** - Works with any organism (CSV or GMT format)  
✅ **Easy comparison** - Overlap, concordance, Jaccard index—all automatic  
✅ **Publication plots** - Professional dotplots, barplots, comparison figures  
✅ **Clear documentation** - Examples that actually work

---

## 📚 Learn More

- **[Getting Started](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html)** - 5-minute tutorial
- **[Custom Pathways](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.html)** - Non-model organisms
- **[Function Reference](https://ghsamuel.github.io/easyGSEA/reference/index.html)** - Complete documentation

---

## 💡 Why This Exists

I got tired of:
- Debugging the same GSEA mistakes in every analysis
- Seeing papers with 1500+ "significant" pathways (nominal p-values!)
- Writing 50 lines of code to compare two clones
- Helping people set up GSEA for the 100th time

So I built the tool I wished existed.

---

## 🐛 Found a Bug?

[Open an issue](https://github.com/ghsamuel/easyGSEA/issues) or submit a PR!

---

## 📖 Citation

If easyGSEA helps your research, please cite:
```
Samuel GH (2026). easyGSEA: Simplified Gene Set Enrichment Analysis. 
R package version 0.1.0. https://github.com/ghsamuel/easyGSEA
```

**Also cite clusterProfiler** (the engine under the hood):
```
Yu G, Wang LG, Han Y, He QY (2012). "clusterProfiler: an R package for 
comparing biological themes among gene clusters." OMICS, 16(5), 284-287.
```

---

## 📜 License

MIT © [Glady Hazitha Samuel](https://github.com/ghsamuel)

>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397
---

## 🙏 Acknowledgments

<<<<<<< HEAD
If easyGSEA helps your research, please cite:
```
Samuel GH (2026). easyGSEA: Simplified Gene Set Enrichment Analysis. 
R package version 0.1.0. https://github.com/ghsamuel/easyGSEA
```

**Also cite clusterProfiler** (the engine under the hood):
```
Yu G, Wang LG, Han Y, He QY (2012). "clusterProfiler: an R package for 
comparing biological themes among gene clusters." OMICS, 16(5), 284-287.
```

---

## License

MIT © [Glady Hazitha Samuel](https://github.com/ghsamuel)

---

## Acknowledgments

=======
>>>>>>> ff02c5136e643a7463972cc96d35b1b451ef4397
Built on the excellent [clusterProfiler](https://bioconductor.org/packages/clusterProfiler/) by Guangchuang Yu.

Inspired by everyone who's ever struggled with GSEA (so... everyone).
