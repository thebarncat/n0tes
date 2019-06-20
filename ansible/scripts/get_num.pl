#!/usr/bin/perl -w
use strict;

my $inv_file = '/etc/ansible/hosts.master';
open(INV, "<", $inv_file) or die "can't read file: $!";

my @stuff = <INV>;
my @nums = map { $_} 0 .. $#stuff;
print scalar @nums,"\n";


my $i = 0;
for my $line (@stuff) {
    $i++;
    print $i-1, "-> $stuff[$i-1]";
	last if $i == 10;
}

