#!/usr/bin/perl -w
use strict;

die "need ONE hostname\n" unless @ARGV == 1;
my $want = $ARGV[0];

my $inv_file = '/etc/ansible/hosts.master';
open(INV, "<", $inv_file) or die "can't read file: $!";

my @stuff = <INV>;
die "$want NOT a valid hostname" unless grep /$want/, @stuff;

my $i = 0;
my $pos;
my %seen;
for my $line (@stuff) {
    $i++;
	if ($line =~ /$want/) {
		$pos = $i;
		do { --$i } until $stuff[$i] =~ /^\[/;
		$seen{ $stuff[$i] }++;
		$i = $pos;
	}
}
print "$_" for keys %seen;


