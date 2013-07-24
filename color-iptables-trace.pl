#!/usr/bin/perl -w

use strict;
use Getopt::Long;

$SIG{INT} = sub {system('stty echo'); exit 0;};

my $c = { 'red'     => "\e[0;31m", 'bold_red'     => "\e[1;31m",
          'green'   => "\e[0;32m", 'bold_green'   => "\e[1;32m",
          'yellow'  => "\e[0;33m", 'bold_yellow'  => "\e[1;33m",
          'blue'    => "\e[0;34m", 'bold_blue'    => "\e[1;34m",
          'purple'  => "\e[0;35m", 'bold_purple'  => "\e[1;35m",
          'cyan'    => "\e[0;36m", 'bold_cyan'    => "\e[1;36m",
          'white'   => "\e[0;37m", 'bold_white'   => "\e[1;37m",
          'reset'   => "\e[0m" };
my $default_color = $c->{'purple'};

my $fields = { 'TTL'  => $c->{'cyan'},
               'IN'   => $c->{'red'},
               'OUT'  => $c->{'white'},
               'SRC'  => $c->{'green'},
               'DST'  => $c->{'yellow'},
               'MARK' => $c->{'bold_red'},
             };

my @table_colors = ( $c->{'bold_green'},
                     $c->{'bold_yellow'},
                     $c->{'bold_cyan'} );
my $cur_color = -1;
my $last_table = '';
my $last_line = '';
my $awful_str = sprintf("%sc%so%sl%so%sr%si%sz%se%sr%s",
                        $c->{'bold_red'},
                        $c->{'bold_green'},
                        $c->{'bold_yellow'},
                        $c->{'bold_blue'},
                        $c->{'bold_purple'},
                        $c->{'bold_cyan'},
                        $c->{'bold_red'},
                        $c->{'bold_green'},
                        $c->{'bold_yellow'},
                        $c->{'reset'});

GetOptions('help|?' => sub { print <<HELPSTR
iptables TRACE target log $awful_str

Usage: $0 trace.out | less -R
       cat trace.out | $0 | less -R
       $0

    If no file specified, run '$0' and paste the contents of the TRACE file to
    the terminal. ctrl-c to exit.
HELPSTR
    ;exit 0}
);

if ( scalar @ARGV ) {
    while (<>) {
        &process($_);
    }
} else {
    system('stty -echo');
    while (<STDIN>) {
        &process($_);
    }
    system('stty echo');
}

sub process {
    my ($cur_line) = @_;
    (my $cur_table = $cur_line) =~ s/^.*TRACE: (.+?):.*$/$1/;
    if ($cur_table ne $last_table) {
        $cur_color = (++$cur_color)%(scalar @table_colors);
        $last_table = $cur_table
    }
    if ($cur_line =~ /PREROUTING/ && $last_line =~ /POSTROUTING/ ) {
        $cur_color = 0;
        $cur_line = $c->{'blue'}.'-'x80 ."\n".'-'x80 ."\n".$default_color.$cur_line;
    }
    for my $field (keys %$fields) {
        $cur_line =~ s/(\b$field=.*?) /$fields->{$field}$1$default_color /g;
    }
    $cur_line =~ s/\bTRACE: (.+?) /TRACE: $table_colors[$cur_color]$1\e[0;35m /g;
    print $default_color;
    print $cur_line;
    print $c->{'reset'};
    $last_line = $cur_line;
}
