library(vcfR)
library(poppr)
library(adegenet)

vcf <- read.vcfR("file.vcf.gz")

# Convert to genind with tetraploid ploidy
gi <- vcfR2genind(vcf, ploidy = 4)

# PCA using allele dosage
x <- tab(gi, freq = TRUE, NA.method = "mean")
pca <- dudi.pca(x, scannf = FALSE, nf = 2)

# Plot
s.label(pca$li, xax = 1, yax = 2)