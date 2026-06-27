import allel
import numpy as np
import matplotlib.pyplot as plt
from joblib import Memory

RATIO_BIN_SIZE = 0.01
VCF_PATH = "results/206_filtered_pass/all_diploid.passonly.vcf.gz"

memory = Memory(location="results/.cache_1005", verbose=0)


@memory.cache
def compute_ratio_bins(vcf_path, ratio_bin_size):
    fields, samples, headers, it = allel.iter_vcf_chunks(
        vcf_path,
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "calldata/AD", "variants/QUAL", "variants/REF", "variants/ALT"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )

    ratio_bins = {
        sample: []
        for sample in samples
    }

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        adepth = chunk["calldata/AD"]
        gt = chunk["calldata/GT"]
        ref = chunk["variants/REF"]
        alt = chunk["variants/ALT"]
        for i, loci in enumerate(adepth):
            # alleles[j] is the nucleotide for distro[j]: [REF, ALT1, ALT2, ALT3]
            genotypes = gt[i]
            alleles = [ref[i]] + list(alt[i])
            for sample, distro in zip(samples, loci):
                if distro[2] >= 0 or distro[3] >= 0:
                    continue # Discard non biallelic snp
                if distro[0] + distro[1] <= 0:
                    continue
                alt_ratio = distro[1] / (distro[0] + distro[1])
                bin_idx = int(alt_ratio // ratio_bin_size)
                while len(ratio_bins[sample]) <= bin_idx:
                    ratio_bins[sample].append(0)
                ratio_bins[sample][bin_idx] += 1

        print(f"chunk of {chunk_length} variants, first POS={chunk['variants/POS'][0]}, last POS={chunk['variants/POS'][-1]}")

    return samples, ratio_bins


if __name__ == '__main__':
    samples, ratio_bins = compute_ratio_bins(VCF_PATH, RATIO_BIN_SIZE)

    # --- one curve per sample, all on the same histogram ---
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = plt.get_cmap("tab20")(np.linspace(0, 1, len(samples)))
    for sample, color in zip(samples, colors):
        if not any(s in sample for s in ["844", "860", "509", "Kitti"]):
            continue
        counts = np.array(ratio_bins[sample], dtype=float)
        bin_centers = (np.arange(len(counts)) + 0.5) * RATIO_BIN_SIZE
        ax.plot(bin_centers, counts, label=sample, color=color)

    ax.set_xlabel("Alt allele depth ratio (AD)")
    ax.set_ylabel("Number of calls")
    ax.legend(fontsize="small", ncol=2)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 500_000)
    fig.tight_layout()
    fig.savefig("results/1005_allelic_depth.png", dpi=300)