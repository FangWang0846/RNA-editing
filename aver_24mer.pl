#!/usr/bin/perl -w
use strict;
use Smart::Comments;
use List::Util qw/sum/;

my $input=$ARGV[0];
my $output=$ARGV[1];

my %hash = ();

open IN,$input;

while(<IN>){
	chomp;
	my ($chr,$s1,$e1,$strand,$s2,$e2,$score) = (split /\t/,$_)[0,1,2,5,7,8,10];
    my $key = join "\t",$chr,$s1,$e1,$strand;
	$hash{$key} = [] unless exists $hash{$key};
	my $value = ();
    if($s2<=$s1 && $e2<=$e1){
        $value = ($e2-$s1)*$score;
	}elsif($s2>$s1 && $e2<=$e1){
		$value = ($e2-$s2)*$score;
	}elsif($s2>$s1 && $e2>$e1){
		$value = ($e1-$s2)*$score;
	}elsif($s2<=$s1 && $e2>$e1){
        $value = ($e1-$s1)*$score;
    }
    else{next;}
	push @{$hash{$key}},$value;
}

close IN;

open OUT,'>',$output;
for my $info (sort keys %hash){
	my @values = @{$hash{$info}};
	printf OUT "$info\t";
	my $aver = (sum @values)/300;
	printf OUT $aver;
	printf OUT "\n";
}


