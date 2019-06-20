#!/usr/bin/perl -w
use strict;
$|++;

my $host; 
my @rhel7 = qw (phldv2lxapnap05 phldv2lxapnwb05 phldvlxapig001 phlprlxapig027);

for my $host (@rhel7) {
	my $cmd = `ansible $host -b -m shell -a '/usr/bin/subscription-manager identity | grep environment | awk "{print \\\$3}"'`;
	if ($cmd =~ /All-Prod/) {
		print "$host: prod\n";
    } elsif ($cmd =~ /Non-Prod/) {
		print "$host: nonprod\n"
    } else {
        print "wtf is $host\n"
    }
}

