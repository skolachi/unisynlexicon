#!/usr/bin/perl
#this used to substitute items from exceptions list (and related forms) into base lexicon
#new one-line format assumed
#log is used to check matches - currently commented out

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;

use Getopt::Std;
getopts('a:f:');

my (%towns, %exc);
my ($wrdsemcat, $pro, $aln, $fre);
my ($quickmatch, $match) = "";
my ($oldproprontmp, $newproprontmp, $oldprobeg, $oldproend, $newpro, $oldpro, $newpropron, $oldpropron);
our ($opt_a, $opt_f);

my $LOC = $opt_a;

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS: $!\n";


#LOG FOR NOTING WHAT'S BEEN CHANGED - can comment out
#our $LOG = "+>./exceptions_log";
#open (LOG) || die "Cannot open $LOG: $!\n";
#END LOG COMMENTS - SEE ALSO BELOW


#this file lists exceptions
our $EXC = "$FindBin::Bin/uni_exceptions";
open (EXC) || die "Cannot open $EXC: $!\n";

#for lexicon
our $INFILE = $opt_f;

&get_towns;


if ((!$opt_f) || (!$towns{$LOC}{TWN}) ) {
    printf STDERR "\nusage:  get-exceptions.pl -a [towncode] -f [inputfile]\n\n";
    printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", "CODE", "PERSON", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
    printf STDERR "%-5s  %6s %-21s %-9s %-5s %s\n", "----", "------", "----------", "------", "-----", "-----";
    foreach my $town (sort keys %towns) {
	printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", $town, $towns{$town}{PER}, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
    }
    die "\nThe above towns are supported\n";
}

#input lexicon
open (INFILE) || die "Cannot open $INFILE: $!\n";
 
&find_exceptions;

