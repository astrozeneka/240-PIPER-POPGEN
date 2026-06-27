import allel
import numpy as np
import matplotlib.pyplot as plt

DEPTH_BIN_SIZE = 100
if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "variants/QUAL", "calldata/QUAL"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )

    qual_bins = []

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        call_qual = chunk["variants/QUAL"]

        for qual in call_qual:
            bin_idx = int(qual // DEPTH_BIN_SIZE)
            while len(qual_bins) <= bin_idx:
                qual_bins.append(0)
            qual_bins[bin_idx]+= 1

    fig, ax = plt.subplots(figsize=(10,6))
    counts = np.array(qual_bins, dtype=float)
    bins_centers = (np.arange(len(counts)) + 0.5) * DEPTH_BIN_SIZE
    ax.plot(bins_centers, counts, color='orange')
    ax.set_xlim(0, 10000) # O to 400x

    ax.set_xlabel("Quality")
    ax.set_ylabel("Number of calls")
    fig.tight_layout()
    fig.savefig("results/1004_calldata_depth.png", dpi=300)