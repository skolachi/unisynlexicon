#!/usr/bin/perl
#Program for checking phonotactics of unisyn transcriptions in lexicon format, or string format, no text

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('lmd01a:');

#variables for options
our ($opt_l,$opt_d,$opt_0,$opt_1, $opt_a);
my $LOC = $opt_a;
my $REPALL;
my $DEBUG = 0;  #If this is 0, messages turned off except for errors; if 1, all turned on.

#general variables

my (%towns);

#rules from file RULES
my (@ruleinit, @ruleforinit, @rulestress, @rulevowel, @ruleforvowel, @rulesyllcons, @rulefinal, @ruleforfinal);

#for storing groups of symbols to try to match them with rules
my (@initial, @stress, @vowel, @syllabic, @final);

#for getting allowed positions from POSI file
my (%posinit, %posstress, %posvowel, %possyllcons, %posfin);
my ($syllable);

my $entry;            #stores whole entry
my $wd;               #stores word
my $transcription;     #stores whole pronunciation
my $stringmode;
my $found_error = 0;

#options for derived or base lexicon	
my $L = $opt_l;		
my $D = $opt_d;
my $M = $opt_m;

unless (($#ARGV == 0) && (($L) || ($M) || ($D)) && (($opt_0) || ($opt_1))) { 
    die "\nusage: check-phon.pl -[lmd] -[01] [-a accent] [inputfile]\n\nchecks UNISYN lexicon or string transcription
first argument l for checking base lexicon or string, m for checking intermediate lexicon (output by get-exceptions.pl or map-unique.pl), d for checking derived lexicon or string
second argument can be 0 \(don't report uncommon strings\) or 1 \(report uncommon or foreign strings\)
third argument (optional) -a accent to allow for accent-specific exceptions in derived files\n";
}


#check accent input

if ($LOC) {
    our $TOWNS = "$FindBin::Bin/uni_towns";
#supported towns listed in towns file
    open (TOWNS) || die "Cannot open $TOWNS: $!\n";
    &get_towns;


    if (!$towns{$LOC}) {
	printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", "CODE", "PERSON", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
	printf STDERR "%-5s  %6s %-21s %-9s %-5s %s\n", "----", "------", "----------", "------", "-----", "-----";
	foreach my $town (sort keys %towns) {
	    printf STDERR "%-5s  %-6s %-21s %-9s %-5s %s\n", $town, $towns{$town}{PER}, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
	}
	die "\nThe above towns are supported\n";
    }
}

# If this is -0, no foreign/uncommon strings reported; if -1, all these reported
if ($opt_0) {	
    $REPALL = 0;
}
elsif ($opt_1) {
    $REPALL = 1;
}		

our $RULES = "$FindBin::Bin/uni_rules";
open (RULES) || die "Cannot open $RULES: $1\n";

our $POSI = "$FindBin::Bin/uni_positions";
open (POSI) || die "Cannot open $POSI: $1\n";

our $FILE = $ARGV[0];
open (FILE) || die "Cannot open $FILE for input: $1\n";

&get_rules;
&get_positions;
my $lex = 0;

ENTRY:
while (<FILE>) {			
    $entry = $_;
    chop;
    $found_error = 0;
#lexicon
    if (/^([^:]*):[^:]*:[^:]*: [\<\{]([^:]*) :[^:]*:[^:]*/) {
	$wd = $1;
	$transcription = $2;
	$stringmode = 0;
	$transcription =~ s/[\<\>\{\}\$\=]+//g;	# removing morpheme and word boundaries
	$transcription =~ s/ +/ /g;
	$lex = 1;
    }
#pronunciation string, with optional accent intro
#cannot use word info here
    elsif (/^([a-z0-9]+:)*\s*\#([\<\{].*[\>\}]\#)/){
	$transcription = $2;
	$stringmode = 1;
	$transcription =~ s/[\<\>\{\}\$\=\#]+//g;	# removing morpheme and word boundaries
	$transcription =~ s/ +/ /g;
	$lex = 2;
    }
    elsif (/[^\s]/) {
	print STDERR "skipping line $_, bad format\n";
	next ENTRY;
    }
    else {
	next ENTRY;
    }
#if different, do both am and british versions for base files, can't check all accents though, too many permutations
    if ($transcription =~ /[\[\/A-Z]/) {
	my $storetrans = $transcription;
	#do brit one
	$transcription =~ s/\[([^\]]*[^1])\]/$1/g;
	$transcription =~ s/\[([^\]]*)1\]//g;
	$transcription =~ s/\(([^\/]+)\/([^\)]+)\)/$1/g;
	$transcription =~ s/(\/[^ ]+)//g; 
	$transcription =~ s/([A-Z\@]+R)1/\@r/g; 
	$transcription =~ s/([A-Z]+\@*)([^0-9A-Z])/\L$1$2/g; 
	$transcription =~ s/([A-Z]+\@*)1/\@/g; 
	$transcription =~ s/ +/ /g; 
	$transcription =~ s/^ //; 
	$transcription =~ s/ $//; 
	&checksyl;
    #do american one 
	$transcription = $storetrans;
	$transcription =~ s/\[([^\]]*)1\]/$1/g;
	$transcription =~ s/\[([^\]]*[^1])\]//g;
	$transcription =~ s/\(([^\/]+)\/([^\)]+)\)/$2/g;
	$transcription =~ s/([^ ]+\/)//g;
	$transcription =~ s/([A-Z]+\@*)1/\L$1/g; 
	$transcription =~ s/([A-Z\@]+R)/\@r/g; 
	$transcription =~ s/([A-Z]+\@*)([^0-9A-Z])/\@$2/g; 
	$transcription =~ s/ +/ /g; 
	$transcription =~ s/^ //; 
	$transcription =~ s/ $//; 
	&checksyl;
    }
    else {
	$transcription =~ s/  / /g;	# removing extra spaces
	$transcription =~ s/^ //;
	$transcription =~ s/ $//;
	&checksyl;
    }
}

