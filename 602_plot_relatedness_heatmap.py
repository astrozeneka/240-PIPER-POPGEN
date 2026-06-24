#!/usr/bin/env python3
import argparse

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def load_matrix(path):
    with open(path) as fh:
        lines = fh.readlines()

    header_idx = None
    for i, line in enumerate(lines):
        fields = line.rstrip("\n").split("\t")
        if len(fields) > 1 and fields[0] == "" and all(fields[1:]):
            header_idx = i
            break
    if header_idx is None:
        raise SystemExit(f"ERROR: could not find a matrix header line in {path}")

    df = pd.read_csv(path, sep="\t", skiprows=header_idx, index_col=0)
    df.index = df.index.astype(str)
    df.columns = df.columns.astype(str)
    return df


def main():
    ap = argparse.ArgumentParser(
        description="Plot a PolyRelatedness out.txt pairwise relatedness matrix as a heatmap."
    )
    ap.add_argument("--matrix", default="results/601_polyrelatedness_diploid/out.txt", help="PolyRelatedness out.txt path")
    ap.add_argument("--out", default="results/601_polyrelatedness_diploid/relatedness_heatmap.png", help="Output image path (.png/.pdf/.svg)")
    ap.add_argument("--no-cluster", action="store_true",
                     help="Plot a plain heatmap (sample order as in the file) instead of hierarchically clustering rows/cols")
    ap.add_argument("--vmin", type=float, default=-1.0)
    ap.add_argument("--vmax", type=float, default=1.0)
    ap.add_argument("--cmap", default="RdBu_r")
    ap.add_argument("--annot", action="store_true", help="Print numeric values in each cell")
    args = ap.parse_args()

    df = load_matrix(args.matrix)
    clipped = df.clip(lower=args.vmin, upper=args.vmax)

    if args.no_cluster:
        fig, ax = plt.subplots(figsize=(0.5 * len(df) + 3, 0.5 * len(df) + 2))
        sns.heatmap(clipped, vmin=args.vmin, vmax=args.vmax, cmap=args.cmap,
                    annot=args.annot, fmt=".2f", square=True,
                    cbar_kws={"label": "Relatedness coefficient"}, ax=ax)
        fig.tight_layout()
        fig.savefig(args.out, dpi=300)
    else:
        g = sns.clustermap(clipped, vmin=args.vmin, vmax=args.vmax, cmap=args.cmap,
                            annot=args.annot, fmt=".2f",
                            figsize=(0.5 * len(df) + 3, 0.5 * len(df) + 3),
                            cbar_kws={"label": "Relatedness coefficient"})
        g.savefig(args.out, dpi=300)

    print(f"Wrote heatmap to {args.out}")

    out_of_range = df[(df < args.vmin) | (df > args.vmax)]
    flagged = out_of_range.stack()
    flagged = flagged[flagged.index.map(lambda ix: ix[0] != ix[1])]
    if not flagged.empty:
        n_pairs = len(flagged) // 2
        print(f"NOTE: {n_pairs} pairs fall outside [{args.vmin}, {args.vmax}] and were clipped for display "
              f"(values unchanged in {args.matrix}). Example: "
              f"{flagged.index[0]} = {flagged.iloc[0]:.3f}")


if __name__ == "__main__":
    main()
