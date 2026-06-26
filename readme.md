## Sequencing read processing

- 9 paired-end illumina WGS Piper nigrum counting a total of X,XXX,XXX reads, averaging X,XXX,XXX reads per sample was processed.
- Additionally, 4 samples from NCBI SRA from the same specie and satisfying the required coverage has been added to the analysis, including X,XXX,XXX reads (X,XXX,XXX reads per sample)
- Quality check has been performed using FastQC v0.11.9 (Andrews, 2010).
- kmer distribution has been checked using jellyfish (ref)
- The reads are trimmed using Trimmomatic v0.39 (ref) and the following parameters — ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10:8:true, LEADING:3, TRAILING:3, SLIDINGWINDOW:4:15 and MINLIN:36
- All samples were aligned on the Piper nigrum reference genome using bwa-mem v2.2.1 (ref) resulting in an alignment files averaging 95.72x coverage on the 9 Piper nigrum samples and 56.89x on the 4 NCBI SRA samples.
- The alignment results were sorted by the genomics position and indexed using SamTools v1.9.4 (ref)
- Duplicated reads were marked using MarkDuplicate modules from GATK v4.6.2 (McKenna et al., 2010)

## Variant Calling using GATK

- Variants were called with GATK4 (McKenna et al., 2010), following the programs best‐practices recommendations. 
- HaplotypeCaller was used to generate intermediate gVCF files for each sample, keeping parallel track for diploid and tetraploid configuration, and using -ERC GVCF mode
- The data were split into 45 genomic intervals, using the -L flag, and all single-sample GVCF-files were imported into a Genomics DB using the GenomicsDBImport module from GATK. <!-- need rewrite -->
- GenotypeGVCFs was called to perform joint genotyping for each diploid and tetraploid track.
- bcftools isec was used to create an intersect positions between the the diploid and tetraploid call tracks <!-- make more clear -->
- the resulting VCF file was filtered using the VariantFiltration module of GATK with the following criteria: QD < 2.0, FS > 60.0, MQ < 40.0, MQRankSum < -12.5, ReadPosRankSum < -8.0, and SOR > 3.0.
- XXX SNPs has passed the quality filtering with an abundance of XXX/kbp (Fig 1, Table X);

## Likelihood based genotyping <!-- need to reframe considering the ploidy -->
- ANGSD is used to compute genotype likelyhood in the samples.
- PCANGSD has been computed and plotted from the outputted beagle file (Fig SX)
- NGSAdmix has been run and the admixture plot has been plotted using a home-made python code (Fig SX)

## Population structure and Phylogenetic Tree Analysis
- PCA with Patterson-scaled was performed using the scikit-allel library in python v3.12 (ref) (Fig 2).
- PLINK was used to prune the SNP, leading to X,XXX independent market.
- To perform the phylogenetic tree analysis, the filtered VCF file was converted to PHYLIP using vcf2phylip (https://github.com/edgardomortiz/vcf2phylip). <!-- need rephrase -->
- The script ascbias.py (https://github.com/btmartin721/ raxml_ascbias) was used to remove invariant sites from the alignment.  <!-- need rephrase -->
- A total of xx,xxx variant sites was retained.
- Randomized Axelerated Maximum Likelihood (RAxML) v.x.x.xx was used with a recommended ascertainment bias correction of the likelihood (Lewis 2001) and 1,000 rapid bootstrap replicates to performed maximum likelihood (ML) analysis.
- The best-scoring ML tree resulting from this analysis was visualized in FigTree v.1.4.4 (http://tree.bio.ed.ac.uk/software/figtree/).

## Pairwise relateness and coancestry matrix <!-- ?? -->
- PolyRelatedness 1.11b (Huang et al. 2014) was used to evaluate pairwise relatedness between each Piper nigrum samples. A coancistry estimator based on Ritland (1996) was used to generate the coancestry matrix, which is suitable for multiploidy datasets (Metschina et al 2025).
