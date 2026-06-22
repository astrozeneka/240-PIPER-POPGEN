import allel

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
        call_depth =  chunk["calldata/DP"]
        for sample, depth in zip(samples, call_depth.items()):
            bin_idx = depth//DEPTH_BIN_SIZE
            while len(depth_bins[sample]) <= bin_idx:
                depth_bins[sample].append(0)
            depth_bins[sample][bin_idx] += 1

    print()