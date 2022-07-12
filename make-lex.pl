#!/usr/bin/perl
#this outputs an accent-specific lexicon, in keysymbols or accent-specific SAMPA format
#uses get-exceptions and post-lex-rules and map-unique

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('a:f:spr');

our ($opt_a,$opt_f,$opt_s,$opt_p,$opt_r);
our $LOC = $opt_a;
$LOC = $opt_a;
undef our $R;
if ($opt_r) {$R = '-r';}

my $line;   #stores line number if error occurs in script
my %towns;  #stores town hierarchy

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS\n";

&get_towns;
	    $towns{$1}{$2} = $3;
if ( (!$opt_a) || (!$opt_f) || (!exists $towns{$LOC})){
    print STDERR  "\nusage:  make-lex.pl [-r] -a [towncode] [-sp] -f [input_lexicon]\n
produces accent-specific version of lexicon (NB words treated as sentence-final)
-r option doesn't remove utterance-final /r/ in linking accents, e.g. rp
-a towncode specifies accent

default option outputs a keysymbol lexicon
-s option outputs a keysymbol lexicon and a SAMPA lexicon
-p option outputs a keysymbol lexicon, a SAMPA lexicon and an html-formatted ipa lexicon

-f lexicon_file
output goes to lex_towncode_jobnumber_\.\.\.\n\n";
    printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", "CODE", "PERSON", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
    printf STDERR "%-5s  %6s %-21s %-9s %-5s %s\n", "----", "------", "----------", "------", "-----", "-----";
    foreach my $town (sort keys %towns) {
	printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", $town, $towns{$town}{PER}, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
    }
    die "\nThe above towns are supported\n";
}

our $LEX = $opt_f;
open (LEX) || die "Cannot open $LEX\n";

#need output files
#nb these are repeated lower down - if these names changed, change the other instances too
our $EXOUT = "+>lex\_$LOC\_$$\_1exceptions";
open (EXOUT) || die "Cannot create $EXOUT\n";

our $POSTOUT = "+>lex\_$LOC\_$$\_2post-lex";
open (POSTOUT) || die "Cannot create $POSTOUT\n";

our $UNIQOUT = "+>lex\_$LOC\_$$\_3unique";
open (UNIQOUT) || die "Cannot create $UNIQOUT\n";

our $SAMOUT;
our $IPAOUT;

if (($opt_s) || ($opt_p)) {
    $SAMOUT = "+>lex\_$LOC\_$$\_4sam";
    open (SAMOUT) || die "Cannot create $SAMOUT\n";
    if ($opt_p) {
	$IPAOUT =  "+>lex\_$LOC\_$$\_5ipa.html";
	open (IPAOUT) || die "Cannot create $IPAOUT\n";
    }
}


sub get_towns {
    while (<TOWNS>) {
	if (/\$towns\{(.*)\}\{(.*)\}.*\"(.*)\"/) {
	    $towns{$1}{$2} = $3;
	}
	elsif (/\$/){
	    print STDERR "WARNING:  can't parse input in file $TOWNS line $_\n";
	}
    }
}

print EXOUT `perl $FindBin::Bin/get-exceptions.pl -a $LOC -f $LEX`;
#error trapping 
if ($?) {$line = __LINE__; print STDERR "error $? at get-exceptions, in $0 line $line\n";undef $?;}
seek (EXOUT, 0, 0);  #reset file pointer

#cannot use filehandle with backticks, have to specify name
#this version much faster than passing separate lines of the file
print POSTOUT `perl $FindBin::Bin/post-lex-rules.pl $R -a $LOC -f lex\_$LOC\_$$\_1exceptions`;
if ($?) {$line = __LINE__; print STDERR "error $? at post-lex-rules, in $0 line $line\n";undef $?;}

seek (POSTOUT, 0 ,0);

print UNIQOUT `perl $FindBin::Bin/map-unique.pl -a $LOC -f lex\_$LOC\_$$\_2post-lex`;
if ($?) {$line = __LINE__; print STDERR "error $? at map-unique, in $0 line $line\n"; undef $?;}

if (($opt_s) || ($opt_p)) {
    seek (UNIQOUT, 0,0);
    print SAMOUT `perl $FindBin::Bin/output-sam.pl -a $LOC -f lex\_$LOC\_$$\_3unique`;
    if ($?) {$line = __LINE__; print STDERR "error $? at output-sam, in $0 line $line\n"; undef $?;}
}

if ($opt_p) {
    seek (SAMOUT, 0,0);   #this line added for perl 5.005
#can't use SAMOUT filehandle here
    print IPAOUT `perl $FindBin::Bin/output-ipa.pl -f lex\_$LOC\_$$\_4sam`;
    if ($?) {$line = __LINE__; print STDERR "error $? at output-ipa, in $0 line $line\n";undef $?;}
}



