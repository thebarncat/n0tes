#!/usr/bin/perl -w
use strict;
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

print "Building master hosts file..\n";

my $header = "[control]\nphlprlxjmp001 ansible_connection=local\n\n";
print INV $header;

print INV "[LINUX-SAND]\n";
my @sand = `hostlist | grep sand`;
print INV @sand, "\n";

print INV "[ALL-PRD]\n";
my @all_prd = `hostlist -o linux -e prod`;
print INV @all_prd, "\n";

print INV "[ALL-NONPRD]\n";
my @all_non_prd = `hostlist -o linux -e nonprod`;
print INV @all_non_prd, "\n";

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

# mongodb
print INV "[MONGODB]\n";
my @mongodb = `hostlist -o linux -g mongodb`;
print INV @mongodb,"\n";

# sybase
print INV "[SYBASE]\n";
my @sybase = `hostlist -o linux -g sybase`;
print INV @sybase,"\n";

# physical servers
print INV "[PHYSICAL]\n";
my @physical = `hostlist -o linux -t physical`;
print INV @physical,"\n";

# ALL ( different file ) 
print "Building ALL hosts file..\n";
my $all_host = '/etc/ansible/inventory/all_linux';
open(ALL, ">>", $all_host) or die "can't create/append file: $!";

#empty file first
truncate(ALL, 0);

my @all = `hostlist -o linux`;
print ALL @all;
close ALL;
print "Done building ALL hosts file\n";
print "There are: ", scalar @all,"\n";

sleep 2;

# ** By OS_LEVEL ** ( back to master file) 
my $cmd = 'ansible all -m setup -a "filter=ansible_distribution_version" -i /etc/ansible/inventory/all_linux';
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

print INV "[RHEL7]\n";
print INV @rhel7,"\n";
print INV "[RHEL6]\n";
print INV @rhel6,"\n";

print "Done building master hosts file\n\n";
close INV;

