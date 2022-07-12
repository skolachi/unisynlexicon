#!/usr/bin/perl
#transforms text into pronunciation strings, for input to post-lex-rules

#use strict;
#use diagnostics;
local $SIG{__DIE__} = sub {};

use Getopt::Std;
getopts('f:i:l:a:');
use FindBin;
use lib $FindBin::Bin;

#for Readtext module
use Readtext;

our ($opt_f,$opt_i,$opt_l,$opt_a);
my (@lex, %towns, %lex);
my $text = ""; 
our $TEXT;
our $LEX = $opt_l;
my $LOC = $opt_a;

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS: $!\n";

&get_towns;

unless (($opt_l) && ($opt_a) && (($opt_f) || ($opt_i)) && ($towns{$LOC})) {
    print STDERR "\nusage:  read-text.pl -a [towncode] -l [intermediate_lexicon_file] -[fi] [input]
transforms plain text into accent-specific pronunciation strings for input to post-lex-rules
-a towncode
-l denotes intermediate lexicon file (output of get-exceptions)
-f for text file
-i \"string input of text\"\n\n";
    printf STDERR "%-4s  %-21s %-9s %-5s %s\n", "CODE", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
    printf STDERR "%-4s  %-21s %-9s %-5s %s\n", "----", "----------", "------", "-----", "-----";
    foreach my $town (sort keys %towns) {
	printf STDERR "%-4s  %-21s %-9s %-5s %s\n", $town, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
    }
    die "\nThe above towns are supported\n";
}

#read in lexicon (should contain exceptions)
open (LEX) || die "Cannot open $LEX\n";
while (<LEX>) {
    push (@lex, $_);
}

if ($opt_f) {
    $TEXT = $opt_f;
    open (TEXT) || die "Cannot open $TEXT: $!\n";
}


#read in text
if ($opt_f) {
    while (<TEXT>) {
	$text = join ('', $text, $_);
    }
}
elsif ($opt_i) {
    $text = join ('', $text, $opt_i);
}

#pass lexicon to module and parse
%lex = &Readtext::parse_lex(@lex);    

#split input into crude sentences and then make into pronunciation strings
#strip final dot off strings of initials
$text =~ s/(([A-Z]\.)+[A-Z])\./$1/;
#allow for word-internal dots, e.g. dot.com, decimal numbers
$text =~ s/([\?\.\!]+)(?![a-zA-Z0-9])/$1 /g;  #zero-width match on alphanumeric
$text =~ s/$/\. /;

#clean up strings of initials - allows for multiple caps but not single, e.g. S.E. Fitt but not S. Fitt
while ($text =~ /[A-Z]\.[A-Z]/) {
    $text =~ s/([A-Z])\.([A-Z])/$1 $2/;
}

while ($text =~ s/^\s*(([^\?\.\!]+|[0-9a-zA-Z\?\=\-]\.[0-9a-zA-Z\?\=\-]+)+[\?\.\!]+[\)\"\'\]]* )//) {
    my $sent = $1;
    my $string = &Readtext::make_sent_and_transform(\$sent, \%lex, \$LOC, \%towns);
    print $string;
}


sub get_towns {
    while (<TOWNS>) {
	if (/\$towns\{(.*)\}\{(.*)\}.*\"(.*)\"/) {
	    $towns{$1}{$2} = $3;
	}
	elsif (/\$/){
	    print STDERR "WARNING:  can't parse input in file $TOWNS, line $_\n";
	}
    }
}
