import allel

if __name__ == '__main__':

    fields, samples, headers, it = allel.iter_vcf_chunks(
        #"results/801_intersect/shared_tetraploid_format.vcf.gz",
        "results/706_filtered_pass_tetraploid/all_tetraploid.passonly.vcf.gz",
        fields=["variants/POS", "calldata/GT", "variants/DP", "calldata/DP", "variants/QUAL", "calldata/AD"],
        chunk_length=65536,  # tune this; default is fine for most cases
        numbers={"GT": 4, "AD": 2}
    )

    frequencies = {s: {"R/R+A": []} for s in samples}
    for chunk, chunk_length, chrom, chunk_end_pos in it:
        gts_chunk = chunk["calldata/GT"]
        dps_chunk = chunk["calldata/DP"]
        ads_chunk = chunk["calldata/AD"]
        for gts, ads in zip(gts_chunk, ads_chunk):
            for gt, ad, sample in zip(gts, ads, samples):
                R_depth = ad[0]
                A_depth = ad[1]
                if R_depth + A_depth == 0:
                    continue
                frequencies[sample]["R/R+A"].append(R_depth / (R_depth + A_depth))
        print()
    print()