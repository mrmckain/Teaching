#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;

my $usage = '--left FASTQ-1 --right FASTQ-2 --single FASTQ --min MinimumScore --median MedianScore --max MaxNs --consecutive NumberofConBasesScoreLessthanMin --length MinLength --window WindowSize';

my ($left, $right, $single);
my $min = 20;
my $med = 22;
my $max = 3;
my $con = 3;
my $len = 40;
my $win = 1;
GetOptions ("left=s" => \$left,
               "right=s" => \$right,
	   "single=s" => \$single,
           "min=i" => \$min,
           "median=i" => \$med,
           "max=i" => \$max,
           "consecutive=i" => \$con,
           "length=i" => \$len, 
           "window=i" => \$win);

#if(scalar @ARGV < 2){
#	print "Usage:\n$usage\n" and die "Provide input files.";
#}

my %scores64= (
	"i" => "41", "h" => "40", "g" => "39", "f" => "38", "e" => "37", "d" => "36", "c" => "35", "b" => "34", "a" => "33", "`" => "32", "_" => "31", "^" => "30", 
	"]" => "29", "\\" => "28", "[" => "27", "Z" => "26", "Y" => "25", "X" => "24", "W" => "23", "V" => "22", "U" => "21", "T" => "20", "S" => "19",
	"R" => "18", "Q" => "17", "P" => "16", "O" => "15", "N" => "14", "M" => "13", "L" => "12", "K" => "11", "J" => "10", "I" => "9", "H" => "8", 
	"G" => "7", "F" => "6", "E" => "5", "D" => "4", "C" => "3", "B" => "2", "A" => "1", "@" => "0", "?" => "-1", ">" => "-2", "=" => "-3", "<" => "-4",
	";" => "-5");

my %scores33= (
	"J" => "41", "I" => "40", "H" => "39", "G" => "38", "F" => "37", "E" => "36", "D" => "35", "C" => "34", "B" => "33", "A" => "32", "@" => "31", 
	"?" => "30", ">" => "29", "=" => "28", "<" => "27", ";" => "26", ":" => "25", "9" => "24", "8" => "23", "7" => "22", "6" => "21", "5" => "20", "4" => "19",
	"3" => "18", "2" => "17", "1" => "16", "0" => "15", "\/" => "14", "." => "13", "-" => "12", "," => "11", "+" => "10", "*" => "9", ")" => "8", "(" => "7",
	"\'" => "6", "&" => "5", "%" => "4", "\$" => "3", "#" => "2", "\"" => "1", "!" => "0"); 
my $scoreref = \%scores33;
if($left && $right){
	detscorescheme($left);
	fastqfilter($left);
	fastqfilter($right);
}
elsif($single){
	detscorescheme($single);
        fastqfilter($single);
}

##########################################################################################
sub detscorescheme{
	open my $infile, "<", $_[0] or die "Cannot open $_[0] for determining score";
	my $count=0;
	while(<$infile>){
		chomp;
		if($count == 4){
                        $count=0;
                }
                $count++;

                if($count == 4){
			if(/[ijgfedcba`_^\]\\\[ZYXWVUTSRQPONMLK]/){
				$scoreref = \%scores64;
			}
		}
	}
}			

##########################################################################################
sub fastqfilter{
	open my $infile, "<", $_[0] or die "Cannot open $_[0] for reading";
	open my $outfile, ">", "$_[0].cleaned.fq";
	my ($seqid, $seq, $seqscore);
	my $count=0;
	while(<$infile>){
		chomp;
		if($count == 4){
			$count=0;
		}
		$count++;
		if($count == 1){
			$seqid = $_;
		}
		
		if($count == 2){
			$seq = $_;
		}
		
		if($count == 4){
		#	print "$_\n";
			my @scoren = split("", $_);
		#	print "@scoren\n";
			my @phscoren;
			my $origscore = $_;
			for my $score (@scoren){
			 	push(@phscoren, $scoreref->{$score});
			 }
			my ($start, $end)= qw(-1 -1);
			my $i =0;
			until($start >= 0){
				my @window;
				my $j=$i;
				while($j <= ($i+$win-1)){
					push(@window, $phscoren[$j]);
					$j++;
			#		print "$j\n";
				}
				my $winscore = &mean(@window);
			#	print "Winscore: $winscore\n";
				if($winscore >= $min){
                                	$start = $i;
				}
				if($i == scalar(@phscoren)-1){
					$start=scalar(@phscoren)+1;
					$seq=();
				}
				$i++;
			}
=item			
			for(my $i=0; $start; $i++){
				my @window;
				print "$i\n";
				for(my $j=$i; $j <= $j+$win-1; $j++){
					push(@window, $phscoren[$j]);
					print "@window\n";
				}
				print "window is @window\n";
				my $winscore = &mean(@window);
				if($winscore >= $min){
					$start = $i;
					last;
				}
			}
=cut
			my @revphscoren = reverse(@phscoren);
			$i =0;
                        until($end >= 0){
                                my @window;
                                my $j=$i;
                                while($j <= ($i+$win-1)){
                                        push(@window, $revphscoren[$j]);
                                        $j++;
                         #               print "$j\n";
                                }
                                my $winscore = &mean(@window);
                                if($winscore >= $min){
                                        $end = scalar(@revphscoren-$i-1);
                                }
				if($i == scalar(@revphscoren)-1){
                                        $end=scalar(@phscoren)+1;;
                                        $seq=();
				#	print "ENDED\n";
                                }

                                $i++;
                        }
=item
			for(my $i=0; $i < @revphscoren; $i++){
				my @window;
				for(my $j=$i; $j <= $j+$win-1; $j++){
					push(@window, $revphscoren[$j]);
				}
				my $winscore = &mean(@window);
				if($winscore >= $min){
					
					$end = scalar(@revphscoren-$i-1);
					last;
				}
			}
=cut
			if($seq){
				$seq = substr($seq, $start, $end-$start+1);
				if(length($seq) >= $len){
					my $countN = () = $seq =~ /N/g;
					#print "There are $countN N's\n";
					unless($countN <= $max){
						$seq=();
					}
				}
				else{
					$seq=();
				}
			}
			if($seq){
				my $median = &median(@phscoren);
				if($median < $med){
					$seq=();
				}
			}
			
			if($seq){
				$seqscore = substr($origscore, $start, $end-$start+1);
			}
			if($seqid && $seq && $seqscore){
				print $outfile "$seqid\n$seq\n\+\n$seqscore\n";
			}
		}
	}
	#close IN;
	#close OUT;
}	
		

##########################################################################################
sub median {
    my @array = sort {$a <=> $b} @_;
    my $median;
    if ($#array % 2 == 0) {
        $median = $array[($#array / 2)];
    }else {
        $median = $array[int($#array / 2)] + (($array[int($#array / 2) + 1] - $array[int($#array / 2)]) / 2);
    }
	return($median);
}
##########################################################################################
sub mean {
	my @array = @_;
    my $sum = 0;
    my $total = $#array + 1;
    for my $element (@array) {
        $sum += $element;
    }
    my $mean = $sum/$total;
    return($mean);
}
