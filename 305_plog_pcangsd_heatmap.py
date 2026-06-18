#!/usr/bin/env python3
"""Plot a clustered heatmap from a PCAngsd covariance matrix."""

import os
import numpy as np
import pandas as pd
import seaborn as sns


COV_FILE = "results/302_pcangsd_diploid/diploid_all.cov"
BAMLIST = "bam_list_diploid.txt"
OUTDIR = "results/302_pcangsd_diploid"
LOG_SCALE = False


ncbi_sra_provenance = {
    #"SRR6075293": "Landrace Thottumuriyan (Kerala, Kollam, India)",
    #"SRR6075294": "Landrace Thottumuriyan (Kerala, Kollam, India)",
    #"SRR8820205": "Cultivar Renyin (China)",
    #"SRR8820207": "Cultivar Renyin (China)"
    "SRR6075293": "LR Thottumuriyan (India)",
    "SRR6075294": "LR Thottumuriyan (India)",
    "SRR8820205": "Cv. Renyin (China)",
    "SRR8820207": "Cv. Renyin (China"
}

def sample_name(bam_path):
    return os.path.basename(bam_path).replace(".markdup.bam", "")


def main():
    cov = np.loadtxt(COV_FILE)
    if LOG_SCALE:
        cov = np.sign(cov) * np.log1p(np.abs(cov))  # covariance can be negative

    with open(BAMLIST) as f:
        samples = [sample_name(line.strip()) for line in f if line.strip()]

    labels = [x + (f" ({ncbi_sra_provenance[x]})" if x in ncbi_sra_provenance else "") for x in samples]
    cov_df = pd.DataFrame(cov, index=labels, columns=labels)

    sns.set_theme(style="white")
    g = sns.clustermap(cov_df, cmap="vlag", center=0, figsize=(9, 8), cbar_pos=(0.85, 0.05, 0.03, 0.15))
    g.figure.suptitle("PCAngsd covariance - Piper nigrum diploid samples", y=1.02)

    suffix = "_log" if LOG_SCALE else ""
    outpath = os.path.join(OUTDIR, f"pcangsd_heatmap_diploid{suffix}.png")
    g.savefig(outpath, dpi=300)
    print(f"Saved: {outpath}")


if __name__ == "__main__":
    main()
