import allel
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

CHROM_BINS = 2**16

if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )
    density = {} # string => array
    max_pos = {}  # string => last observed SNP position (bp), used as axis extent


    for chunk, chunk_length, chrom, chunk_end_pos in it:
        pos = chunk["variants/POS"]      # shape (chunk_length,)
        gt  = chunk["calldata/GT"]       # shape (chunk_length, n_samples, ploidy)

        # wrap GT if you want GenotypeArray methods (allele counts, het calls, etc.)
        gt_array = allel.GenotypeArray(gt)
        # e.g. allele counts per variant
        ac = gt_array.count_alleles()
        if chrom not in density:
            density[chrom] = []
            max_pos[chrom] = 0
        max_pos[chrom] = max(max_pos[chrom], int(pos.max()))
        for bp in pos:
            while (bp // CHROM_BINS) >= len(density[chrom]):
                density[chrom].append(0)
            density[chrom][bp // CHROM_BINS] += 1


        print(f"chunk of {chunk_length} variants, first POS={pos[0]}, last POS={pos[-1]}")

    # --- 1D heatmap per contig: x = genomic position (Mb), y = contig (discrete) ---
    # pcolormesh (not imshow/seaborn.heatmap) because each row needs its own bin
    # edges: every full bin stays exactly CHROM_BINS wide, and only the genuinely
    # partial final bin is truncated to the true last observed SNP position.
    # imshow+extent would instead stretch ALL bins in a row to fill the extent,
    # and seaborn.heatmap forces one shared grid across every row.
    chrom_keys = list(density.keys())
    contigs = [k.decode().rstrip('\x00') for k in chrom_keys]
    counts_per_contig = [np.asarray(density[k], dtype=float) for k in chrom_keys]
    vmax = max(c.max() for c in counts_per_contig if c.size)

    row_height = 0.8  # leaves a 0.2-row gap between contigs
    norm = mcolors.Normalize(vmin=0, vmax=vmax)
    cmap = plt.get_cmap("viridis")

    fig, ax = plt.subplots(figsize=(10, 0.4 * len(contigs) + 1))
    for i, (key, counts) in enumerate(zip(chrom_keys, counts_per_contig)):
        x_edges = np.arange(len(counts) + 1) * CHROM_BINS
        x_edges[-1] = max_pos[key]  # truncate the partial final bin
        ax.pcolormesh(x_edges / 1e6, [i, i + row_height], counts[np.newaxis, :],
                      cmap=cmap, norm=norm, shading="flat")

    ax.set_xlabel("Genomic position (Mb)")
    ax.set_ylabel("Contig")
    ax.set_yticks(np.arange(len(contigs)) + row_height / 2)
    ax.set_yticklabels(contigs)
    ax.set_ylim(0, len(contigs))
    ax.set_xlim(0, max(max_pos.values()) / 1e6)

    cbar = fig.colorbar(plt.cm.ScalarMappable(cmap=cmap, norm=norm), ax=ax)
    cbar.set_label(f"SNP count per {CHROM_BINS} bp bin")

    fig.tight_layout()
    fig.savefig("results/1002_snp_density_heatmap.png", dpi=300)