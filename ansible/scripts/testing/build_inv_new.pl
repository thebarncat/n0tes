#!/usr/bin/perl -w
use strict;
$|++;

# read lock make sure file not open

my $log = '/etc/ansible/log/inv_err_log';
open STDERR, ">$log" or die $!;

my $inv_file = '/etc/ansible/hosts.master';
open(INV, ">>", $inv_file) or die "can't create/append file: $!";

#empty file first
truncate(INV, 0);

# genral vars
my $phl_dmz_subs="10\.7\.0|10\.7\.1|10\.7\.40";
my $rdg_dmz_subs="10\.5\.112";
#my $prod_subs="10\.45\.4|10\.45\.5|10\.7\.1|10\.7\.0|10\.45\.12|10\.5\.82|10\.5\.112";

print "Building master hosts file..\n";

my $header = "[control]\nphlprlxjmp001 ansible_connection=local\n\n";
print INV $header;

print INV "[LINUX-SAND]\n";
my @sand = `hostlist | grep sand`;
print INV @sand, "\n";

print INV "[PHL-NONPRD]\n";
my @phl_non_prd = `hostlist -o linux -l phl -e nonprod`;
print INV @phl_non_prd, "\n";

print INV "[PHL-PRD]\n";
my @phl_prd = `hostlist -o linux -l phl -e prod`;
print INV @phl_prd, "\n";

print INV "[PHL-DMZNONPRD]\n";
my @phl_non_prd_dmz;
for my $host (@phl_non_prd) {
    my $ip = (split(/\s+/, `host $host`))[3];
    next unless $ip =~ /$phl_dmz_subs/;
	push @phl_non_prd_dmz,$host;
}
print INV @phl_non_prd_dmz, "\n";

print INV "[PHL-DMZPRD]\n";
my @phl_prd_dmz;
for my $host (@phl_prd) {
    my $ip = (split(/\s+/, `host $host`))[3];
    next unless $ip =~ /$phl_dmz_subs/;
	push @phl_prd_dmz,$host;
}
print INV @phl_prd_dmz, "\n";

print INV "[RDG-PRD]\n";
my @rdg_prd = `hostlist -o linux -l rdg -e prod`;
print INV @rdg_prd, "\n";

print INV "[RDG-NONPRD]\n";
my @rdg_non_prd = `hostlist -o linux -l rdg -e nonprod`;
print INV @rdg_non_prd, "\n";

print INV "[RDG-DMZPRD]\n";
my @rdg_prd_dmz;
for my $host (@rdg_prd) {
    my $ip = (split(/\s+/, `host $host`))[3];
    next unless $ip =~ /$rdg_dmz_subs/;
	push @rdg_prd_dmz,$host;
}
print INV @rdg_prd_dmz, "\n";

# all PHL
print INV "[PHL]\n";
my @phl = `hostlist -o linux -l phl`;
print INV @phl,"\n";

# all RDG
print INV "[RDG]\n";
my @rdg = `hostlist -o linux -l rdg`;
print INV @rdg,"\n";

# oracle
print INV "[ORACLE]\n";
my @oracle = `hostlist -o linux -g oracle`;
print INV @oracle,"\n";

# sybase
print INV "[SYBASE]\n";
my @sybase = `hostlist -o linux -g sybase`;
print INV @sybase,"\n";

# close for now then re open
close INV;

sleep 2;

# ** By OS_LEVEL **  
#my $cmd = 'ansible all -m setup -a "filter=ansible_distribution_version" -i /etc/ansible/hosts_files/all_linux';
my $cmd = 'ansible all -m setup -a "filter=ansible_distribution_version"';
open(P, "$cmd|") or die "can't pipe: $!";

my $host; my @rhel7; my @rhel6;
while (my $line = <P>) {
    chomp $line;
    ($host) = (split(/\s+/,$line))[0] if $line =~ /SUCCESS/;
    if ( $line =~ /7\./ ) {
        push @rhel7, "$host\n";
    } elsif ( $line =~ /6\./ ) {
        push @rhel6, "$host\n";
    }
}

# re open file
open(INV, ">>", $inv_file) or die "can't create/append file: $!";

my @rhel7_prod; my @rhel7_non_prod;
for my $host (@rhel7) {
	chomp $host;
	my $cmd = `ansible $host -b -m shell -a '/usr/bin/subscription-manager identity | grep environment | awk "{print \\\$3}"'`;
    if ($cmd =~ /All-Prod/) {
    	push @rhel7_prod,"$host\n";
	} elsif ( $cmd =~ /Non-Prod/ ) { 
    	push @rhel7_non_prod,"$host\n";
	} else {
		print "wtf is $host\n" 
	}
}

print INV "[RHEL7-PRD]\n";
print INV @rhel7_prod,"\n";
print INV "[RHEL7-NONPRD]\n";
print INV @rhel7_non_prod,"\n";

my @rhel6_prod; my @rhel6_non_prod;
for my $host (@rhel6) {
	chomp $host;
	my $cmd = `ansible $host -b -m shell -a '/usr/bin/subscription-manager identity | grep environment | awk "{print \\\$3}"'`;
    if ($cmd =~ /All-Prod/) {
    	push @rhel6_prod,"$host\n";
	} elsif ( $cmd =~ /Non-Prod/ ) {
    	push @rhel6_non_prod,"$host\n";
	} else {
	    print "wtf is $host\n"
    }
}

print INV "[RHEL6-PRD]\n";
print INV @rhel6_prod,"\n";
print INV "[RHEL6-NONPRD]\n";
print INV @rhel6_non_prod,"\n";

print "Done building master hosts file\n\n";
close INV;


