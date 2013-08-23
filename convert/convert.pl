#!/usr/bin/perl -w

use strict;
use Cwd;
use File::Find;
use File::Path qw(make_path);
use Getopt::Long;

my $OUTPUT_DIR;
my $INPUT_DIR;
my $INPUT_FILE;
my $TEMPLATE_FILE;
my $cwd = getcwd;
my $usage = <<USAGE
$0 -i INPUT_DIR -o OUTPUT_DIR -t TEMPLATE_FILE

Converts .convert files in INPUT_DIR and writes them to OUTPUT_DIR, preserving
the directory structure. Uses TEMPLATE_FILE as the basis of the output files.
USAGE
;

GetOptions("help"       => sub {print "$usage"; exit;},
           "in=s"       => \$INPUT_DIR,
           "out=s"      => \$OUTPUT_DIR, 
           "template=s" => \$TEMPLATE_FILE,
          );

if ( ! defined $OUTPUT_DIR or 
     ! defined $INPUT_DIR or 
     ! defined $TEMPLATE_FILE
   ) {
    die "$usage";
}

# File::Find changes directories, so we need to use full paths
if ( $OUTPUT_DIR !~ /^\// ) { $OUTPUT_DIR = "$cwd/$OUTPUT_DIR"; }
if ( $INPUT_DIR !~ /^\// ) { $INPUT_DIR = "$cwd/$INPUT_DIR"; }
if ( $TEMPLATE_FILE !~ /^\// ) { $TEMPLATE_FILE = "$cwd/$TEMPLATE_FILE"; }

File::Find::find(\&convert_dir, $INPUT_DIR); 

sub convert_dir {
    use vars '*name';
    *name = *File::Find::name;

    if ( lstat($_) && /^.*\.convert\z/s ) {
        $name =~ /^$INPUT_DIR(.*)\/(.+?).convert$/;
        my $base_dir = '';
        my $base_name = $2;
        if (defined $1) { $base_dir = $1; }
        my $output_dir = "$OUTPUT_DIR/$base_dir";
        if ( ! -d $output_dir ) {
            make_path($output_dir);
        }
        print "$name -> $output_dir/$base_name.html\n";
        &convert_file($name, "$output_dir/$base_name.html", $TEMPLATE_FILE);
    }
}

sub convert_file {
    my ($input_file,$output_file,$template_file) = @_;

    open(my $TEMPLATE, '<', $template_file) or die "$0: $template_file: $!\n";
    open(my $OUTPUT,   '>', $output_file) or die "$0: $output_file: $!\n";

    my $converted = &process_input($input_file);

    while(<$TEMPLATE>) {
        if (/^\s*<\!--\s*##TITLE\s*-->.*$/) {
            print $OUTPUT $converted->{'title'};
        } elsif (/^(\s*)<\!--\s*##BODY\s*-->.*$/) {
            my $indent = '';
            if (defined $1) {
                $indent = $1;
            }
            for (@{$converted->{'body'}}) {
                print $OUTPUT "$indent$_";
            }
        } else {
            print $OUTPUT $_;
        }
    }
    close $TEMPLATE;
    close $OUTPUT;
}
    
sub process_input {
    my ($input_file) = @_;
    my $converted = {'title' => '',
                     'body'  => []};
    open(my $INPUT,    '<', $input_file) or die "$0: $input_file: $!\n";
    while (<$INPUT>) {
        chomp;
        my $s = '';
        if (/^\s*$/) {
            next;
        } elsif (/^=T=(.+)$/) {
            $converted->{'title'} = "<title>$1</title>";
            $s = "<h1>$1</h1>\n";
        } elsif (/^=([0-9]+)=(.+)$/) {
            my ($num,$line) = ($1,$2);
            $num++;
            $s = "<h$num>$line</h$num>\n";
        } elsif (/^=R=(.+?)$/) {
            $s = "$1\n";
        } else {
            $s = "<p>$_</p>\n";
        }
        push($converted->{'body'},$s);
    }
    close $INPUT;
    return $converted;
}
