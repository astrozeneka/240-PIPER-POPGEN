import allel

CHROM_BINS = 2**10

if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )
    density = {} # string => array


    for chunk, chunk_length, chrom, chunk_end_pos in it:
        pos = chunk["variants/POS"]      # shape (chunk_length,)
        gt  = chunk["calldata/GT"]       # shape (chunk_length, n_samples, ploidy)

        # wrap GT if you want GenotypeArray methods (allele counts, het calls, etc.)
        gt_array = allel.GenotypeArray(gt)
        # e.g. allele counts per variant
        ac = gt_array.count_alleles()
        if chrom not in density:
            density[chrom] = []
        for bp in pos:
            while (bp // CHROM_BINS) >= len(density[chrom]):
                density[chrom].append(0)
            density[chrom][bp // CHROM_BINS] += 1


        print(f"chunk of {chunk_length} variants, first POS={pos[0]}, last POS={pos[-1]}")