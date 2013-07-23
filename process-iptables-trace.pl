#!/usr/bin/perl -w
use strict;

$SIG{INT} = sub { `stty echo`; exit 0; };

my @colors = ("\e[0;32m",
              "\e[0;33m",
              "\e[0;36m");
my $cur_color = -1;
my $last_table;
my $last_line;

if ( scalar @ARGV ) {
    while (<>) {
        &process;
    }
} else {
    `stty -echo`;
    while (<STDIN>) {
        &process;
    }
    `stty echo`;
}

sub process {
    (my $cur_table = $_) =~ s/^.*TRACE: (.+?):.*$/$1/;
    if ($cur_table ne $last_table) {
        $cur_color = (++$cur_color)%(scalar @colors);
        $last_table = $cur_table
    }
    
    if (/PREROUTING/ && $last_line =~ /POSTROUTING/ ) {
        $cur_color = 0;
        $_ = sprintf("\e[0;34m%s\n%s\e[0;35m\n%s", '-'x80,'-'x80, $_);
    }
    s/\bTRACE: (.+?) /TRACE: $colors[$cur_color]$1\e[0;35m /g;
    s/(\bTTL=[0-9]+) /\e[0;36m$1\e[0;35m /g;
    s/(\bIN=.*?) /\e[0;31m$1\e[0;35m /g;
    s/(\bOUT=.*?) /\e[0;37m$1\e[0;35m /g;
    s/(\bSRC=.*?) /\e[0;32m$1\e[0;35m /g;
    s/(\bDST=.*?) /\e[0;33m$1\e[0;35m /g;
    s/(\bMARK=.*?) /\e[0;31m$1\e[0;35m /g;
    print "\e[0;35m";
    print;
    print "\e[0m";
    $last_line = $_;
}
