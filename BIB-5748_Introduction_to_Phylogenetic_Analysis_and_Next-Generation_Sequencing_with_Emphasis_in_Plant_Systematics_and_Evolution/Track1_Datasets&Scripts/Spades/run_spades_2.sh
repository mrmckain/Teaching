#!/bin/bash
cd `pwd`

#USAGE: 1=directory1 2=reads 3=directory2

time python /data/kellogg/bin/SPAdes-3.0.0-Linux/bin/spades.py -o spades_iter1 -s $1 --only-assembler -k 55,77,89 -t 4
time python /data/kellogg/bin/SPAdes-3.0.0-Linux/bin/spades.py -o spades_iter2 -s $1 --trusted-contigs spades_iter1/contigs.fasta --only-assembler -k 55,77,89 -t 4

