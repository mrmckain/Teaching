#!/usr/bin/perl -w
use strict;

open my $file, "<", $ARGV[0];
#This command opens a file.

open my $out, ">", $ARGV[0] . "_" . $ARGV[1] . ".fsa";
#This command creates an outfile (we write to) named the original file plius the length we choose.

my $seqid;
my $seq;
#Initiating variables

while(<$file>){
	chomp;
	if(/^>/){
		if($seq){
			if(length($seq) >= $ARGV[1]){
				print $out "$seqid\n$seq\n";
			}
			$seq = ();
		}
		
		$seqid = $_;
	}

	else{
		$seq .= $_;
	}
}

if($seq){
	if(length($seq) >= $ARGV[1]){
        	print $out "$seqid\n$seq\n";
           
        }
}
