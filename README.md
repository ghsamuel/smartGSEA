<div align="center">

<img src="https://img.shields.io/badge/easyGSEA-v0.1.0-5B47ED?style=for-the-badge&logo=r&logoColor=white" alt="easyGSEA" />

# easyGSEA

### Gene Set Enrichment Analysis, simplified.

**Stop wasting hours on GSEA preprocessing. One line. Zero mistakes.**

<br>

[![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange?style=flat-square)](https://lifecycle.r-lib.org/articles/stages.html)
[![MIT License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)
[![R ≥ 4.0](https://img.shields.io/badge/R-%E2%89%A5%204.0-276DC3?style=flat-square&logo=r)](https://www.r-project.org/)

[**Documentation**](https://ghsamuel.github.io/easyGSEA/) · [**Quick Start**](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html) · [**Report Bug**](https://github.com/ghsamuel/easyGSEA/issues) · [**Request Feature**](https://github.com/ghsamuel/easyGSEA/issues)

<br>

<img width="100%" alt="divider" src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

</div>

<br>

## 🎯 The Problem

> *"I spent 3 hours debugging GSEA only to realize I was filtering on nominal p-values."*  
> — Every bioinformatician, ever

<br>

<table>
<tr>
<td>

**Standard GSEA workflow:**
```r
# Extract results
res <- results(dds, contrast = ...)

# Filter
res_sig <- res[!is.na(res$padj) & res$padj < 0.05, ]

# Convert IDs
genes <- mapIds(org.Hs.eg.db, ...)

# Handle duplicates
genes_dedup <- genes[!duplicated(genes)]

# Rank
gene_list <- res_sig$log2FoldChange
names(gene_list) <- genes_dedup
gene_list <- sort(gene_list, decreasing = TRUE)

# Run GSEA (wrong p-value!)
gsea <- gseGO(
  geneList = gene_list,
  pvalueCutoff = 0.05,  # ❌ WRONG!
  ...
)

# Get 1500 pathways (mostly false)
```

**50 lines. 3 hours. Still wrong.**

</td>
<td>

**easyGSEA:**
```r
results <- gsea_from_deseq(
  dds, 
  contrast = c("condition", "treated", "control")
)
```

**1 line. 10 seconds. Always correct.**

<br>

✓ Auto-detects organism  
✓ Converts IDs  
✓ Handles duplicates  
✓ Ranks genes  
✓ **Filters on adjusted p-values**  
✓ Returns clean results  

</td>
</tr>
</table>

<br>

## ⚡ Installation
```r
# Install from GitHub
devtools::install_github("ghsamuel/easyGSEA")

# Install organism annotation (if needed)
BiocManager::install("org.Hs.eg.db")  # Human
```

<br>

## 🚀 Quick Start

### Basic Usage
```r
library(easyGSEA)

# Run GSEA in one line
results <- gsea_from_deseq(dds, contrast = c("condition", "treated", "control"))

# Visualize
plot_gsea(results)
```

<br>

### Compare Conditions
```r
# Compare two clones, treatments, or time points
m1 <- gsea_from_deseq(dds, contrast = c("clone", "M1", "control"))
m2 <- gsea_from_deseq(dds, contrast = c("clone", "M2", "control"))

comparison <- compare_gsea(m1, m2, label1 = "M1", label2 = "M2")
plot_comparison(comparison)
```

**Output:**
```
M1 pathways: 230
M2 pathways: 676
Common: 130 (56%)
Direction concordance: 100%
Jaccard similarity: 0.168
```

<br>

## ✨ Key Features

<div align="center">

| Feature | easyGSEA | Standard Workflow |
|:--------|:--------:|:-----------------:|
| **Lines of code** | `1` | `20-50` |
| **P-value filtering** | ✅ Adjusted (FDR) | ❌ Nominal (wrong!) |
| **Organism detection** | ✅ Automatic | ❌ Manual config |
| **Gene ID conversion** | ✅ Built-in | ❌ Debug yourself |
| **Clone/condition comparison** | ✅ One function | ❌ Write it yourself |
| **Non-model organisms** | ✅ CSV/GMT support | ❌ No solution |
| **Publication plots** | ✅ One command | ❌ Custom ggplot code |

</div>

<br>

## 📊 What You Get

<table>
<tr>
<td width="33%" align="center">

### 🎯 Accurate Results

Always filters on **adjusted p-values** (FDR < 0.05)

Prevents the #1 GSEA mistake

Typical: 200-400 pathways (not 1500!)

</td>
<td width="33%" align="center">

### 🤖 Smart Automation

Auto-detects 7+ organisms

Handles gene ID conversion

Manages duplicates correctly

No configuration needed

</td>
<td width="33%" align="center">

### 📈 Beautiful Viz

Publication-ready dotplots

Side-by-side comparisons

Custom barplots

Export to PDF/PNG

</td>
</tr>
</table>

<br>

## 🌍 Supported Organisms

<div align="center">

| Organism | Auto-detect | Database |
|----------|:-----------:|----------|
| Human | ✅ | `org.Hs.eg.db` |
| Mouse | ✅ | `org.Mm.eg.db` |
| Rat | ✅ | `org.Rn.eg.db` |
| Fly | ✅ | `org.Dm.eg.db` |
| Zebrafish | ✅ | `org.Dr.eg.db` |
| Worm | ✅ | `org.Ce.eg.db` |
| Yeast | ✅ | `org.Sc.sgd.db` |
| **Custom** | ➕ | CSV/GMT files |

</div>

<br>

## 📚 Documentation

<div align="center">

| Guide | What You'll Learn | Time |
|:------|:------------------|:----:|
| [**Getting Started**](https://ghsamuel.github.io/easyGSEA/articles/quickstart.html) | Run your first GSEA analysis | 5 min |
| [**Custom Pathways**](https://ghsamuel.github.io/easyGSEA/articles/custom-pathways.html) | Use with non-model organisms | 10 min |
| [**Function Reference**](https://ghsamuel.github.io/easyGSEA/reference/index.html) | Complete API documentation | — |

[**View Full Documentation →**](https://ghsamuel.github.io/easyGSEA/)

</div>

<br>

## 💭 Why This Exists

<div align="center">



</div>

<br>

**The problem:**
- Everyone makes the p-value mistake (nominal vs adjusted)
- Every lab reinvents the preprocessing wheel
- No standard way to compare conditions
- Cryptic errors waste hours

**The solution:**
- One function that does it right
- Built-in comparison tools
- Clear error messages
- Works out of the box

<br>

## 🤝 Contributing

We welcome contributions! Found a bug? Have a feature request?

<div align="center">

[**Report Bug**](https://github.com/ghsamuel/easyGSEA/issues) · [**Request Feature**](https://github.com/ghsamuel/easyGSEA/issues) · [**Submit PR**](https://github.com/ghsamuel/easyGSEA/pulls)

</div>

<br>

## 📖 Citation

If easyGSEA helps your research, please cite:

**easyGSEA:**
> Samuel GH (2026). easyGSEA: Simplified Gene Set Enrichment Analysis.  
> R package version 0.1.0. https://github.com/ghsamuel/easyGSEA

**clusterProfiler:**
> Yu G, Wang LG, Han Y, He QY (2012). "clusterProfiler: an R package for comparing biological themes among gene clusters."  
> *OMICS: A Journal of Integrative Biology*, 16(5), 284-287. doi:10.1089/omi.2011.0118

<details>

<summary>BibTeX format</summary>
```bibtex
@Manual{samuel2026easygsea,
  title = {easyGSEA: Simplified Gene Set Enrichment Analysis},
  author = {Glady Hazitha Samuel},
  year = {2026},
  note = {R package version 0.1.0},
  url = {https://github.com/ghsamuel/easyGSEA}
}

@Article{yu2012clusterprofiler,
  title = {clusterProfiler: an R package for comparing biological themes among gene clusters},
  author = {Guangchuang Yu and Li-Gen Wang and Yanyan Han and Qing-Yu He},
  journal = {OMICS: A Journal of Integrative Biology},
  year = {2012},
  volume = {16},
  number = {5},
  pages = {284-287},
  doi = {10.1089/omi.2011.0118}
}
```

</details>

<br>

<img width="100%" alt="divider" src="https://raw.githubusercontent.com/andreasbm/readme/master/assets/lines/rainbow.png">

<br>

<div align="center">

### 📜 License

**MIT** © [Glady Hazitha Samuel](https://github.com/ghsamuel)

<br>

### 🙏 Acknowledgments

Built on [**clusterProfiler**](https://bioconductor.org/packages/clusterProfiler/) by Guangchuang Yu

Inspired by every bioinformatician who's ever struggled with GSEA



<br>

**Made with ❤️ for the #rstats community**

</div>
