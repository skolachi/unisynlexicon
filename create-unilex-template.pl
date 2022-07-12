#!/usr/bin/perl
#takes a file (wordlist, lowercase) and makes unisyn-format entries
#uses frequencies from uni_freqs
#also looks at unilex and warns if words are already in there (outputs them anyway with # marker in pron

use FindBin;
use lib $FindBin::Bin;
use strict;

#this file lists frequencies
our $FREQ = "$FindBin::Bin/uni_freqs";
open (FREQ) || die "Cannot open $FREQ: $!\n";
our $UNI = "$FindBin::Bin/unilex";
open (UNI) || die "Cannot open $UNI: $!\n";

if ( $#ARGV != 0) {
    die "\nusage:  create-unilex-template.pl wordlist\n
takes a wordlist file and turns in into blank unisyn entries, ready for editing
enters word string in morpheme field ready for editing
in pron field, script enters free root morphemes but no other symbols

user should edit POS, pron, morpheme field

if wordlist file contains multiple fields per line, takes first one only
if wordlist contains uppercase letters, makes them lower case
if word already in unilex, outputs warning and creates template anyway with # marker in pron\n";
}

our %freqs;
our %uni;
our $wd;
our $freq;

while (<FREQ>) {
    chomp;
    if (/^([0-9]+)\s+([^ ]*)/) {
	$freqs{$2} = $1;
    }
}

while (<UNI>) {
    chomp;
    if (/^([^:]+):/) {
	$uni{$1} = 1;
    }
}

while (<>) {
    chomp;
    if (/^[\s]*([^\s]+)/) {
	$wd = $1;
	$wd =~ s/(.*)/\L$1/;
	if (exists $freqs{$wd}) {
	    $freq = $freqs{$wd};
	}
	else {
	    $freq = 0;
	}
	print $wd;
	if (exists $uni{$wd}) {
	    print STDERR "WARNING, WORD \'$wd\' IS ALREADY IN UNILEX, MAKING ENTRY ANYWAY WITH # MARKER IN PRON FIELD\n";
		print "::: { # } :{$wd}:$freq\n";
	}
	else {
	    print "::: { } :{$wd}:$freq\n";
	}
    }
}    
