#!/usr/bin/env python3
"""Plot cumulative coverage distributions from mosdepth global dist files."""

import glob
import os
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
import pandas as pd


INDIR = "results/010_mosdepth"
OUTDIR = "results/010_mosdepth"
MAX_DEPTH = 200


def load_dist(path):
    df = pd.read_csv(path, sep="\t", header=None, names=["chrom", "depth", "fraction"])
    return df[df["chrom"] == "total"][["depth", "fraction"]].sort_values("depth")


def sample_name(path):
    base = os.path.basename(path)
    return base.replace(".mosdepth.global.dist.txt", "")


def main():
    dist_files = sorted(glob.glob(os.path.join(INDIR, "*.mosdepth.global.dist.txt")))
    if not dist_files:
        raise FileNotFoundError(f"No dist files found in {INDIR}")

    samples = [sample_name(f) for f in dist_files]
    colors = cm.tab10(np.linspace(0, 0.9, len(samples)))

    fig, ax = plt.subplots(figsize=(8, 5))

    for path, sample, color in zip(dist_files, samples, colors):
        df = load_dist(path)
        df = df[df["depth"] <= MAX_DEPTH]
        ax.plot(df["depth"], df["fraction"], label=sample, color=color, linewidth=1.5)

    ax.set_xlabel("Coverage depth (×)", fontsize=12)
    ax.set_ylabel("Fraction of genome ≥ depth", fontsize=12)
    ax.set_xlim(0, MAX_DEPTH)
    ax.set_ylim(0, 1.02)
    ax.legend(fontsize=9, frameon=False, loc="upper right")
    ax.spines[["top", "right"]].set_visible(False)

    outpath = os.path.join(OUTDIR, "coverage_distribution.pdf")
    fig.savefig(outpath, bbox_inches="tight", dpi=300)
    print(f"Saved: {outpath}")

    outpath_png = outpath.replace(".pdf", ".png")
    fig.savefig(outpath_png, bbox_inches="tight", dpi=300)
    print(f"Saved: {outpath_png}")


if __name__ == "__main__":
    main()
