#!/bin/bash
cd `pwd`
# 1= species 2=reads 3=cp genome

blastall -p blastn -i spades_iter2/contigs.fasta -o SppName_cpSPADES.blastn -d ../ReferenceToMap.fsa -m 8 -e 1e-10

perl ../get_blasthitSPADES_seqs.pl SppName SppName_cpSPADES.blastn spades_iter2/contigs.fasta

