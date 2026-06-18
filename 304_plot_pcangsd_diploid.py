#!/usr/bin/env python3
"""Plot PCA from a PCAngsd covariance matrix, colored by population."""

import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from adjustText import adjust_text


COV_FILE = "results/302_pcangsd_diploid/diploid_all.cov"
BAMLIST = "bam_list_diploid.txt"
POPDATA = "RawData/PopData.csv"
OUTDIR = "results/302_pcangsd_diploid"


def sample_name(bam_path):
    return os.path.basename(bam_path).replace(".markdup.bam", "")


def main():
    cov = np.loadtxt(COV_FILE)

    eigvals, eigvecs = np.linalg.eigh(cov)
    order = np.argsort(eigvals)[::-1]
    eigvals, eigvecs = eigvals[order], eigvecs[:, order]
    var_explained = eigvals / eigvals.sum() * 100

    with open(BAMLIST) as f:
        samples = [sample_name(line.strip()) for line in f if line.strip()]

    pop_df = pd.read_csv(POPDATA)

    df = pd.DataFrame({
        "Sample": samples,
        "PC1": eigvecs[:, 0],
        "PC2": eigvecs[:, 1],
    }).merge(pop_df, on="Sample")

    sns.set_theme(style="whitegrid")
    palette = sns.color_palette("pastel", df["Population"].nunique())

    plt.figure(figsize=(8, 6))
    ax = sns.scatterplot(data=df, x="PC1", y="PC2", hue="Population", palette=palette, s=40)

    texts = [ax.text(row["PC1"], row["PC2"], row["Sample"], fontsize=8) for _, row in df.iterrows()]
    adjust_text(texts, ax=ax, arrowprops=dict(arrowstyle="-", color="gray", lw=0.5))

    plt.xlabel(f"PC1 ({var_explained[0]:.2f}%)")
    plt.ylabel(f"PC2 ({var_explained[1]:.2f}%)")
    plt.title("PCAngsd - Piper nigrum diploid samples")
    plt.tight_layout()

    outpath = os.path.join(OUTDIR, "pca_diploid.png")
    plt.savefig(outpath, dpi=300)
    print(f"Saved: {outpath}")


if __name__ == "__main__":
    main()
