# Compare GSEA Results Between Two Conditions

Compares two GSEA results to identify common and condition-specific
pathways. Calculates overlap statistics, direction concordance, and
identifies discordant pathways.

## Usage

``` r
compare_gsea(gsea1, gsea2, label1 = "Condition1", label2 = "Condition2")
```

## Arguments

- gsea1:

  A gseaResult object from first condition

- gsea2:

  A gseaResult object from second condition

- label1:

  Character string label for first condition (default: "Condition1")

- label2:

  Character string label for second condition (default: "Condition2")

## Value

A list containing:

- common_pathways:

  Data frame of pathways significant in both conditions

- specific1:

  Data frame of pathways only in condition 1

- specific2:

  Data frame of pathways only in condition 2

- stats:

  List of summary statistics (overlap, concordance, etc.)

- labels:

  Named vector of condition labels

## Examples

``` r
if (FALSE) { # \dontrun{
# Compare M1 vs M2 clones
m1_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M1", "S1"))
m2_gsea <- gsea_from_deseq(dds, contrast = c("clone", "M2", "S1"))

comparison <- compare_gsea(m1_gsea, m2_gsea,
                           label1 = "M1", label2 = "M2")

# View statistics
comparison$stats

# View common pathways
head(comparison$common_pathways)
} # }
```
