#!/usr/bin/env python3
"""Plot jellyfish kmer histograms: 9 individual PNGs + 1 overlay PNG."""

import glob
import os
import matplotlib.pyplot as plt
import numpy as np

HISTO_DIR = "results/003_kmer"
OUT_DIR = "results/003_kmer"
XMAX = 300  # trim x-axis; count=1 (errors) skipped for readability
YLIM_PERCENTILE = 99.9   # percentile of y values used to set the y-axis ceiling
YLIM_PAD = 1.05        # multiply the percentile value by this for headroom

def load_histo(path):
    data = np.loadtxt(path, dtype=np.int64)
    # skip count=1 (sequencing errors dominate and obscure the peak)
    mask = data[:, 0] > 1
    x = data[mask, 0]
    y = data[mask, 1]
    return x, y

def sample_name(path):
    return os.path.basename(path).replace(".histo", "")

def compute_ylim(y_arrays, percentile=YLIM_PERCENTILE, pad=YLIM_PAD):
    all_y = np.concatenate(y_arrays)
    return np.percentile(all_y, percentile) * pad

if __name__ == '__main__':

    histo_files = sorted(glob.glob(os.path.join(HISTO_DIR, "*.histo")))
    if not histo_files:
        raise FileNotFoundError(f"No .histo files found in {HISTO_DIR}")

    all_data = {path: load_histo(path) for path in histo_files}

    # --- Individual plots ---
    for path in histo_files:
        name = sample_name(path)
        x, y = all_data[path]
        ylim = compute_ylim([y])

        fig, ax = plt.subplots(figsize=(8, 5))
        ax.plot(x, y, linewidth=1.2)
        ax.set_ylim(0, ylim)
        ax.set_xlim(2, XMAX)
        ax.set_xlabel("Kmer multiplicity")
        ax.set_ylabel("Count")
        ax.set_title(f"Kmer histogram — {name}")
        ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
        fig.tight_layout()

        out_path = os.path.join(OUT_DIR, f"{name}_kmer_histo.png")
        fig.savefig(out_path, dpi=150)
        plt.close(fig)
        print(f"Saved {out_path}")

    # --- Overlay plot ---
    overlay_ylim = compute_ylim([y for _, (_, y) in all_data.items()])
    fig, ax = plt.subplots(figsize=(10, 6))
    for path in histo_files:
        name = sample_name(path)
        x, y = all_data[path]
        ax.plot(x, y, linewidth=1.0, label=name)

    ax.set_ylim(0, overlay_ylim)
    ax.set_xlim(2, XMAX)
    ax.set_xlabel("Kmer multiplicity")
    ax.set_ylabel("Count")
    ax.set_title("Kmer histograms — all samples")
    ax.ticklabel_format(axis="y", style="sci", scilimits=(0, 0))
    ax.legend(fontsize=7, loc="upper right")
    fig.tight_layout()

    out_path = os.path.join(OUT_DIR, "all_samples_kmer_histo.png")
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"Saved {out_path}")
