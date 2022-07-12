#!/usr/bin/perl

#produces output in SAMPA, accent-specific mapping
#this must FOLLOW map-unique
#uses basic SAMPA symbols, plus X-SAMPA symbols
#to turn syllable boundaries on or off, change value of $DOSYLL

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('a:f:i:');

our ($opt_a,$opt_f,$opt_i);

my $DOSYLL = "y";    #set to n for no syllable boundaries, y for syllable boundaries

my $LOC = $opt_a;    #towncode
our $IN;             #input file, if used
my ($wrd,$sem,$cat,$pro,$aln,$fre,$entry);  #word parts
my (%mappings, $mapping, %map, %samscore);    #store accent-dependent mappings and scores
my (%towns);
my ($cny, $num, $text);         #used for parts of input

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS\n";

#scores listed for oppositions
our $SAM = "$FindBin::Bin/uni_sam";
open (SAM) || die "Cannot open $SAM\n";

&get_towns;

if ( (!$towns{$LOC}) || ((!$opt_f) && (!$opt_i)) ){
    print STDERR "\nusage:  output-sam.pl -a [towncode] -[fi] [input]\n
-a towncode specifies accent
-f lexicon_file/pronunciation_strings_file or 
-i \"lexicon_line\"/\"pronunciation string\" (stdinput in double quotes)\n\n";
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

&get_file_scores;		# reads rule scores from file
&parse_maps;                    # get ready for matching

if ($opt_f){			# file input
    $IN = $opt_f;
    open (IN) || die "Cannot open $IN\n";
    
  GETLINE:
    while (<IN>) {
	chop;
	&operate_sam;
    }
}
elsif ($opt_i) {		# stdinput
    my $input = $opt_i;
  GETLINE:
    while ($input =~ s/([^\n]+)//) {
	$_ = $1;
	&operate_sam;
    }
}

sub operate_sam {
#character conversion
    &get_format;		

#remove morphology and tertiary stress - leave syllables to help with other stress
    $pro =~ s/[\{\}\<\>\=\$\-]//g;
    $pro =~ s/ +/ /g;
    $pro =~ s/\.\#/ \./g;	# do word boundaries so as to leave word spaces
    $pro =~ s/^\#//;	# do word boundaries so as to leave word spaces
    $pro =~ s/\#$//;	# do word boundaries so as to leave word spaces

#do stress - this is hardwired in here, not in mappings file
#primary
    $pro =~ s/ \. ([^\.\*]*)\* / \+\"\+ $1 /g; # word(or phrase)-internal
    $pro =~ s/^ ([^\.\*]*)\* / \+\"\+ $1 /g;   # string-initial

#secondary
    $pro =~ s/ \. ([^\.\*]*)\~ / \+%\+ $1 /g;  # word(or phrase)-internal
    $pro =~ s/^ ([^\.\*]*)\~ / \+%\+ $1 /g;    # string-initial
    
    if ($DOSYLL eq "n") {
	$pro =~ s/ \.//g;
    }
    elsif ($DOSYLL eq "y") {
	$pro =~ s/ \# \. / \# /g;		# remove syll boundaries at word ends
	$pro =~ s/ \./ \+\$\+/g;
    }
    else {
	print STDERR "incorrect setting for \$DOSYLL in output-sam\n";
    }
    $pro =~ s/ +/ /g;

    for my $inchar (keys %map) { # only does those which were saved in hash
#need \Q\E to match ^ in taps
	$pro =~ s/ (\Q$inchar\E) / \+$map{$inchar}\+ /g;
    }

    $pro =~ s/SCOTSU/\}/g;

#clean up word boundaries
    $pro =~ s/#//g;
#final output (in string format only $+ will contain data)
#let's add spaces for a clearer lexicon, as : is used in sampa
    $cat =~ s/(.)$/$1 /;
    $aln =~ s/^(.)/ $1/;
    if ($pro =~ /^( +(\+[^\+ ]+\+))* $/) {
	$pro =~ s/\+ \+//g;
	$pro =~ s/\+  \+/ /g;
	$pro =~ s/\+//g;
	$pro =~ s/^ +//g;
	$pro =~ s/ +$//g;
	print "$wrd$sem$cat$pro$aln$fre\n";
    }
    elsif ($pro) {
	my $unmatched = "";
	my $tmpunmatched = $pro;
	while ($tmpunmatched =~ s/ ([^\+ ]+) / /) {
	    $unmatched = join (' ', $unmatched, $1);
	}
	$pro =~ s/\+ \+//g;
	$pro =~ s/\+//g;
	print "$wrd$sem$cat$pro$aln$fre, WARNING,$unmatched NOT MAPPED TO SAMPA\n";
    }
    else {
	print "\n";             #for blank lines
    }
    s/ +/ /g;
    s/ $//;
    s/^ //;
}


