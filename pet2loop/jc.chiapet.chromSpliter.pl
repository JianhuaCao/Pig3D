#!/usr/bin/env perl
#
# ChromSpliter: Split infile into chr.-based files
# in ./tmpdir as 1_1, 2_2 ...
#
# Note:
# (1) Infile column specification: (col2 = chr1, col5 = chr2)
#       ID chr1 start1 end1 chr2 start2 end2 ...
# (2) Output: tmpdir, infile.chr (mandatory)
#
# Usage: $0 -i <infile>
# Infile: infile
# Oufile: tmpdir/1_1, 2_2 ...
#
# Jianhua Cao @ HZAU
# Last modified: 2018-4-18
# Ver: 0.3
use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Data::Dumper;
use Term::ANSIColor qw(:constants);
$| = 1;

my $infile = 'infile.txt'; # e.g.: pet.intxx.xxx, cls.intra.xxx

my($help, $man, $verbose) = (0, 0, 0);
pod2usage("$0: No files given!") if !@ARGV;
GetOptions(
	'i|infile=s' => \$infile,
	'help|?'     => \$help,
	'man'        => \$man,
	'verbose!'   => \$verbose)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my $tmp_dir = $infile . '.chr';
mkdir $tmp_dir;

my $t_start = time;

### Split pet info file based on Chr1_vs_Chr2.
my $t_start_split = time;
my($tot_records, $files_ref) = &split_infile($infile);
my $tot_files = scalar @$files_ref;

print join "", (
	"[INFO] Tot. Records: $tot_records Files: $tot_files ",
	'.'x20, ' OK! (', int((time - $t_start)/60), "m)\n",
	);


sub split_infile {
	my $pet = shift;

	my $files;
	my $count_pet = 0;

	open my $fh_pet, "<$pet" or die $!;
	while(<$fh_pet>){
  	$count_pet++;

		my $outfile = join "_", (split /\t/)[1, 4]; # chr1_chr2
		$outfile = ($outfile =~ /^[1-9MXY]/) ? $outfile : 'SCF_SCF';

		if(!exists $files->{$outfile}){
			open my $fh_out, ">./$tmp_dir/$outfile" or die $!;
			$files->{$outfile} = $fh_out;
		}
		print { $files->{$outfile} } $_;
	}
	close $fh_pet;
	close $files->{$_} for keys %{ $files };

	my @files = glob("./$tmp_dir/*");

	return ($count_pet, \@files);
}


__END__
=head1 NAME

Split infile into chromosome pieces like 1_1, 2_2 ...

=head1 SYNOPSIS

 $0 -i infile

 Options:
  -inf	infile (col2=chr1, col5=chr2)
  -help	brief help message
  -man	full documentation

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
