#!/usr/bin/perl -w

use strict;
use File::Copy;
use Getopt::Long;

my $buffer_size = 1024;
my $max_log_count = 5;
my $output_dir = '.';
my $output_name = 'rotate.pl.out';
my $rotate_size = 5*1024*1024;
my $VERBOSE = 0;

GetOptions( 'buf=i'       => \$buffer_size,
            'count=i'     => \$max_log_count,
            'dir=s'       => \$output_dir,
            'logfile=s'   => \$output_name,
            'size=i'      => \$rotate_size,
            'verbose'     => \$VERBOSE,
            'help|?'      => sub { print <<USAGE
Automatically rotate your logs after they grow beyond a specified size
Usage:
    $0
        -b --buf [buffer size]      Read buffer size (bytes)
                                    Default: $buffer_size
        -c --count [log count]      Max number of logs to keep
                                    Default: $max_log_count
        -d --dir [log dir]          Directory to store logs in
                                    Default: $output_dir
        -l --logfile [log name]     Name of log to write to
                                    Default: $output_name
        -s --size [max log size]    Maximum log size before rotating (bytes)
                                    Default: $rotate_size
        -v --verbose                Be annoying
        -? --help                   Print this usage info
    
    ex:  yes | $0 -c 5 -d /tmp -l logname -s 1048576
USAGE
;
                                exit;
                            }
          );

if ( $buffer_size > $rotate_size ) {
    warn "Read buffer size larger than maximum log size. Setting buffer size to the specified maximum log size.\n";
    $buffer_size = $rotate_size;
}

my $current_size = 0;
my $read_bytes;

my $FH;

&rotate_logs;

while ($read_bytes = read(STDIN,my $input, $buffer_size)){
    print $FH "$input";
    $current_size += $read_bytes;
    if ($current_size >= $rotate_size) {
        &rotate_logs;
        $current_size = 0;
    }
}

if ( ! defined $read_bytes ) {
    die "read() failed: $!\n";
}

if ( $VERBOSE && $read_bytes == 0 ) {
    print "End of file\n";
}

if ( defined $FH && tell $FH != -1 ) {
    close $FH;
}

sub rotate_logs {
    if ($VERBOSE) { print "Rotating\n"; }
    opendir(my $DH, $output_dir) or die "opendir() failed: $!\n";
    my @logs = grep {/$output_name(\.[0-9]+)?$/} readdir($DH);
    close $DH;
    for my $log_file (sort logsort @logs) {
        $log_file =~ /([0-9]+)$/;
        if ( ! defined $1 ) {
            next;
        }
        my $log_number = $1;
        if ( $log_number >= $max_log_count-1) {
            if (!unlink($log_file)) {
                warn "Failed to unlink: $log_file\n";
            }
        }
        my $src = sprintf("%s/%s.%d",$output_dir,$output_name,$log_number);
        my $dst = sprintf("%s/%s.%d",$output_dir,$output_name,$log_number+1);
        if ( -f $src ) {
            move($src,$dst) or die "move() failed: $!\n";
        }
    }
    if ( defined $FH && tell $FH != -1 ) {
        close $FH;
    }
    if ( -f "$output_dir/$output_name" ) {
        move("$output_dir/$output_name","$output_dir/$output_name.1") or die "move() failed: $1\n";
    }
    open($FH,'>',$output_name) or die "open() failed: $!\n";
}

sub logsort {
    $a =~ /([0-9]+)$/;
    my $a_num = $1;
    $b =~ /([0-9]+)$/;
    my $b_num = $1;
    if ( ! defined $a_num ) { return $b_num; }
    if ( ! defined $b_num ) { return $a_num; }
    $b_num <=> $a_num;
}
