import allel

if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "variants/QUAL"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        pos = chunk["variants/POS"]      # shape (chunk_length,)
        gt  = chunk["calldata/GT"]       # shape (chunk_length, n_samples, ploidy)

        # wrap GT if you want GenotypeArray methods (allele counts, het calls, etc.)
        gt_array = allel.GenotypeArray(gt)
        # e.g. allele counts per variant
        ac = gt_array.count_alleles()

        print(f"chunk of {chunk_length} variants, first POS={pos[0]}, last POS={pos[-1]}")