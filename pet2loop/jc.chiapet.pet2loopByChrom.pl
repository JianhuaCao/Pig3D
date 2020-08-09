#!/usr/bin/env perl
#
# Generate loop file (txt) using pet file.
# Note: Singleton also included
# 
# Usage: $0 -p <pet.intxx.xxx> [-e 500]
# Option: -e INT, anchor extension (bp), default=500
# Outfiles: loop.xxx.xxx -> cluster file (12 columns)
#
# Jianhua Cao @ HZAU
# Last modified: 2016-8-29
# Ver: 0.7
use strict;
use warnings;
# use v5.23.2;
use Data::Dumper;
use Getopt::Long qw(GetOptions);
use Pod::Usage qw(pod2usage);
use Term::ANSIColor qw(:constants);
$| = 1;

my($inf_pet, $ext) = ('X_Y', 500);

my($help, $man, $verbose) = (0, 0, 0);
pod2usage("$0: No files given!") if !@ARGV;
GetOptions(
	'p|petfile=s' => \$inf_pet,
	'e|ext=i'     => \$ext,
	'help|?'      => \$help,
	'man'         => \$man,
	'verbose!'    => \$verbose)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my $ouf_loop = 'loop.' . $inf_pet;

my %loop;
my @id;
open my $fh_pet, "<$inf_pet" or die $!;
while(<$fh_pet>){
	chomp;
	my($id, @pos) = (split)[0..6];
	$loop{$id} = {
		'left_chr'   => $pos[0],
		'left_head'  => $pos[1],
		'left_tail'  => $pos[2] + $ext,
		'right_chr'  => $pos[3],
		'right_head' => $pos[4],
		'right_tail' => $pos[5] + $ext,
	};
}
close $fh_pet;
push @id, $_ for keys %loop;

open my $fh_loop, ">$ouf_loop" or die $!;
# open my $fh_sig, ">$ouf_sig" or die $!;
&gen_cluster(\@id);
close $fh_loop;
# close $fh_sig;


sub gen_cluster{ #generate cluster hash from an id array reference
	my $aref = shift; #array ref of all cluster's ids

	my $left  = &sort_head('left',  $aref);
	
	for(keys %$left){
		next if /^_/;
		my $right = &sort_head('right', $left->{$_});

		if($right->{'_num_cls'} > 1){
			for my $k (keys %$right){
				next if $k =~ /^_/;
				&gen_cluster($right->{$k});
			}
		}
		else{
			&save_cluster(&make_cluster($right));
		}
	}
}

sub sort_head { #f: left/right, aref: ref to id array of a cluster
	my($f, $aref) = @_;

	my %cluster;
	my($p, $cid) = (0, ''); #p: point to the end; cid: cluster id
	
	for ( sort { $loop{$a}{$f.'_head'} <=> $loop{$b}{$f.'_head'} } @$aref ){
		my $end = $loop{$_}{$f.'_tail'};
		if($loop{$_}{$f.'_head'} > $p){
			$cid = $_;
			$p = $end;
		}
		else{
			$p = $end if $end > $p;
		}
		push @{ $cluster{$cid} }, $_;
	}

	my $num_ids = 0;
	my @mem_ids;
	for(keys %cluster){
		# if(@{$cluster{$_}} == 1){
		# 	print $fh_sig "$_\n";
		# 	delete $cluster{$_};
		# }
		# else{
		# 	$num_ids += @{$cluster{$_}};
		# 	push @mem_ids, @{$cluster{$_}};
		# }
		$num_ids += @{$cluster{$_}};
		push @mem_ids, @{$cluster{$_}};
	}
	$cluster{'_num_cls'} = keys %cluster;
	$cluster{'_num_ids'} = $num_ids;
	$cluster{'_mem_ids'} = [ @mem_ids ];

	return \%cluster;
}

sub make_cluster{
	my $href = shift;

	my %cluster;
	for(keys %$href){
		next if /^_/;

		my $left_chr  = $loop{$_}{'left_chr'};
		my $right_chr = $loop{$_}{'right_chr'};
		my @members = @{ $href->{$_} };

		my $left_head =
				$loop{
					(sort {$loop{$a}{'left_head'} <=> $loop{$b}{'left_head'}} @members)[0]
				}{'left_head'};

		my $left_tail =
				$loop{
					(sort {$loop{$b}{'left_tail'} <=> $loop{$a}{'left_tail'}} @members)[0]
				}{'left_tail'} - $ext;

		my $right_head =
				$loop{
					(sort {$loop{$a}{'right_head'} <=> $loop{$b}{'right_head'}} @members)[0]
				}{'right_head'};

		my $right_tail =
				$loop{
					(sort {$loop{$b}{'right_tail'} <=> $loop{$a}{'right_tail'}} @members)[0]
				}{'right_tail'} - $ext;

		my $intv = $right_head - $left_tail - 1;

		$cluster{$_} = {
			'left_chr'   => $left_chr,
			'left_head'  => $left_head,
			'left_tail'  => $left_tail,
			'right_chr'  => $right_chr,
			'right_head' => $right_head,
			'right_tail' => $right_tail,
			'left_len'   => $left_tail  - $left_head  + 1,
			'right_len'  => $right_tail - $right_head + 1,
			'interval'   => $intv < 0 ? 0 : $intv,
			'member_num' => scalar @members,
			'member_id'  => join "|", @members,
		};
	}

	return \%cluster;
}

sub save_cluster {
	my $href = shift;

	for(keys %$href){
		print $fh_loop join "\t", ($_,
			$href->{$_}{'left_chr'},   $href->{$_}{'left_head'},  $href->{$_}{'left_tail'},
			$href->{$_}{'right_chr'},  $href->{$_}{'right_head'}, $href->{$_}{'right_tail'},
			$href->{$_}{'left_len'},   $href->{$_}{'right_len'},  $href->{$_}{'interval'},
			$href->{$_}{'member_num'}, "$href->{$_}{'member_id'}\n");
	}
}


__END__
=head1 NAME

sample - Using xxxx

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
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
