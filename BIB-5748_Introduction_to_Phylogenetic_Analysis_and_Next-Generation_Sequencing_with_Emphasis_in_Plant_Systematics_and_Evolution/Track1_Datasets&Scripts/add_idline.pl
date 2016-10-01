#!/usr/bin/perl -w
use strict;

open my $file, "<", $ARGV[0];
open my $out, ">", $ARGV[0] . ".fixedid";

while(<$file>){
	chomp;
	print $out ">$ARGV[0]\n$_\n";
}