sub checksyl {
    my @syllables = split (/ \. /,$transcription); # splitting into syllables
    &check_overall_transcription($transcription);
    foreach $syllable (@syllables) {
	&parse_syll($syllable);
    }
    &check_imposs_seq($_);	# don't do on 'transcription' - I need morpheme boundaries back
    if ($found_error == 1) { print "\n";}
}


sub get_rules {
    while (<RULES>){
	if ($_ =~ /^init.*>/) { push (@ruleinit, $'); }
#have added for_init for foreign sequences
	if ($_ =~ /^for_init.*>/) { push (@ruleforinit, $'); }
	if ($_ =~ /^stress.*>/) { push (@rulestress, $'); }
	if($_ =~ /^vowel.*>/) { push (@rulevowel, $'); }
	if ($_ =~ /^for_vowel.*>/) { push (@ruleforvowel, $'); }
	if($_ =~ /^syllcons.*>/) { push (@rulesyllcons, $'); }
	if ($_ =~ /^fin.*>/) { push (@rulefinal, $'); }
#have added for_fin for foreign sequences
	if ($_ =~ /^for_fin.*>/) { push (@ruleforfinal, $'); }
    }	
}

sub get_positions {
#    $posinit{} = "";
#    $posstress{} = "";
#    $posvowel{} = "";
#    $possyllcons{} = "";
#    $posfin{} = "";

    while (<POSI>){
	chop;
	if ($_ =~ /^Cons:([^ ]+) .*\[\+ini\]/) {
	    $posinit{$1} = 1;
	}

	if (($L) || ($M)) {
	    if ($_ =~ /^Cons:([^ ]+).*\[[0\+]syl\]/) { # +syl is for those marked as !, i.e. in derived not base files, may appear in intermediate files
		$possyllcons{$1} = 1;
	    }
	}

	else {
	    if ($_ =~ /^Cons:([^ ]+).*\[\+syl\]/) { # +syl is for those marked as !, i.e. in derived not base files
		$possyllcons{$1} = 1;
	    }
	}

	if ($_ =~ /^Cons:([^ ]+).*\[\+fin\]/) {
	    $posfin{$1} = 1;
	}
	elsif ($_ =~ /^Stress:([^ ]+)/) {
	    $posstress{$1} = 1;
	}
	elsif ($_ =~ /^Vowel:([^ ]+)/) {
	    $posvowel{$1} = 1;
	}
    }	
}

sub parse_syll {
    my ($syll) = @_;
    my $p = 0;   #temporary variables
    my $k = 0;

    if ($DEBUG == 1) { print "\nsyll is \'$syll\'\n"; }
    my @phons = split (/ /,$syll);

# $p is phoneme number, $k is temporary position
    undef @initial;
    for($p=0;$p<=2;$p++) {	# looks at first phoneme, [then next two] 
	if(exists $posinit{$phons[$p]}) {
	    push(@initial, $phons[$p]);
	}
	else { goto Stress; }
    }
  Stress:
    undef @stress;
    if(exists $posstress{$phons[$p]}) {
	push (@stress, $phons[$p]);
	$p++;
    }				

    my $vowel = 0;
    undef @vowel;
    for ($k=$p; $k<=($p+1); $k++) {
	if(exists $posvowel{$phons[$k]}) {
	    $vowel = 1;
	    push (@vowel, $phons[$k]);
	    $p++;
	}				
	else { goto Syllabic; }
    }
  Syllabic:
    undef @syllabic;
    if ($vowel == 0) {	       
	for ($k=($p-1); $k >=0; $k--){
	    $#initial = $#initial - 1; # truncating array
	    if(exists $possyllcons{$phons[$k]}) {
		push (@syllabic, $phons[$k]);
		$p = $k + 1;
		goto Final;
	    }
	}
    }
Final:
    undef @final;
    for($k=$p; $k<= ($p+3); $k++) {
	    if(exists $posfin{$phons[$k]}) {
		push (@final, $phons[$k]);
		$p++;
	    }				
	else { goto End; }
  }
  End:

# double-checking parse
    my $new_syll = join (' ', @initial, @stress, @vowel, @syllabic, @final);
    if ($syll ne $new_syll) {
#hard-wire some exceptions
	if (($wd ne "sh") && ($REPALL == 0)) {
	    print "ERROR, ATTEMPTED PARSE \($new_syll\) DOES NOT MATCH ORIGINAL SYLLABLE \($syll\) IN ENTRY\:\n  $entry";
	    $found_error = 1;
	}
    }

    &check_syll(@initial, @stress, @vowel, @syllabic, @final);
}			      

sub check_imposs_seq {
    my ($trans) = @_;
    $trans =~ s/^[^ ]*//;

#pre-r vowel not followed by r in same morpheme (not sure this is right - can we have the r in another morpheme?)
#scrap the above, change to pre-r vowel not before r

    if ($L)  {
	if (( $trans =~ /[aeiou\@]+r [\$\<\>\=\}\{]*\.[\$\<\>\=\}\{]* [^r]/i)||($trans =~ / [aeiou\@]+r [abcdefghijklmnopqstuvwxyz]/i))  {
	    print "ERROR, IMPOSSIBLE SEQUENCE \'$&\' IN ENTRY\:\n  $entry";
	    $found_error = 1;
	}
    }	

#don't want == or < or > followed by . should be combined instead, in fact don't want sequence of boundaries (separated by space) in base lexicons
    if (($trans =~ /\. [\}\{\>\<\=]/)||($trans =~ /[\}\{\>\<\=] \./) ) {
	print "ERROR, IMPOSSIBLE SEQUENCE \'$&\' IN ENTRY\:\n  $entry";
	$found_error = 1;
    }	
    if (($L) && ($trans =~ /[\}\{\>\<\=] [\}\{\>\<\=]/) ) {
	print "ERROR, IMPOSSIBLE SEQUENCE \'$&\' IN ENTRY\:\n  $entry";
	$found_error = 1;
    }	

#double consonant, when not across double morpheme boundary.  Shouldn't occur within sylls or it would be caught by syllable rules.
    while ($trans =~ s/^([^\.]* )*([a-z]+) ([\>\<\}\{\$\=]*\.[\=\>\<\}\{\$]* )([a-z]+) //) {
	my $tmp2 = $2;
	my $tmp3 = $3;
	my $tmp4 = $4;
	if (($tmp2 eq $tmp4) && (exists $posfin{$tmp2}) && (exists $posinit{$tmp4})) {
	    if (($tmp3 !~ /[\=\}].[\=\{]/) && ($L)) {
		if ($tmp3 !~ /^[\}\>\<\=].[\=\{\>\<] $/) {
		    print "ERROR, IMPOSSIBLE SEQUENCE \'$tmp2 $tmp3$tmp4\' IN ENTRY\:\n  $entry";
		    $found_error = 1;
		}
	    }	
	}	
    }
}


sub check_syll {
    my $initial_match = 0;
    my $foreign_init = 0;
    my $stress_match = 0;
    my $vowel_match = 0;
    my $foreign_vowel = 0;
    my $syllabic_match = 0;
    my $final_match = 0;
    my $foreign_final = 0;
    my $rule = "";

    if ($#initial == 2) {
	foreach $rule(@ruleinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*\+.[^\+]* \Q$initial[1]\E .[^+]*\+.[^\+]* \Q$initial[2]\E .[^\+]*$/) {
		$initial_match = 1;
		if (($DEBUG == 1)) {
		    print "matched initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }
	}
	foreach $rule(@ruleforinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*\+.[^\+]* \Q$initial[1]\E .[^+]*\+.[^\+]* \Q$initial[2]\E .[^\+]*$/) {
		$initial_match = 1;
		$foreign_init = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }
	}
    }
    if ($#initial == 1) {
	foreach $rule(@ruleinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*\+.[^\+]* \Q$initial[1]\E .[^\+]*$/) {
		$initial_match = 1;
		if (($DEBUG == 1)) { 
		    print "matched initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }		       
	}    
	foreach $rule(@ruleforinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*\+.[^\+]* \Q$initial[1]\E .[^\+]*$/) {
		$initial_match = 1;
		$foreign_init = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }
	}
    }
    if ($#initial == 0) {
	foreach $rule(@ruleinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*$/) {
		$initial_match = 1;
		if (($DEBUG == 1)) { 
		    print "matched initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }
	}    
	foreach $rule(@ruleforinit) {
	    if ($rule =~ /^.[^\+]* \Q$initial[0]\E .[^\+]*$/) {
		$initial_match = 1;
		$foreign_init = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign initial \"@initial\" to $rule";
		}
		else {goto STR;}
	    }
	}
    }

    if (($initial_match == 0) && (exists ($initial[0]))){
	print "WARNING - COULDN'T MATCH INITIAL \"@initial\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

  STR:

    if (($foreign_init == 1) && ($REPALL == 1)) {
	print "WARNING - FOREIGN OR UNCOMMON INITIAL \"@initial\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

    if ($#stress == 0) {
	foreach $rule(@rulestress) {
	    if ($rule =~ /^.[^\+]* \Q$stress[0]\E .[^\+]*$/) {
		$stress_match = 1;
		if (($DEBUG == 1)) {
		    print "matched stress \"@stress\" to $rule";
		}
		else {goto VOW;}
	    }
	}
    }
    if (($stress_match == 0) && (exists ($stress[0]))) {
	print "ERROR - COULDN'T MATCH STRESS \"@stress\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

  VOW:
    if ($#vowel == 1) {
	foreach $rule(@rulevowel) {
	    if ($rule =~ /^.[^\+]* \Q$vowel[0]\E .[^\+]*\+.[^\+]* \Q$vowel[1]\E .[^\+]*$/) {
		$vowel_match = 1;
		if ($DEBUG == 1) {
		    print "matched vowel \"@vowel\" to $rule";
		}
		else {goto SYLLAB;}
	    }
	}    
	foreach $rule(@ruleforvowel) {
	    if ($rule =~ /^.[^\+]* \Q$vowel[0]\E .[^\+]*\+.[^\+]* \Q$vowel[1]\E .[^\+]*$/) {
		$vowel_match = 1;
		$foreign_vowel = 1;
		if ($DEBUG == 1) {
		    print "matched foreign vowel \"@vowel\" to $rule";
		}
		else {goto SYLLAB;}
	    }
	}    
    }
    if ($#vowel == 0) {
	foreach $rule(@rulevowel) {
	    if ($rule =~ /^.[^\+]* \Q$vowel[0]\E .[^\+]*$/) {
		$vowel_match = 1;
		if ($DEBUG == 1) {
		    print "matched vowel \"@vowel\" to $rule";
		}
		else {goto SYLLAB;}
	    }
	}    
    }

    if (($vowel_match == 0) &&  (exists ($vowel[0]))) {
	print "WARNING - COULDN'T MATCH VOWEL \"@vowel\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

  SYLLAB:
    if (($foreign_vowel == 1) && ($REPALL == 1)) {
	print "WARNING - FOREIGN OR UNCOMMON VOWEL \"@vowel\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

    if (exists ($syllabic[0])) {
	foreach $rule(@rulesyllcons) {
	    if ($rule =~ /^.[^\+]* \Q$syllabic[0]\E .[^\+]*$/) {
		$syllabic_match = 1;
		if ($DEBUG == 1) {
		    print "matched syllabic \"@syllabic\" to $rule";
		}
		else {goto FIN;}
	    }
	}    
    }
    if (($syllabic_match == 0) && (exists ($syllabic[0]))) {
	print "ERROR - COULDN'T MATCH SYLLABIC \"@syllabic\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

FIN:
    if ($#final == 3) {
	foreach $rule(@rulefinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^n+]*\+.[^\+]* \Q$final[2]\E .[^\+]*\+.[^\+]* \Q$final[3]\E .[^\+]*$/) {
		$final_match = 1;
		if (($DEBUG == 1)) {
		    print "matched final \"@final\" to $rule";
		}
	    }
	}    
	foreach $rule(@ruleforfinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^n+]*\+.[^\+]* \Q$final[2]\E .[^\+]*\+.[^\+]* \Q$final[3]\E .[^\+]*$/) {
		$final_match = 1;
		$foreign_final = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}
    }
    if ($#final == 2) {
	foreach $rule(@rulefinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^+]*\+.[^\+]* \Q$final[2]\E .[^\+]*$/) {
		$final_match = 1;
		if (($DEBUG == 1)) {
		    print "matched final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}    
	foreach $rule(@ruleforfinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^+]*\+.[^\+]* \Q$final[2]\E .[^\+]*$/) {
		$final_match = 1;
		$foreign_final = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}
    }
    if ($#final == 1) {
	foreach $rule(@rulefinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^\+]*$/) {
		$final_match = 1;
		if (($DEBUG == 1)) {
		    print "matched final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}    
	foreach $rule(@ruleforfinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*\+.[^\+]* \Q$final[1]\E .[^\+]*$/) {
		$final_match = 1;
		$foreign_final = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}
    }
    if ($#final == 0) {
	foreach $rule(@rulefinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*$/) {
		$final_match = 1;
		if (($DEBUG == 1)) {print "matched final \"@final\" to $rule"; }
		else {goto DONE;}
	    }
	}    
	foreach $rule(@ruleforfinal) {
	    if ($rule =~ /^.[^\+]* \Q$final[0]\E .[^\+]*$/) {
		$final_match = 1;
		$foreign_final = 1;
		if (($DEBUG == 1)) {
		    print "matched foreign final \"@final\" to $rule";
		}
		else {goto DONE;}
	    }
	}
    }
    if (($final_match == 0) && (exists ($final[0]))) {
	print "WARNING - COULDN'T MATCH FINAL \"@final\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }

  DONE:
    if (($foreign_final == 1) && ($REPALL == 1)) {
	print "WARNING - FOREIGN OR UNCOMMON FINAL \"@final\" IN ENTRY\:\n  $entry";
	$found_error = 1;
    }
}

sub check_overall_transcription {
    my ($trans) = @_;

# checking presence/absence of stresses
    if( ($trans =~ /\*.*\*/) && ($stringmode == 0)) {
	print "ERROR - TWO MAIN STRESSES IN ENTRY\:\n  $entry";
	$found_error = 1;	
    }				 

    if( ($trans =~ /^[^\.]*\*.[^\.]*\..[^\.]*\~[^\.]*$/) ||
       ($trans =~ /^[^\.]*\~.[^\.]*\..[^\.]*\*[^\.]*$/)) {
	print "ERROR - TWO STRESSES ON BISYLLABIC WORD IN ENTRY\:\n  $entry";
	$found_error = 1;	
    }				 

    my $prim = ($trans =~ /\*/);
    my $vowel = ($trans =~ /[aeiou]/);
    my $vowel2 = ($trans =~ /\@\@/);
    if (($prim == 0) && (($vowel == 1) || ($vowel2 == 1)) && ($entry !~ /\,unstressed/)) {
#hard-wire some exceptions
	if (($wd ne "de") && ($wd ne "the") && ($wd ne "to") && ($REPALL == 0)) {
	    print "ERROR - NO PRIMARY STRESS IN ENTRY\:\n  $entry";
	    $found_error = 1;
	}
    }    
    if (($prim == 1) && ($vowel == 0) && ($vowel2 == 0)) {
#hard-wire some exceptions
	if (($wd ne "ahem") && ($wd ne "gonna") && ($wd ne "the") && ($wd ne "huh") && ($REPALL == 0)) {
#nb in some accents schwa and other vowels may merge, giving stressed schwas
	    unless ((($D) || ($M)) && (($towns{$LOC}{REG} eq "WALES") || ($towns{$LOC}{CNY} eq "NZ"))) {
		print "WARNING - PRIMARY STRESS WITHOUT FULL VOWEL IN ENTRY\:\n   $entry";
		$found_error = 1;
	    }
	}
    }    
    elsif ((($trans =~ /[\*~] (\@|iy|uw|ie) /i) || ($trans =~ /[\*~] (\@|ie|iy|uw)$/i))
	&& ($REPALL == 1)) {
	unless ((($D) || ($M)) && (($towns{$LOC}{REG} eq "WALES") || ($towns{$LOC}{CNY} eq "NZ"))) {
	    print "WARNING - STRESSED $1 IN ENTRY\:\n   $entry";
	}
    }
}

my ($bd, $lp);

if ($L) {
    $bd = "base";
}
if ($M) {
    $bd = "intermediate";
}
elsif ($D) {
    $bd = "derived";
}
if ($lex eq "1") {
    $lp = "lexicon";
}
elsif ($lex eq "2") {
    $lp = "pronunciation string";
}
print "\nUnisyn phonotactic checking of $bd $lp finished.\n";


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
