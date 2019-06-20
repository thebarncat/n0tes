#!/usr/bin/perl -w
use strict;

#die "need host class\n" unless @ARGV == 1;

my $cmd;
# show ansible help if no args supplied
unless($ARGV[0]) {
	$cmd = "/usr/bin/ansible --list-hosts";
	system($cmd) ==0  or die "$?";
}

$cmd = "/usr/bin/ansible --list-hosts \"$ARGV[0]\"";
my $out = `$cmd`;

$out =~ s/\s+hosts\s+\(.*\n//g;
$out =~ s/^\s+//mg;
print $out;

