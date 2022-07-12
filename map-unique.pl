#!/usr/bin/perl
#produces accent-specific symbols, i.e. removes redundancy and just leaves distinctions

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('a:f:i:d');

our ($opt_f,$opt_i,$opt_d,$opt_a);

our $LOC = $opt_a;
our $IN;			# input file if used

my (%mapscore, %towns, %mappings, %tmpmapscore);
my ($allin, $debug, $input) = "";
my (@debug);

#fields in lexicon
my ($entry,$wrd,$sem,$cat,$pro,$aln,$fre);

#vowel, consonant, symbol groups
my ($c,$s,$v,$b,$e) = "";
my (%CONS, %VOWL, %STRS, %EXTR, %BOUN);


#this file lists keysymbols and some features for regexp matches
our $POSI = "$FindBin::Bin/uni_positions";
open (POSI) || die "Cannot open $POSI\n";

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS\n";

#scores listed for oppositions
our $SCORES = "$FindBin::Bin/uni_scores";
open (SCORES) || die "Cannot open $SCORES\n";

&get_towns;

if ( (!$towns{$LOC}) || ((!$opt_f) && (!$opt_i)) ){
    print STDERR "\nusage:  map-unique.pl [-d] -a [towncode] -[fi] [input]\n
-d option prints breakdown of rule use
-a towncode specifies accent
-f lexicon_file/pronstrings_file or 
-i \"lexicon_line\"/\"pronstring\" (stdinput in double quotes)\n\n";
    printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", "CODE", "PERSON", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
    printf STDERR "%-5s  %6s %-21s %-9s %-5s %s\n", "----", "------", "----------", "------", "-----", "-----";
    foreach my $town (sort keys %towns) {
	printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", $town, $towns{$town}{PER}, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
    }
    die "\nThe above towns are supported\n";
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

&get_posi;			# used for checking symbols in input
&get_phoneme_scores;		# reads rule scores from file

#these should be order-independent as they are single segment mappings only
for my $mapping (keys %mappings) {
    &make_mapscores($mapping);	# calculates score
}

$allin =~ s/^\|//;

if ($opt_d) {
    printf "\n";
}


if ($opt_f){			# file input
    $IN = $opt_f;
    open (IN) || die "Cannot open $IN\n";
    
  GETLINE:
    while (<IN>) {
	chop;
	&operate;
    }
}
elsif ($opt_i) {		# stdinput
    $input = $opt_i;
  GETLINE:
    while ($input =~ s/([^\n]+)//) {
	$_ = $1;
	&operate;
    }
}

sub operate {
# automatically detects lexicon or string format, gets parts
    if ($opt_d) {
	@debug = "INPUT:  $_\n";
    }
    &get_format;		
    $_ = $pro;
    if ($_ =~ / ($allin) /) {	# don't bother unless the input mapping symbols are found in the string
	&do_mappings;
	&remove_morphemes;	# remove boundary markers from pron string
#optional printout of rule workings
	if ($opt_d) {
	    $debug = join ('', @debug);
	    $debug =~ s/  / /g;
	    print "$debug\n";
	    print "OUTPUT:  ";
	    undef @debug;
	}
#final output (in string format only $_ will contain data)
	print "$wrd$sem$cat$_$aln$fre\n";
    }
    else {
	&remove_morphemes;
	print "$wrd$sem$cat$_$aln$fre\n";
    }
}

sub do_mappings {

    for my $domap (keys %mapscore) { # only does those with a score above 0
	if ($opt_d) {push (@debug, "    $domap\n");}
#need round brackets on first element as it may be a list of choices
	while ($_ =~ s/ ($mapscore{$domap}{in}) / $mapscore{$domap}{out} /) {
	    &debug_format;
	}
    }
}

sub remove_morphemes {
#    $_ =~ s/[\>\<\}\{\$\=]//g;  #currently not removing these -probably best if diphones etc. avoid crossing, say, compound boundaries
    if ($opt_d) {push (@debug, "    remove-morphemes\n");}
    if ($_ =~ s/\=//g) {&debug_format;}
    $_ =~ s/ +/ /g;
}

sub get_format {
#for lexicon transformation
    if ($_ =~ /^([^:]+:)([^:]*:)([^:]+:)([^:]+)(:[^:]*)(:[^:]*)$/) {
#NB some fields optional
#including : in fields to remain unchanged
	$entry = $_;
	$wrd = $1;
	$sem = $2;
	$cat = $3;
	$pro = $4;
	$aln = $5;
	$fre = $6;
#checks here are only basic - other file checking progs available for more thorough checks, e.g. syllable structure
	if ($wrd !~ /^[a-z\'\-\.]+:$/) {
	    print STDERR "Bad lexicon format for map-unique, line $entry, word field $wrd;\n";
	    next GETLINE;
	}
	if ($cat !~ /^[A-Z\/\|\$]+:$/) {
	    print STDERR "Bad lexicon format for map-unique, line $entry, cat field $cat;\n";
	    next GETLINE;
	}
	if ($pro !~ /^($c|$v|$s|$b|$e| )+$/) {
	    print STDERR "Bad lexicon format for map-unique, line $entry, pron field $pro\n";
	    next GETLINE;
	}
    }
#for strings of prons, taken straight from base lexicon and joined with syllable markers, e.g. /#{ h * or r s }#.#{ r * ee s }#/
#note hash here, not in compounds e.g. / { h * or r s }.{ r * ee s } /
    elsif ($_ !~ /:/) {
	$_ =~ s/^(.*)$/$1/;
	$wrd = "";
	$sem = "";
	$cat = "";
	$pro = $_;
#don't need end spaces in this prog - these lines removed
#	$pro =~ s/^([^ ])/ $1/;
#	$pro =~ s/([^ ])$/$1 /;
#	$pro =~ s/ +$/ /;
#	$pro =~ s/^ / /;
	$aln = "";
	$fre = "";
	$entry = $_;
#end spaces not at issue in this prog - don't bother complaining about them, or about word boundaries appearing at ends; just complain about rogue keysymbols
	if ($pro !~ /^(($c|$v|$s|$b|$e| )+)+$/) {
	    print STDERR "Bad string format for map-unique, line $entry\n";
	    next GETLINE;
	}
    }
    else {
	print STDERR "Bad lexicon format for map-unique, line $_\n";
	next GETLINE;
    }
}

sub get_posi {
#all terms must be used within round brackets e.g. ($b) or ($c|$v) when in reg exps
    $c = "";
    $s = "";
    $v = "";
    $b = "";
    $e = "";

    while (<POSI>){
	chop;
	if ($_ =~ /^Cons:([^ ]+)/) {
	    $CONS{$1} = $';
	    $c = join ('|', $c, $1);
	}
	elsif ($_ =~ /^Stress:([^ ]+)/) {
	    $STRS{$1} = $';
	    $s = join ('|', $s, $1); 
	}
	elsif ($_ =~ /^Vowel:([^ ]+)/) {
#all vowels may be capitalised, but these listed separately in uni_positions
	    $VOWL{$1} = $';
	    $v = join ('|', $v, $1);
	}
#remember boundaries may occur between ANY keysymbols
	elsif ($_ =~ /^Bound:([^ ]+)/) {
	    $BOUN{$1} = $';
	    $b = join ('|', $b, $1); 
	}	
	elsif ($_ =~ /^Extra:([^ ]+)/) {
	    $EXTR{$1} = $';
	    $e = join ('|', $e, $1); 
	}	
    }
    $c =~ s/([\^\!\?])/\\$&/g;	# need to escape some chars
    $c =~ s/^\|//;			
    $v =~ s/[\@\;]/\\$&/g;	#escape some chars
    $v =~ s/^\|//;		
    $s =~ s/[\*\~\-]/\\$&/g;	# need to escape all chars
    $s =~ s/^\|//;
    $b =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b =~ s/^\|//;
    $e =~ s/[\]\[\(\)\/]/\\$&/g;		# need to escape all chars
    $e =~ s/^\|//;
}

sub get_phoneme_scores {
    my $codecheck;
    while (<SCORES>) {
	if (/^\s*\$map.*\{0\}.*;/) {
	    print STDERR "FATAL ERROR:  error in file $SCORES, non-permissible setting 0 for $_";
	}
	elsif (/^\s*\$map\{(.*)\}\{(.*)\}\{(.*)\} \= ([0-9]+)/) {
	    $mappings{$1}{$2}{$3} = $4;
	    $codecheck = 0;
	  CHECKCONV:
	    for my $code (keys %towns) {
		if ($towns{$code}{$2} eq $3) {
		    $codecheck = 1;
		    last CHECKCONV;
		}
	    }
	    if ($codecheck == 0){print STDERR "WARNING:  can't match $2 $3 in file $SCORES, line $_\n";}
	}
	elsif (/^\s*\$map\{(.*)\}\{ALL\} \= ([0-9]+)/) {
	    $mappings{$1}{ALL} = $2;
	}
	elsif ((/\$map/) && ($_ !~ /^\#/)){
	    print STDERR "Can't match mapping line $_ in file $SCORES\n";
	}
    }
}

sub debug_format {
    if ($opt_d) {
	push (@debug, "            \'$`$&$'\' -> \'$_\', matched on \'$&\'\n");
    }
}


sub make_mapscores {
    my ($mapping) = @_;

#tests for application of rule by country, region then town, each level overriding the previous

    $tmpmapscore{$mapping} = 0;
    if (exists ( $mappings{$mapping}{ALL})) {
	$tmpmapscore{$mapping} = $mappings{$mapping}{ALL};
    }
    if (exists ( $mappings{$mapping}{CNY}{$towns{$LOC}{CNY}})) {
	$tmpmapscore{$mapping} = $mappings{$mapping}{CNY}{$towns{$LOC}{CNY}};
    }
    if (exists ( $mappings{$mapping}{REG}{$towns{$LOC}{REG}})) {
	$tmpmapscore{$mapping} = $mappings{$mapping}{REG}{$towns{$LOC}{REG}};
    }
    if (exists ( $mappings{$mapping}{TWN}{$towns{$LOC}{TWN}})) {
	$tmpmapscore{$mapping} = $mappings{$mapping}{TWN}{$towns{$LOC}{TWN}};
    }
    if (exists ( $mappings{$mapping}{PER}{$towns{$LOC}{PER}})) {
	$tmpmapscore{$mapping} = $mappings{$mapping}{PER}{$towns{$LOC}{PER}};
    }
    if ($opt_d) {
	printf "%-30s  %-s\n", "mapscore for $mapping", $tmpmapscore{$mapping};
    }
#could speed things up by only adding relevant rules to array
#put the initial match in the value
    if ($tmpmapscore{$mapping} > 0) {
	if ($mapping =~ /^(.+)\_([^\_]+)$/) {
	    my $in = $1;
	    my $out = $2;
	    $in =~ s/\_/\|/g;
	    $mapscore{$mapping}{in} = $in;
	    $mapscore{$mapping}{out} = $out;
# $allin used for a quick check on input strings to see if I need to alter any symbols - this makes prog a little faster
	    $allin = join ('|', $allin, $in); 
	}
	else {
	    print STDERR "can't parse mapping $mapping in file $SCORES\n";
	}
    }
}
