#!/usr/bin/perl -w
use strict;
use Smart::Comments;
use List::Util qw/sum/;

my $Dir = $ARGV[0]; ###path of detected site lists of all samples for each method
my $input1 = $ARGV[1]; ###list of REDItools detected sites 
my $input2 = $ARGV[2]; ###list of RED-ML detected sites 
my $input3 = $ARGV[3]; ###list of SPRINT detected sites 
my $sample = $ARGV[4]; ###list of samples
my $output = $ARGV[5]; 

my @samplelist = get_sampleid($sample);
my %sites = get_editing_level($Dir);

my %hash=();
open IN1,'<',$input1;
while(<IN1>){
    chomp $_;
    my ($chr,$start,$end,$strand) = (split /\t/,$_)[0,1,2,5];
    my $key = join "\t",$chr,$start,$end,$strand;
    push @{$hash{$key}{'method'}},'REDItools';
}

open IN2,'<',$input2;
while(<IN2>){
    chomp $_;
    my ($chr,$start,$end,$strand) = (split /\t/,$_)[0,1,2,5];
    my $key = join "\t",$chr,$start,$end,$strand;
    push @{$hash{$key}{'method'}},'RED-ML';
}

open IN3,'<',$input3;
while(<IN3>){
    chomp $_;
    my ($chr,$start,$end,$strand) = (split /\t/,$_)[0,1,2,5];
    my $key = join "\t",$chr,$start,$end,$strand;
    push @{$hash{$key}{'method'}},'SPRINT';
}


open OUT,'>',$output || die "can't open $output";
print OUT "Chr\tStart\tEnd\tStrand\tMethods\tMethod_num\t";
print OUT join "\t",@samplelist; 
print OUT "\n";

for my $keys(sort keys %hash){
	my $num = @{$hash{$keys}{'method'}};
	my $method = join ",",@{$hash{$keys}{'method'}};
    print OUT "$keys\t$method\t$num\t";
	for my $sampleid(@samplelist){
		if(exists $sites{$keys}{$sampleid}){
            my $size = @{$sites{$keys}{$sampleid}};
            my $aver_edit = sum(@{$sites{$keys}{$sampleid}})/$size;
            print OUT "$aver_edit\t";
		}else{
			print OUT "0\t";
		}
	}
	print OUT "\n";
}

sub get_sampleid{
	my $file = shift;
	my @sample=();
	open IN,$file;
	while(<IN>){
		chomp;
		my $sample_id=(split /\t/,$_)[0];
		push @sample,$sample_id;
	}
return @sample;
close IN;
}

sub get_editing_level{
    my $dir = shift;
    my @files1 = glob ("$dir/*reditools.bed");
    my @files2 = glob ("$dir/*redml.bed");
    my @files3 = glob ("$dir/*sprint.bed");
    my %sites = ();
    for my $eachfile1(@files1){
        my $id = '';
        open IN1,'<',$eachfile1;
        ($id) = $eachfile1 =~ /$dir\/(.*?).reditools/;
        while(<IN1>){
            chomp $_;
            my ($chr,$start,$end,$editing_level,$strand) = (split /\t/,$_)[0,1,2,4,5];
            my $key = join "\t",$chr,$start,$end,$strand;
            push @{$sites{$key}{$id}},$editing_level;
        }
    }
    for my $eachfile2(@files2){
        my $id = '';
        open IN2,'<',$eachfile2;
        ($id) = $eachfile2 =~ /$dir\/(.*?).redml/;
		my $method = 'RED-ML';
        while(<IN2>){
            chomp $_;
            my ($chr,$start,$end,$editing_level,$strand) = (split /\t/,$_)[0,1,2,4,5];
            my $key = join "\t",$chr,$start,$end,$strand;
            push @{$sites{$key}{$id}},$editing_level;
        }
		
    }
    for my $eachfile3(@files3){
        my $id = '';
        open IN3,'<',$eachfile3;
        ($id) = $eachfile3 =~ /$dir\/(.*?).sprint/;
        while(<IN3>){
            chomp $_;   
            my ($chr,$start,$end,$editing_level,$strand) = (split /\t/,$_)[0,1,2,4,5];
            my $key = join "\t",$chr,$start,$end,$strand;
            push @{$sites{$key}{$id}},$editing_level;
        }
    }
    return %sites;
}