#remove initial | and escape funny chars in alignment string
$quickmatch =~ s/^\|//;
$quickmatch =~ s/[\=\}\{\'\-]/\\$&/g;

READ:
while (<INFILE>) {
    chop;
#only bother if $quickmatch matches input (this is reg exp of form word1|word2|word3, where word is taken from alignment field

    unless ($_ =~ /($quickmatch)/) { 
	print "$_\n";
	next READ;
    }
#as in post-lex-rules
    if ($_ =~ /^([^:]+:[^:]*:[^:]+:)([^:]+)(:[^:]*)(:[^:]*)$/) {
#NB some fields optional
#including : in fields to remain unchanged
	$wrdsemcat = $1;
	$pro = $2;
	$aln = $3;
	$fre = $4;
#LOOKING FOR EXAMPLES WHERE EXCEPTION MORPHEME APPEARS IN WORD
	foreach my $ex (keys %exc) {
	    $match = 0;
	    if ($aln =~ /$ex/) {
		$match = -1;
		if ($exc{$ex} =~ /^[^:]+:[^:]*:[^:]+:([^:]+)/) {
		    my $expro = $1;
		    $expro =~ /^([^\%]*)\%(.*)/;
		    $oldpro = $1;
		    $newpro = $2;
#THIS BIT FOR COPING WITH RELATED FORMS
#extract morpheme ends for matching part pronunciations with the same morpheme boundaries
		    $oldpro =~ /^ *([\<\{\}\>\=])(.*)([\<\}\{\>\=]) *$/;
		    $oldprobeg = $1;
		    $oldpropron = $2;
		    $oldproend = $3; 
		    $newpro =~ /^ *([\<\{\}\>\=])(.*)([\<\}\{\>\=]) *$/;
		    $newpropron = $2;
		    
		    $oldpro = $pro;
		    if ($pro =~ s/\Q$oldprobeg\E(\Q$oldpropron\E)\Q$oldproend\E/$oldprobeg$newpropron$oldproend/) {
			$match = 1;
		    }
		    else {
#FOR IGNORING OR REDUCING STRESS FOR COMPOUND-MATCHING AND DERIVATION - REDUCE THREE TIMES
			$newproprontmp = $newpropron;
			$oldproprontmp = $oldpropron;
			$newproprontmp =~ s/\~ /\- /g;
			$newproprontmp =~ s/\* /\~ /g;
			$oldproprontmp =~ s/\~ /\- /g;
			$oldproprontmp =~ s/\* /\~ /g;
			if ($pro =~ s/\Q$oldprobeg\E(\Q$oldproprontmp\E)\Q$oldproend\E/$oldprobeg$newproprontmp$oldproend/) {
			    $match = 1;
			}
			else {
			    $newproprontmp =~ s/\- / /g;
			    $newproprontmp =~ s/\~ /\- /g;
			    $newproprontmp =~ s/\* /\~ /g;
			    $oldproprontmp =~ s/\- / /g;
			    $oldproprontmp =~ s/\~ /\- /g;
			    $oldproprontmp =~ s/\* /\~ /g;
			    if ($pro =~ s/\Q$oldprobeg\E(\Q$oldproprontmp\E)\Q$oldproend\E/$oldprobeg$newproprontmp$oldproend/) {
				$match = 1;
			    }
			}
#FOR ADJUSTING STRESS IN DERIVATIONS, ADDING SECONDARY STRESS TO ORIGINAL (NON-EXCEPTION) PRONS, E.G. ORGANISE -> ORGANISES, ORGANISER, ORGANISABLE (PRIMARY STRESS THREE-SYLL FROM END)
			$newproprontmp = $newpropron;
			$oldproprontmp = $oldpropron;
			if ((($_ =~ /(VBZ|VBG)/) || ($_ =~ /NN.*\>er\>/) || ($_ =~ /JJ.*\>[ai]ble\>/)) && ($oldproprontmp =~ /\*[^\.]*\.[^\.]*\.[^\.]*$/))  {
			    $oldproprontmp =~ s/ ([aeiou\@][^\.]*)$/ \~ $1/gi;
			    if ($pro =~ s/\Q$oldprobeg\E(\Q$oldproprontmp\E)\Q$oldproend\E/$oldprobeg$newproprontmp$oldproend/) {
				$match = 1;
			    }
			}
#ADJUST STRESS FOR SOME OTHER DERIVATIONS, E.G. THEOR== ->> THEOR==ETIC
			elsif (($_ =~ /(JJ|RB|NN)/) && ($aln =~ /etic|ation/)) {
			    $oldproprontmp =~ s/ \* / \~ /; 
			    $newproprontmp =~ s/ \* / \~ /; 
			    if ($pro =~ s/\Q$oldprobeg\E(\Q$oldproprontmp\E)\Q$oldproend\E/$oldprobeg$newproprontmp$oldproend/) {
				$match = 1;
			    }
			    else {
				$oldproprontmp =~ s/ \~ / /; 
				$newproprontmp =~ s/ \~ / /; 
				if ($pro =~ s/\Q$oldprobeg\E(\Q$oldproprontmp\E)\Q$oldproend\E/$oldprobeg$newproprontmp$oldproend/) {
				    $match = 1;
				}
			    }
			}
		    }
		}
		else {
		    print STDERR "Bad format in exceptions file, line $exc{$ex}\n";
		}
	    }
#COMMENT OUT FROM HERE FOR NO LOG - SEE ALSO ABOVE
#	    if ($match == 1) {
#		print LOG "$exc{$ex}:$ex:\n\t$wrdsemcat$oldpro$aln$fre\n   \-\>\t$wrdsemcat$pro$aln$fre\n\n";
#	    }
#	    if ($match == -1 ){
#		print LOG "$exc{$ex}:$ex:\n\t$wrdsemcat$oldpro$aln$fre\n   \!-\>\n\n";
#	    }
#END OF NO LOG COMMENTING
	}
    } 
    else {
	print "$_\n";
	print STDERR "Bad format in base lex, line $_\n";
    }
    print "$wrdsemcat$pro$aln$fre\n";
}


sub get_towns {
    while (<TOWNS>) {
	if (/\$towns\{(.*)\}\{(.*)\}.*\"(.*)\"/) {
	    $towns{$1}{$2} = $3;
	}
    }
}

sub find_exceptions {
#ordering ensures that local varieties overrule country varieties
#add exceptions to a regular expression to speed up prog by quick match on input from main lexicon

    while (<EXC>) {
	if ($_ =~ /^\{CNY\} \= \"$towns{$LOC}{CNY}\" \% ([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):[0-9]*$/) {
	    $exc{$2} = $1;
	    $quickmatch = join ('|', $quickmatch, $2); 
	}
	elsif ($_ =~ /^\{REG\} \= \"$towns{$LOC}{REG}\" \% ([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):[0-9]*$/){
	    $exc{$2} = $1;
	    $quickmatch = join ('|', $quickmatch, $2); 
	}
	elsif ($_ =~ /^\{TWN\} \= \"$towns{$LOC}{TWN}\" \% ([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):[0-9]*$/) {
	    $exc{$2} = $1;
	    $quickmatch = join ('|', $quickmatch, $2); 
	}
	elsif ($_ =~ /^\{PER\} \= \"$towns{$LOC}{PER}\" \% ([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):[0-9]*$/) {
	    $exc{$2} = $1;
	    $quickmatch = join ('|', $quickmatch, $2); 
	}
	elsif (($_ !~ /^\#/) && ($_ =~ /[a-z]/) && 
	       ($_ !~ /^\{(PER|TWN|CNY|REG)\} \= \"[^\"]+\" \% ([^:]*:[^:]*:[^:]*:[^:]*):([^:]*):[0-9]*$/)) {
	    print STDERR "warning, can't match line \"$_\" in $EXC\n";
	}
    }
}
