#!/usr/bin/perl

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('f:i:');

our ($opt_f,$opt_i);
our $IN;
my $fest;

if ((!$opt_f) && (!$opt_i)) {
    die "\nusage:  output-fest.pl -[fi] [input]\n
\t-f file_of_pronunciation_strings or 
\t-i \"string input\" (stdinput in double quotes, no new lines)
\tinput should be keysymbols\n\n";}

if ($opt_f)  {
    $IN = $opt_f;
    open (IN) || die "Cannot open $IN\n";
    while (<IN>) {
	&clean;
	print $fest;
    }
}

elsif ($opt_i) {
    $_ = $opt_i;
    &clean;
    print $fest;
}

sub clean {
    s/[\{\}\<\>\=\.\#\$]//g;
    s/[\*\~\-] //g;
    s/ +/ /g;
    s/\!/\=/g;			# not sure if festival likes !
    s/\;/\:/g;			# festival definitely doesn't like ; (NB will be a problem if I make a whole lexicon but I don't think this should arise
    $fest = $_;
}
