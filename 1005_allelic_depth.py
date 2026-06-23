import allel

if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        "results/206_filtered_pass/all_diploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "calldata/AD", "variants/QUAL"],
        chunk_length=65536,  # tune this; default is fine for most cases
    )

    for chunk, chunk_length, chrom, chunk_end_pos in it:
        adepth = chunk["calldata/AD"]
        for loci in adepth:
            for sample, distro in zip(samples, loci):
                print()