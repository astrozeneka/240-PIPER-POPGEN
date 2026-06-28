import argparse
import allel
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from joblib import Memory

parser = argparse.ArgumentParser()
parser.add_argument("vcf", help="path to .vcf.gz file")
args = parser.parse_args()

CHROM_BINS = 2**16
VCF_PATH = args.vcf
FAI_PATH = "references/Piper_nigrum.genome.fa.fai"

memory = Memory(location="results/.cache_1002", verbose=0)


@memory.cache
def compute_density(vcf_path, chrom_bins):
    fields, samples, headers, it = allel.iter_vcf_chunks(
        vcf_path,
        fields=["variants/CHROM", "variants/POS", "calldata/GT"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )
    density = {} # string => array

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        chroms = chunk["variants/CHROM"]  # shape (chunk_length,), per-variant contig
        pos = chunk["variants/POS"]       # shape (chunk_length,)
        gt  = chunk["calldata/GT"]        # shape (chunk_length, n_samples, ploidy)

        # wrap GT if you want GenotypeArray methods (allele counts, het calls, etc.)
        gt_array = allel.GenotypeArray(gt)
        # e.g. allele counts per variant
        ac = gt_array.count_alleles()

        # bin by the per-variant CHROM, not the chunk-level chrom: a chunk can
        # straddle a contig boundary, and the chunk-level value alone would
        # misattribute every row before the boundary to the wrong contig
        for row_chrom, bp in zip(chroms, pos):
            if row_chrom not in density:
                density[row_chrom] = []
            while (bp // chrom_bins) >= len(density[row_chrom]):
                density[row_chrom].append(0)
            density[row_chrom][bp // chrom_bins] += 1

        print(f"chunk of {chunk_length} variants, first POS={pos[0]}, last POS={pos[-1]}")

    return density


def read_fai_lengths(fai_path):
    lengths = {}
    with open(fai_path) as fh:
        for line in fh:
            name, length = line.split("\t")[:2]
            lengths[name] = int(length)
    return lengths


if __name__ == '__main__':
    density = compute_density(VCF_PATH, CHROM_BINS)
    contig_lengths = read_fai_lengths(FAI_PATH)

    # iterate over every contig in the reference (not just density.keys()) so
    # contigs with zero called SNPs (e.g. unresolved telomeric scaffolds) still
    # get a full-length, all-zero row instead of being silently dropped
    # contigs = list(contig_lengths.keys())
    contigs = [f"Pn{i}" for i in range(1, 27)]
    counts_per_contig = []
    for chrom in contigs:
        n_bins = -(-contig_lengths[chrom] // CHROM_BINS)  # ceil division
        counts = np.zeros(n_bins, dtype=float)
        if chrom in density:
            observed = density[chrom]
            counts[:len(observed)] = observed
        counts_per_contig.append(counts)

    # convert raw per-bin counts to a density (loci/Mbp) so the truncated,
    # narrower final bin of each contig isn't shown darker/lighter just
    # because it covers less genomic distance than a full CHROM_BINS bin
    density_per_contig = []
    for chrom, counts in zip(contigs, counts_per_contig):
        x_edges = np.arange(len(counts) + 1) * CHROM_BINS
        x_edges[-1] = contig_lengths[chrom]
        bin_widths_kb = np.diff(x_edges) / 1e3
        density_per_contig.append(counts / bin_widths_kb)

    vmax = max(d.max() for d in density_per_contig if d.size)

    row_height = 0.8  # leaves a 0.2-row gap between contigs
    row_gap = 0.3  # gap between the top border and the first contig row
    norm = mcolors.Normalize(vmin=0, vmax=vmax)
    cmap = plt.get_cmap("viridis")

    # --- 1D heatmap per contig: x = genomic position (Mb), y = contig (discrete) ---
    # pcolormesh (not imshow/seaborn.heatmap) because each row needs its own bin
    # edges: every full bin stays exactly CHROM_BINS wide, and only the genuinely
    # partial final bin is truncated to the true contig length. imshow+extent
    # would instead stretch ALL bins in a row to fill the extent, and
    # seaborn.heatmap forces one shared grid across every row.
    fig, ax = plt.subplots(figsize=(10, 0.4 * len(contigs) + 1))
    for i, (chrom, density) in enumerate(zip(contigs, density_per_contig)):
        x_edges = np.arange(len(density) + 1) * CHROM_BINS
        x_edges[-1] = contig_lengths[chrom]  # truncate the partial final bin
        ax.pcolormesh(x_edges / 1e6, [i, i + row_height], density[np.newaxis, :],
                      cmap=cmap, norm=norm, shading="flat")

    ax.set_xlabel("Genomic position (Mb)")
    ax.set_ylabel("Chromosome")
    ax.set_yticks(np.arange(len(contigs)) + row_height / 2)
    ax.set_yticklabels(contigs)
    ax.set_ylim(-row_gap, len(contigs))
    ax.invert_yaxis()  # first contig (Pn1) on top
    ax.set_xlim(0, max(contig_lengths.values()) / 1e6)
    ax.xaxis.set_ticks_position("top")
    ax.xaxis.set_label_position("top")
    ax.spines[["left", "right", "bottom"]].set_visible(False)

    cbar = fig.colorbar(plt.cm.ScalarMappable(cmap=cmap, norm=norm), ax=ax,
                         orientation="vertical", location="right", shrink=0.08, aspect=5,
                         anchor=(0, 1))
    cbar.set_label("SNP density (loci/kb)")

    fig.tight_layout()
    out_png = VCF_PATH.removesuffix(".vcf.gz") + ".png"
    fig.savefig(out_png, dpi=300)