#!/usr/bin/perl -w
use strict;

my @meanarray;
open my $file, "<", $ARGV[0];
while(<$file>){
	chomp;
	my @tarray = split /\s+/;
	push (@meanarray, $tarray[2]);
}

my $average;

for my $dat (@meanarray){
	$average += $dat;
}

$average = $average/@meanarray;

my @low;


open $file, "<", $ARGV[0];

while(<$file>){
	chomp;
	my @tarray = split /\s+/;
	if($tarray[2] < $average){
		push (@low, $tarray[2]);
	}
}

my $lowaverage;

for my $dat (@low){
	$lowaverage += $dat;
}

$lowaverage = $lowaverage/@low;

open my $out, ">", $ARGV[0] . ".problemareas.txt";
open $file, "<", $ARGV[0];

while(<$file>){
        chomp;
        my @tarray = split /\s+/;
        if($tarray[2] < $lowaverage/2){
		print $out "$_\n";
	}
}


