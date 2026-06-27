import allel


if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        #"results/801_intersect/shared_tetraploid_format.vcf.gz",
        "results/706_filtered_pass_tetraploid/all_tetraploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "variants/QUAL"],
        chunk_length=65536,  # tune this; default is fine for most cases
        numbers={"GT": 4}
    )
    frequencies = {
        s:{} for s in samples
    }
    for chunk, chunk_length, chrom, chunk_end_pos in it:
        gts_chunk = chunk["calldata/GT"]  # shape (chunk_length, n_samples, ploidy)
        for gts in gts_chunk:
            for gt, sample in zip(gts, samples):
                genotype_txt = "/".join(map(str, gt))
                frequencies[gt][genotype_txt] = frequencies[gt].get(genotype_txt, 0) + 1
