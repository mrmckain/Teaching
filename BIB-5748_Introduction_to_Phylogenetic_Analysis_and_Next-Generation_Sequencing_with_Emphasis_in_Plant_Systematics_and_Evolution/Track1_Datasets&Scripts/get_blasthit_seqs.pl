#!/usr/bin/perl -w 
use strict;

open my $outfile, ">", $ARGV[0] . ".cphit_seqs.fsa";

my %goodhits;
open my $blastfile, "<", $ARGV[1];
while(<$blastfile>){
	chomp;
	my @fields = split /\s+/;
	$goodhits{$fields[0]}=1;
}

my $seqid;
open my $file, "<", $ARGV[2];
while(<$file>){
	chomp;
	if(/^>/){
		my $tid = substr($_, 1);
		if(exists $goodhits{$tid}){
			$seqid=$tid;
			print $outfile "$_\n";
		}
		else{
			$seqid=();
		}
	}
	elsif($seqid){
		print $outfile "$_\n";
	}
}
