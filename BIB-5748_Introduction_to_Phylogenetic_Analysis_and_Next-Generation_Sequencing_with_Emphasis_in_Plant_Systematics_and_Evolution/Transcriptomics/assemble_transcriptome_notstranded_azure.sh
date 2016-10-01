#!/bin/bash
cd `pwd`
#Usage $1= reads1 $2= reads2 $3 species (one word, no underscores)
mkdir $3
cd $3
#bunzip2 -c $1 > $3_reads1.fq
gunzip -c $2 > $3_reads2.fq

#time perl /home/mmckain/bin/new_fastq_cleaner.pl -left $1 -right $2

#module load jre-1.7
#module load compiler/gcc-4.8.2
export PATH=$PATH:/data/pireslab/Asparagales/bin/samtools-bcftools-htslib-1.0_x64-linux/bin

READ_COUNT="`grep \"^@\" -c $3_reads2.fq`"

rm $3_reads2.fq

if [ $READ_COUNT -ge 50000000 ]
then
        time -p /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/Trinity --seqType fq --trimmomatic --quality_trimming_params 'ILLUMINACLIP:/data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/trinity-plugins/Trimmomatic/adapters/TruSeq2-PE.fa:2:30:10 SLIDINGWINDOW:10:20' --normalize_reads --group_pairs_distance 800 --JM 20G --left $1 --right $2 --CPU 6 --genome_guided_sort_buffer 25G
else
        time -p /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/Trinity --seqType fq --trimmomatic --quality_trimming_params 'ILLUMINACLIP:/data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/trinity-plugins/Trimmomatic/adapters/TruSeq2-PE.fa:2:30:10 SLIDINGWINDOW:10:20' --group_pairs_distance 800 --JM 20G --left $1 --right $2 --CPU 6 --genome_guided_sort_buffer 25G
fi

if [ -f "trinity_out_dir/failed_cmds.txt" ]
then
	echo "Some of the butterfly commands failed."
	exit
fi

mv trinity_out_dir/Trinity.fasta $3.trinity.fasta
#rm -r trinity_out_dir/

export PATH=$PATH:/data/pireslab/Asparagales/bin/rsem-1.2.17/

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/util/TrinityStats.pl $3.trinity.fasta > $3_trinity_assembly_stats.txt

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/util/align_and_estimate_abundance.pl --transcripts $3.trinity.fasta --seqType fq --left $1 --right $2 --est_method RSEM --aln_method bowtie --output_dir abundance_estimation --output_prefix $3 --trinity_mode --prep_reference

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/util/misc/count_features_given_MIN_FPKM_threshold.pl abundance_estimation/$3.genes.results > $3_cumultative_gene_counts.txt

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/util/filter_fasta_by_rsem_values.pl --rsem_output abundance_estimation/$3.isoforms.results --fasta $3.trinity.fasta --output $3.trinity.fpkm_filtered.fasta --isopct_cutoff 1.00 

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/util/TrinityStats.pl $3.trinity.fpkm_filtered.fasta > $3_fpkm_assembly_stats.txt

perl /data/pireslab/Asparagales/bin/trinityrnaseq_r20140717/trinity-plugins/transdecoder/TransDecoder -t $3.trinity.fpkm_filtered.fasta


