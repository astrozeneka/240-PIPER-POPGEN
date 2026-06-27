import allel
import numpy as np
import matplotlib.pyplot as plt

DEPTH_BIN_SIZE = 1
if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "variants/QUAL"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )

    depth_bins = {
        sample: []
        for sample in samples
    }

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        call_depth = chunk["calldata/DP"]
        for sample_idx, sample in enumerate(samples):
            if not any(s in sample for s in ["844", "860", "509", "Kitti"]):
                continue
            for depth in call_depth[:, sample_idx]:
                bin_idx = depth//DEPTH_BIN_SIZE
                while len(depth_bins[sample]) <= bin_idx:
                    depth_bins[sample].append(0)
                depth_bins[sample][bin_idx] += 1

    # --- one curve per sample, all on the same histogram ---
    fig, ax = plt.subplots(figsize=(10, 6))
    for sample in samples:
        if not any(s in sample for s in ["844", "860", "509", "Kitti"]):
            continue
        counts = np.array(depth_bins[sample], dtype=float)
        bin_centers = (np.arange(len(counts)) + 0.5) * DEPTH_BIN_SIZE
        ax.plot(bin_centers, counts, label=sample)

    ax.set_xlabel("Depth (DP)")
    ax.set_ylabel("Number of calls")
    ax.legend(fontsize="small", ncol=2)
    ax.set_xlim(0, 400) # O to 400x
    fig.tight_layout()
    fig.savefig("results/1003_calldata_depth.png", dpi=300)