sub get_file_scores {
    while (<SAM>) {
	if (/^\s*\$sampa.*\{0\}.*;/) {
	    print STDERR "FATAL ERROR:  error in file $SAM, non-permissible setting 0 for $_";
	}
	elsif (/^\s*\$sampa\{([^\_]*)\_(.*)\}\{(.*)\}\{(.*)\}\s+\=\s+1;/) {
	    my $codecheck = 0;
	  CHECKCONV:
	    for my $code (keys %towns) {
		if ($towns{$code}{$3} eq $4) {
		    $codecheck = 1;
		    last CHECKCONV;
		}
	    }

	    if ($codecheck == 0){print STDERR "WARNING:  can't match $3 $4 in file $SAM, line $_\n";}

#person takes precedence over all
	    if ($4 eq $towns{$LOC}{PER}) {
		undef $mappings{$1};
		$mappings{$1}{$3}{$4} = $2;
	    }
#others only done if mapping at lower level not found
	    elsif ($4 eq $towns{$LOC}{TWN}) {
		if ((! $mappings{$1}) || 
		    ( $mappings{$1}{REG}) ||( $mappings{$1}{CNY})|| ( $mappings{$1}{ALL}) ) {
		    delete $mappings{$1};
		    $mappings{$1}{$3}{$4} = $2;
		}
	    }
	    elsif ($4 eq $towns{$LOC}{REG}) {
		if ((! $mappings{$1}) || 
		    ( $mappings{$1}{CNY})|| ( $mappings{$1}{ALL}) ) {
		    delete $mappings{$1};
		    $mappings{$1}{$3}{$4} = $2;
		}
	    }
	    elsif ($4 eq $towns{$LOC}{CNY}) {
		if ((! $mappings{$1}) ||
		    ( $mappings{$1}{ALL}) ) {
		    delete $mappings{$1};
		    $mappings{$1}{$3}{$4} = $2;
		}
	    }
	}
	elsif (/^\s*\$sampa\{([^\_]*)\_(.*)\}\{ALL\}\s+\=\s+1;/) {
	    if (! $mappings{$1}) {
		$mappings{$1}{ALL} = $2;
	    }
	}
	elsif ((/\$sampa/) && ($_ !~ /^\#/)){
	    print STDERR "Can't match mapping line $_ in file $SAM\n";
	}
    }
}

sub parse_maps {
    for my $tmpchar (keys %mappings) {
#should only be one key for each, but I don't know what it is
	for my $tmpkey (keys %{$mappings{$tmpchar}}) {
	    if  ($tmpkey eq "ALL") {
		$map{$tmpchar} = $mappings{$tmpchar}{ALL};
	    }
	    else {
		for my $tmpanotherkey (keys %{$mappings{$tmpchar}->{$tmpkey}}) {
		    $map{$tmpchar} = $mappings{$tmpchar}->{$tmpkey}->{$tmpanotherkey};
		}
	    }
	}
    }
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
#leave out checks here on format - if it's got this far it should be ok
    }

#for strings of prons, taken straight from base lexicon and joined with syllable markers, e.g. /#{ h * or r s }#.#{ r * ee s }#/
#or for output of transform-text
#note hash here, not in compounds e.g. / { h * or r s }.{ r * ee s } /
    else { 
	$wrd = "";
	$sem = "";
	$cat = "";
	$aln = "";
	$fre = "";
	$pro = "";
#optional country name
	if (s/^([a-z][a-z][a-z]\:  )//) {
	    $cny = $1;
	}
	else {
	    $cny = "";
	}
#optional numbering
	if (s/^( *[0-9]+[\.\:]*)//) {
	    $num = $1;
	}
	else {
	    $num = "";
	}
#optional text - marked by 3 spaces (nb may be on multiple lines - don't want to use paragraph input as it may be a lexicon with line format)
#keysymbol input should have #{ or }#, or #< or >#, on every line
	if (/(.*NOT_IN_LEXICON.*)/) {   #oov words
	    $text = $_;
	    $pro = "";
	    &do_chars;
	    $text = "";
	}
	elsif (($_ !~ /(\#[\{\<]|[\>\}]\#)/) && ($_ !~ /:   /) && (!$text)){     #first line of multi-line text
	    $text = $_;
	    $pro = "";
	}
	elsif (($_ !~ /(\#[\{\<]|[\>\}]\#)/) && ($text)){  #other lines of multi-line text
	    $text = join ('', $text, $_);
	}
	elsif (($text) && (/^(.*\:   )/)) {   #last line of multi-line text
	    $text = join ('', $text, $1);
	    $pro = $';
	}
	elsif (/^(.*\:   )/s) {                #text in input /s allows . to match \n
	    $text = $&;
	    $pro = $';
	}
	else {
	    $pro = $_;
	}
    }
}

