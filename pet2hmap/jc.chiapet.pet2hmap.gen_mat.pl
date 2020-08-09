#!/usr/bin/env perl
#
# Generate heatmat.txt (heatmap matrix) using pet.info file
#
# Usage: $0 <-i pet.info>
# Outfiles: heatmat.txt
#
# Jianhua Cao @ HZAU
# Last modified: 2016-5-11
# Ver: 0.1
use strict;
use warnings;
# use v5.23.2;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Term::ANSIColor qw(:constants);
$| = 1;

my %chr_max_len = ( # ssc11.1
    '1'  => 274330532,
    '2'  => 151935994,
    '3'  => 132848913,
    '4'  => 130910915,
    '5'  => 104526007,
    '6'  => 170843587,
    '7'  => 121844099,
    '8'  => 138966237,
    '9'  => 139512083,
    '10' => 69359453,
    '11' => 79169978,
    '12' => 61602749,
    '13' => 208334590,
    '14' => 141755446,
    '15' => 140412725,
    '16' => 79944280,
    '17' => 63494081,
    '18' => 55982971,
    'X'  => 125939595,
    'Y'  => 43547828,
    );

my $inf_pet = 'pet.intra.{ctcf|pol2}[.{con|trt}]';
my($chrom, $start_kb, $end_kb, $res_kb) = ('1', 1e-3, 4e5, 1e2);
my($help, $man, $verbose) = (0, 0, 0);
pod2usage("$0: No files given!") if !@ARGV;
GetOptions(
    'i|infpet=s' => \$inf_pet,
    'c|chrom=s'  => \$chrom,
    's|start=f'  => \$start_kb,
    'e|end=f'    => \$end_kb,
    'r|res=i'    => \$res_kb,
    'help|?'     => \$help,
    'man'        => \$man,
    'verbose!'   => \$verbose)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my $desc = join "_", ($chrom, $start_kb, $end_kb, $res_kb);
# $inf_pet =~ /pet\.intra\.(.*)/;
$inf_pet =~ /^pet.*intra.(.*).txt/;
my $ouf_mat = join ".", ('heatmat', $1, $desc);
# my $ouf_mat = 'heatmat.txt';

my($start, $end, $res) = (
    $start_kb * 1e3,
    $end_kb   * 1e3,
    $res_kb   * 1e3,
    );
$end = $chr_max_len{$chrom} if $end > $chr_max_len{$chrom};
my $max = int (($end - $start + 1)/$res);
$end = $start + $max * $res;
print "[INFO] Blocks: $max\n";

my $ref_aoa;
for my $x (0 .. $max - 1) {
    for my $y (0 .. $max - 1) {
        $ref_aoa->[$x][$y] = 1;
        $ref_aoa->[$y][$x] = 1 if $x != $y;
    }
}

my %loop;
open my $fh_pet, "<$inf_pet" or die $!;
while(<$fh_pet>){
    chomp;
    my($id, $chr, $head, $tail, $dist) = (split)[0..2, 6, -1];

    $loop{$id} = {
        'chr'  => $chr,
        'head' => $head,
        'tail' => $tail,
        'dist' => $dist,
    } if ($chr eq $chrom) and ($head > $start) and ($tail < $end);
}
close $fh_pet;
# print Dumper \%loop;

for(keys %loop){
    my $row = int ( ($loop{$_}{'head'} - $start) / $res );
    my $col = int ( ($loop{$_}{'tail'} - $start) / $res );

    $ref_aoa->[$row][$col]++;
    if($row != $col) {
        $ref_aoa->[$col][$row] = $ref_aoa->[$row][$col];
        $ref_aoa->[$row][$row]++;
        $ref_aoa->[$col][$col]++;
    }
}

open my $fh_mat, ">$ouf_mat" or die $!;
for my $x (0 .. $max - 1) {
    for my $y (0 .. $max - 1) {
        if($y == $max - 1){
            print $fh_mat "$ref_aoa->[$x][$y]\n";
        }
        else{
            print $fh_mat "$ref_aoa->[$x][$y]\t";
        }
    }
}
close $fh_mat;


__END__
=head1 NAME

sample - Using xxxx

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
  -help brief help message
  -man  full documentation

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the mamual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut
