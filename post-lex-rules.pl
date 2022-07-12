#!/usr/bin/perl
#post-lexical rules
#The base lexicon should be run through get_exceptions, before using post-lex-rules or before making pronunciation strings

#need to use 'while (s///)' for rule transformations rather than 's///g' so that all correct matches retained in debug format

#boundaries are roughly:  {} round free morpheme, << or >> round bound morpheme, == at internal boundary where there are no free roots.
#pronunciations in string format file should be linked by word ends # and a syllable boundary

#e.g. horse box #{ h * oo r s }#.#{ b o k s }#   (in string-type file)
#e.g. horsebox { h * oo r s }.{ b o k s }        (in master lexicon file)
#e.g. horses { h * oo r s }.> i z >              (in master lexicon file)
#e.g. horsed { h * oo r s }> t >                 (in master lexicon file)
#e.g. xenophobia { z ~ e . n @ =.= f * ou b }    (in master lexicon file)

#system:
#1 - strip out all numbers, brackets, caps etc.  Reduce to basic keysymbol set.  So, e.g. iu3 converted to either iu or uu.  NB all symbols in caps are vowels.  These conversions are order-dependent, and are mostly context-free.
#2 - post-lexical rules proper.  These rules are ordered.
#The rules are intended to work on both lexicon format and string format.

#use strict;
#use diagnostics;

use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('a:f:i:dr');

our ($opt_a,$opt_f,$opt_i,$opt_d, $opt_r);
my $LOC = $opt_a;
our $IN;			# input file, if used
my (%towns, %rules, %rulescore, %ruleorder, %convert, %convertscore, %convertorder);
my (@debug, @sortconvertorder, @sortruleorder);
my $rule;

#vowel, consonant, symbol groups
my $c = "";
my $c_n_num = "";
my $c_syl = "";
my $c_0_syl = "";
my $c_n_syl = "";
my $c_n_vel = "";
my $c_vel = "";
my $c_nas = "";
my $c_lab = "";
my $c_n_lab = "";
my $c_asf = "";
my $c_drk = "";
my $c_frc = "";
my $c_vce = "";
my $s = "";
my $v = "";
my $v_n_stg = "";
my $v_int = "";
my $v_drk = "";
my $v_n_num = "";
my $v_n_schwa = "";
my $b = "";
my $b_sll = "";
my $b_n_sll = "";
my $b_cmp = "";
my $b_bnd = "";
my $b_isl = "";
my $b_fri = "";
my $b_n_fri = "";
my $b_frf = "";
my $b_frf_n_sll = "";
my $b_wrd = "";
my $b_n_wrd = "";
my $b_utt = "";
my $b_int_sll = "";
my $e = "";

my (%CONS, %VOWL, %STRS, %EXTR, %BOUN);

my ($convert);

#fields in lexicon
my ($entry,$wrd,$sem,$cat,$pro,$aln,$fre);

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS: $!\n";

#rule applications scores listed 
our $SCORES = "$FindBin::Bin/uni_scores";
open (SCORES) || die "Cannot open $SCORES: $!\n";

#this file lists keysymbols and some features for regexp matches
our $POSI = "$FindBin::Bin/uni_positions";
open (POSI) || die "Cannot open $POSI: $!\n";


#check command-line input

&get_towns;

if ( (!$towns{$LOC}) || ((!$opt_f) && (!$opt_i))) {
    print STDERR "\nusage:  post-lex-rules.pl [-dr] -a [towncode] -[fi] [input]\n
-d option prints breakdown of rule use
-r option doesn't remove utterance-final /r/ in linking accents, e.g. rp
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


&get_posi;			# specifies keysymbol sets

&get_scores;			# reads rule scores from file

&get_convert_typology;		# specifies segment conversion typology

&get_rule_typology;		# specifies typology of accents - check new
                                # accents and adjust rule applications here
				# this is a very important function!

#read input, either file or command-line

if ($opt_f){
    $IN = $opt_f;
    open (IN) || die "Cannot open $IN\n";
    
  GETLINE:
    while (<IN>) {
	chop;
	&operate;
    }
}
elsif ($opt_i) {
    my $input = $opt_i;
  GETLINE:
    while ($input =~ s/([^\n]+)//) {
	$_ = $1;
	&operate;
    }
}


#executes transformations
sub operate {
# automatically detects lexicon or string format, gets parts
    if ($opt_d) {
	@debug = "INPUT:  $_\n";
    }
    &get_format;		

    $_ = $pro;

#add extra spaces to facilitate matching
    s/ /  /g;
    
#segment rationalisation, reduces segments to basic set
    &convert_segments;
    
#actual rules
    &post_lex;
    
#could remove bound morpheme boundaries from pron string for easier reading
#    s/\=//g;

#change spaces back
    s/  +/ /g;
    s/^ (\#.*\#) $/$1/g;

#optional printout of rule workings
    if ($opt_d) {
	my $debug = join ('', @debug);
	$debug =~ s/  / /g;
	print "$debug";
        print "OUTPUT:  ";
	undef @debug;
    }
#final output (in string format only $_ will contain data)
    print "$wrd$sem$cat$_$aln$fre\n";
    if ($opt_d) {
	print "\n";
    }
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

#reads scores for rules and conversions from file
sub get_scores {
    my $codecheck;
    while (<SCORES>) {
	if (/^\s*\$(convert|rules).*\{0\}.*;/) {
	    print STDERR "FATAL ERROR:  error in file $SCORES, non-permissible setting 0 for $_";
	}
	elsif (/^\s*\$convert\{(.*)\}\{(.*)\}\{(.*)\} \= ([0-9]+)/) {
	    $convert{$1}{$2}{$3} = $4;
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
	elsif (/^\s*\$convert\{(.*)\}\{ALL\} \= ([0-9]+)/) {
	    $convert{$1}{ALL} = $2;
	}
	elsif (/^\s*\$rules\{(.*)\}\{(.*)\}\{(.*)\} \= ([0-9]+)/) {
	    $rules{$1}{$2}{$3} = $4;
	    $codecheck = 0;
	  CHECKRULE:
	    for my $code (keys %towns) {
		if ($towns{$code}{$2} eq $3) {
		    $codecheck = 1;
		    last CHECKRULE;
		}
	    }
	    if ($codecheck == 0){print STDERR "WARNING:  can't match $2 $3 in file $SCORES, line $_\n";}
	}
	elsif (/^\s*\$rules\{(.*)\}\{ALL\} \= ([0-9]+)/) {
	    $rules{$1}{ALL} = $2;
	}
	elsif (/^\s*\$convertorder\{(.*)\} \= ([^\s]+);/) {
	    if ($convertorder{$1}) {print STDERR "WARNING:  error in file $SCORES, duplicate convertorder \"$1\" for $convertorder{$1} and $2\n";}
	    $convertorder{$1} = $2;
	}
	elsif (/^\s*\$ruleorder\{(.*)\} \= ([^\s]+);/) {
	    if ($ruleorder{$1}) {print STDERR "WARNING:  error in file $SCORES, duplicate ruleorder \"$1\" for $ruleorder{$1} and $2\n";}
	    $ruleorder{$1} = $2;
	}
	elsif (( (/^\s*\$/)|| (/^\s*[^\#\-\s]/)) && ($_ !~ /\$map/)) {
	    print STDERR "WARNING:  can't parse input in file $SCORES, line $_\n";
	}
    }
}


#calls function to get conversion scores, and sorts conversions
sub get_convert_typology {
    @sortconvertorder = sort (keys %convertorder);
    for my $order (@sortconvertorder) {
	$convert = $convertorder{$order};
	&get_convertscore ($convert);
    }
    if ($opt_d) {
	printf "\n";
    }
}


#calls function to get rule scores, and sorts rules
sub get_rule_typology {
    @sortruleorder = sort (keys %ruleorder);
    for my $order (@sortruleorder) {
	$rule = $ruleorder{$order};
	&get_rulescore ($rule);
    }
#tried just storing those with a score above 0, but marginal speed improvement
    if ($opt_d) {
	printf "\n";
    }
}
	
	
#reads symbol features, and uses them to make classes to help specify groups of symbols in regular expressions
sub get_posi {
#all terms must be used within round brackets e.g. ($b) or ($c|$v) when in reg exps
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

#set up groups 
#due to allowable variable names, can't use - sign, have to use _n for negative.  3-letter parameters for consistency

#weak vowels for tap rule
    for my $vowl (keys %VOWL) {
	if ($VOWL{$vowl} =~ /\[\-stg\]/) {
	    $v_n_stg = join ('|', $v_n_stg, $vowl);
	}
    }
    $v_n_stg =~ s/[\@\;]/\\$&/g;	#escape some chars just incase
    $v_n_stg =~ s/^\|//;			
#intrusive vowels, precede intrusive /r/
    for my $vowl (keys %VOWL) {
	if ($VOWL{$vowl} =~ /\[\+int\]/) {
	    $v_int = join ('|', $v_int, $vowl);
	}
    }
    $v_int =~ s/[\@\;]/\\$&/g;	#escape some chars just incase
    $v_int =~ s/^\|//;			
#vowels except |ae|, |oi| and |ai| (for S_US clear l)
    for my $vowl (keys %VOWL) {
	if ($vowl !~ /^(ae|ai|oi)/) {
	    $v_drk = join ('|', $v_drk, $vowl);
	}
    }
    $v_drk =~ s/[\@\;]/\\$&/g;	#escape some chars just incase
    $v_drk =~ s/^\|//;			
#vowels without numbers (used in e.g. segment conversions
    for my $vowl (keys %VOWL) {
	if ($vowl !~ /[0-9]$/) {
	    $v_n_num = join ('|', $v_n_num, $vowl);
	}
    }
    $v_n_num =~ s/[\@\;]/\\$&/g;	#escape some chars just incase
    $v_n_num =~ s/^\|//;			
#vowels which are not @ or @r
    for my $vowl (keys %VOWL) {
	if ($vowl !~ /^(\@r*)$/) {
	    $v_n_schwa = join ('|', $v_n_schwa, $vowl);
	}
    }
    $v_n_schwa =~ s/[\@\;]/\\$&/g;	#escape some chars just incase
    $v_n_schwa =~ s/^\|//;			

#consonants without numbers (used in e.g. segment conversions
    for my $cons (keys %CONS) {
	if ($cons !~ /[0-9]$/) {
	    $c_n_num = join ('|', $c_n_num, $cons);
	}
    }
    $c_n_num =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_n_num =~ s/^\|//;			
#fricatives
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+frc\]/) {
	    $c_frc = join ('|', $c_frc, $cons);
	}
    }
    $c_frc =~ s/^\|//;			
#voiced
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+vce\]/) {
	    $c_vce = join ('|', $c_vce, $cons);
	}
    }
    $c_vce =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_vce =~ s/^\|//;	
#explicitly syllabic consonants 
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+syl\]/) {
	    $c_syl = join ('|', $c_syl, $cons);
	}
    }
    $c_syl =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_syl =~ s/^\|//;			
#not explicitly syllabic consonants (i.e. can have l, m, n but not l! etc
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[[\-0]syl\]/) {
	    $c_n_syl = join ('|', $c_n_syl, $cons);
	}
    }
    $c_n_syl =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_n_syl =~ s/^\|//;			
#potentially syllabic consonants (i.e. l, m, n)
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[[0]syl\]/) {
	    $c_0_syl = join ('|', $c_0_syl, $cons);
	}
    }
    $c_0_syl =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_0_syl =~ s/^\|//;			
#non-velars
    for my $cons (keys %CONS) {
	if ($CONS{$cons} !~ /\[\+vel\]/) {
	    $c_n_vel = join ('|', $c_n_vel, $cons);
	}
    }
    $c_n_vel =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_n_vel =~ s/^\|//;			
#velars
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+vel\]/) {
	    $c_vel = join ('|', $c_vel, $cons);
	}
    }
    $c_vel =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_vel =~ s/^\|//;			
#nasals
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+nas\]/) {
	    $c_nas = join ('|', $c_nas, $cons);
	}
    }
    $c_nas =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_nas =~ s/^\|//;			
#labials
    for my $cons (keys %CONS) {
	if ($CONS{$cons} =~ /\[\+lab\]/) {
	    $c_lab = join ('|', $c_lab, $cons);
	}
    }
    $c_lab =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_lab =~ s/^\|//;			
#non-labials
    for my $cons (keys %CONS) {
	if ($CONS{$cons} !~ /\[\+lab\]/) {
	    $c_n_lab = join ('|', $c_n_lab, $cons);
	}
    }
    $c_n_lab =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_n_lab =~ s/^\|//;			
#alveolar stops and frics
    for my $cons (keys %CONS) {
	if (($CONS{$cons} =~ /\[\+alv\]/) && ($CONS{$cons} =~ /\[\+(frc|stp)\]/)) {
	    $c_asf = join ('|', $c_asf, $cons);
	}
    }
    $c_asf =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_asf =~ s/^\|//;			
#all consonants except |y| for S_US dark l rule
    for my $cons (keys %CONS) {
	if ($cons !~ /^(y)$/) {
	    $c_drk = join ('|', $c_drk, $cons);
	}
    }
    $c_drk =~ s/[\!\?\^]/\\$&/g;	# need to escape some chars
    $c_drk =~ s/^\|//;			
#boundaries including syllable boundary
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+sll\]/) {
	    $b_sll = join ('|', $b_sll, $boun);
	}
    }
    $b_sll =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_sll =~ s/^\|//;			
#boundaries not including syllable boundary
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\-sll\]/) {
	    $b_n_sll = join ('|', $b_n_sll, $boun);
	}
    }
    $b_n_sll =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_n_sll =~ s/^\|//;			
#word internal boundaries with syllable boundary (not at compound joins)
    for my $boun (keys %BOUN) {
	if (($BOUN{$boun} =~ /\[\-wrd\]/) &&($BOUN{$boun} =~ /\[\-cmp\]/) 
	    && ($BOUN{$boun} =~ /\[\+sll\]/) )  {
	    $b_isl = join ('|', $b_isl, $boun);
	}
    }
    $b_isl =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_isl =~ s/^\|//;			
#boundaries at joins within compounds
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+cmp\]/) {
	    $b_cmp = join ('|', $b_cmp, $boun);
	}
    }
    $b_cmp =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_cmp =~ s/^\|//;			
#internal boundaries joining 2 bound or 1 bound, 1 free morphemes (not joins at compounds or free words)
    for my $boun (keys %BOUN) {
	if (($BOUN{$boun} =~ /\[\-wrd\]/) &&($BOUN{$boun} =~ /\[\-cmp\]/))  {
	    $b_bnd = join ('|', $b_bnd, $boun);
	}
    }
    $b_bnd =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_bnd =~ s/^\|//;			

#boundaries noting start of potentially free unit, i.e. a word beginning, whether or not it's a prefix, or a boundary including {, e.g. 'predetermine' has two of these boundaries (needed for e.g. glottal stop rules)
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+fri\]/){
	    $b_fri = join ('|', $b_fri, $boun);
	}
    }
    $b_fri =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_fri =~ s/^\|//;			

#boundaries *not* noting start of potentially free unit
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\-fri\]/){
	    $b_n_fri = join ('|', $b_n_fri, $boun);
	}
    }
    $b_n_fri =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_n_fri =~ s/^\|//;			

#boundaries noting end of potentially free unit (frf = free final), used e.g. in -ing rule, nb can be } or >
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+frf\]/){
	    $b_frf = join ('|', $b_frf, $boun);
	}
    }
    $b_frf =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_frf =~ s/^\|//;			

#boundaries noting end of potentially free unit (frf_n_sll = free final, not syllabic), used e.g. sus_rule
    for my $boun (keys %BOUN) {
	if (($BOUN{$boun} =~ /\[\+frf\]/) && ($BOUN{$boun} =~ /\[\-sll\]/) ){
	    $b_frf_n_sll = join ('|', $b_frf_n_sll, $boun);
	}
    }
    $b_frf_n_sll =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_frf_n_sll =~ s/^\|//;			


#word boundaries (not internal compound boundaries)
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+wrd\]/) {
	    $b_wrd = join ('|', $b_wrd, $boun);
	}
    }
    $b_wrd =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_wrd =~ s/^\|//;			


#word-internal boundaries (with or without syll boundary or compound boundary)
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\-wrd\]/) {
	    $b_n_wrd = join ('|', $b_n_wrd, $boun);
	}
    }
    $b_n_wrd =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_n_wrd =~ s/^\|//;			

#utterance boundaries
    for my $boun (keys %BOUN) {
	if ($BOUN{$boun} =~ /\[\+utt\]/) {
	    $b_utt = join ('|', $b_utt, $boun);
	}
    }
#note that for lexicon format we have included " {" and "} " as utterance boundaries, also " <" and "> "
    $b_utt =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_utt =~ s/^\|//;			

#morpheme boundary with syllable boundary, word internal but not compound
    for my $boun (keys %BOUN) {
	if (($BOUN{$boun} =~ /\[\+sll\]/)  && ($BOUN{$boun} =~ /\[\-cmp\]/) && ($BOUN{$boun} =~ /\[\-wrd\]/) && ($BOUN{$boun} =~ /\[\-utt\]/)) {
	    $b_int_sll = join ('|', $b_int_sll, $boun);
	}
    }
    $b_int_sll =~ s/[\[\]\}\{\>\<\=\.\$\#]/\\$&/g; # need to escape all chars
    $b_int_sll =~ s/^\|//;			

}


	
#determines and checks format of input
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
	    print STDERR "Bad lexicon format, line $entry, word field $wrd;\n";
	    next GETLINE;
	}
	if ($cat !~ /^[A-Z\/\|\$]+:$/) {
	    print STDERR "Bad lexicon format, line $entry, cat field $cat;\n";
	    next GETLINE;
	}
	if ($pro !~ /^($c|$v|$s|$b|$e| )+$/) {
	    print STDERR "Bad lexicon format, line $entry, pron field $pro\n";
	    next GETLINE;
	}
    }
#for strings of prons, taken straight from base lexicon and joined with syllable markers, e.g. /#{ h * or r s }#.#{ r * ee s }#/
#note hash here, not in compounds e.g. / { h * or r s }.{ r * ee s } /
    elsif ($_ !~ /:/) {
	$_ =~ s/^(.*)$/ $1 /;
	$wrd = "";
	$sem = "";
	$cat = "";
	$pro = $_;
#correct any errors with spaces at beginning and end - leave other errors to be tracked
	$pro =~ s/^([^ ])/ $1/;
	$pro =~ s/([^ ])$/$1 /;
	$pro =~ s/ +$/ /;
	$pro =~ s/^ +/ /;
	$aln = "";
	$fre = "";
	$entry = $_;
	if ($pro !~ /^ (($b_wrd)($c|$v|$s|$b|$e| )+)+($b_wrd) $/) {
	    print STDERR "Bad string format for post-lex-rules, line $entry\n";
	    next GETLINE;
	}
    }
    else {
	print STDERR "Bad lexicon format, line $_\n";
	next GETLINE;
    }
}

sub convert_segments {
#this mostly converts single segments in certain format conventions, to reduce to basic keysymbol set; most rules are context-free
#formats to be altered are square brackets, capitals, numbers, round brackets, forward slashes
#a few of the alterations convert sequences, e.g. iu in Welsh
# mostly uk or us-wide but some are for smaller areas.  
#nb some of these symbols may also be used for style variation - don't worry about that at present
#these rules are order-dependent, and this function must precede all other rule functions
#beware of using 'else's' with scores in case future additions require more refinements, elsif is preferred

    if ($opt_d) {push (@debug, "    convert_segments\n");}
    for my $order (@sortconvertorder) {
	$convert = $convertorder{$order};
	if ($opt_d) {push (@debug, "       $convert\n");}
#do all
	&$convert;		# seems unlikely but works... 
                                # (though not under 'use strict')
#do not specify &correct_bounds each time here - for speed, just specified for rules where it's needed
    }

    &conv_general;    #these apply to all accents (syllabics etc).
}

sub post_lex {
#list of rules
#must follow convert_segments
#rules are ordered

    if ($opt_d) {push (@debug, "   post_lex\n");}
    for my $order (@sortruleorder) {
	$rule = $ruleorder{$order};
	if ($opt_d) {push (@debug, "       $rule\n");}
#do those with positive score
	if ( $rulescore{$rule} > 0) {
	    &$rule;		# seems unlikely but works...
                                # (except under use 'strict')
	}
    }

}

sub do_sus_velar {
    if ($rulescore{$rule} == 1) {		
#in southern us, /i/ before velar becomes /ei/
	while (s/ i  ($c_vel) / ei  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#in southern us, /e/ before g becomes /ei/
	while (s/ e  (g) / ei  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_sus_weak {
#in southern us, final syllable /uu/ (or /iu/) or /ou/ (or /ouw/) (of free morpheme?) reduced to schwa, e.g. volume
#insert /w/ if it's before a vowel
#need to insert syllable boundary if it's before schwa and there is no boundary already
     if ($rulescore{$rule} == 1) {		
	 while (s/ ($c|$b)  (uu|ou[wu]*)  ((($b_n_wrd)  )*($b_frf_n_sll))  (\@r*) / $1  @  $3  \. w  $7 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
#fix syllable boundaries
	     &correct_bounds;
	 }
	 while (s/ ($c|$b)  (uu|ou[wu]*)  ((($b_n_wrd)  )*($b_frf))  (\@r*) / $1  @  $3  w  $7 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
	 while (s/ ($c|$b)  (uu|ou[wu]*)  ((($c|$b_n_wrd)  )*($b_frf))  ($v|$s) / $1  @  $3  w  $7 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
	 while (s/ ($c|$b)  (uu|ou[wu]*)  ((($c|$b_n_wrd)  )*($b_frf)) / $1  @  $3 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
    }
 }


sub do_sus_break {
# schwa offglide after front lax vowels in stressed monosyllable before labial
# haven't done a variable for this vowel set
# can also do before sh, zh, g, ng, not necessarily in monosyllable (but word-internal, and stressed?)  let's not do this set - wells says tend to be stigmatised
     if ($rulescore{$rule} == 1) {		
#in southern us, /i/ before velar becomes /ei/
	while (s/(\#[^\.]*  ($s)  (i|e|a|ah|oa))  (($c_lab)  [^\.]*\#)/$1  @  $4/) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_sus_strut_nurse {
#merge except before labial
#(free?-)morpheme final /ng/ is /ng g/
    if ($rulescore{$rule} == 1) {		
	while (s/ uh  ($c_n_lab|$b_n_wrd) / \@\@r  $1 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_aai_oow {
# ai/ae becomes monophthongal aai except before voiceless consonant in same syllable (i.e. it transforms before voiced consonant or syll boundary
    if ($rulescore{$rule} == 1) {		
	while (s/ (ai|ae)  ($c_vce|$b_sll) / aai  $2 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ (ow)  ($c_vce|$b_sll) / oow  $2 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_ng_ngg {
#from wells
#(free?-)morpheme final /ng/ is /ng g/
     if ($rulescore{$rule} == 1) {		
	 while (s/ ng  \}/ ng  g  \}/) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
     }
}

sub do_e_i {
#from wells
    if ($rulescore{$rule} == 1) {		
	while (s/ e  ($c_nas) / i  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_vless_plural {
#from Tench 1990, English in Abercrave
#allowing for word-final and compound-boundary

    if ($rulescore{$rule} == 1) {		

#for plurals
#nb this version does verbs as well - no access to categories
	while (s/ ($v)  \}\>  z  \>/ $1  \}\>  s  \>/) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#change /dh s/ to /th s/ in words like 'baths'
	while (s/ dh  \$\}\>  z  \>/ th  \}\>  s  \>/) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_h_drop {
#all dropped
     if ($rulescore{$rule} == 1) {		
	 while (s/ h //) {
	     if ($opt_d) { &debug_format(__LINE__); }
#need to make 'a' into 'an' in connected speech
	     while (s/ ($b_wrd)  (\@)  ($b_wrd)  ($v|$s) / $1  $2  n  $3  $4 /) {
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
#change to/the realisations to pre-vocalic realisations
	     while (s/ ($b_fri)  (dh)  \@  ($b_frf)(\.*)($b)  ($v|$s) / $1  $2  ii  $3$4$5  $6 /) { # 'the'
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
	     while (s/ ($b_fri)  (t)  \@  ($b_frf)(\.*)($b)  ($v|$s) / $1  $2  uu  $3$4$5  $6 /) { # 'to'
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
	}
    }
}

sub do_short_ii {
#make unstressed /ii/ into something that will result in phonetic [i] not [i:]
     if ($rulescore{$rule} == 1) {		
# unstressed /ii @/ is always /iy @/, (or /ie @/ for rulescore 2), unstressed /ii/ before vowel is always /iy/ or /ie/
	while (s/ ($c|$b|$v)  ii  ((($b_bnd)  )*($v|$s)) / $1  iy  $2 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

    elsif ($rulescore{$rule} == 2) {		
# unstressed /ii @/ is /ie @/,  unstressed /ii/ before vowel is /ie/
	while (s/ ($c|$b|$v)  ii  ((($b_bnd)  )*($v|$s)) / $1  ie  $2 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#/iy/ before vowel in same word, e.g. 'happier', or previous word e.g. 'happy hour' - transcribed as /iy/ for morpheme equivalence, but is in fact always [i] not [i:].  transform to /ie/
	while (s/ iy  ((($b)  )*($s|$v)) / ie  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}


sub do_uw {
     if ($rulescore{$rule} == 1) {		
#make unstressed /uu/ into something that will result in phonetic [u] not [u:]
# unstressed /uu @/ is always /uw @/, unstressed /uu/ before vowel is always /uw/ if it follows or precedes a stressed syllable and is not in last syllable of word
	 while (s/ ($c|$b)  uu  ((($b_bnd)  )*(\@r*)) / $1  uw  $2 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
#follows stressed syll, not in word final syll
	 while (s/ (($s)  ($v)  (($c|$b)  )+)uu  ((($c|$b_bnd)  )*($v|$s)) / $1uw  $6 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
#precedes stressed syllable
	 while (s/ ($c|$b)  uu  ((($c|$b_bnd)  )+($s)) / $1  uw  $2 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
#change iu too for some accents
	 if ($convertscore{conv_iu} == 1) { 
	     while (s/ ($c|$b)  iu  ((($b_bnd)  )*(\@r*)) / $1  uw  $2 /) {
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
#follows stressed syll, not in word final syll
	     while (s/ (($s)  ($v)  (($c|$b)  )+)iu  ((($c|$b_bnd)  )*($v|$s)) / $1uw  $6 /) {
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
#precedes stressed syllable
	     while (s/ ($c|$b)  iu  ((($c|$b_bnd)  )+($s)) / $1  uw  $2 /) {
		 if ($opt_d) { &debug_format(__LINE__); }
	     }
       }
   }
}

sub do_y_insert {
     if ($rulescore{$rule} == 1) {		
#y inserted before initial /@@r/, /er/ (also replaces /h/, but this follows on from h-dropping
#y before /ir/ done in do_ur_ir
	 while (s/ ($b_cmp|$b_wrd)  (($s)  )*\@\@r / $1  y  $2\@\@r /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
	 while (s/ ($b_cmp|$b_wrd)  (($s)  )*er / $1  y  $2er /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
     }
}

sub do_hurry_furry {
     if ($rulescore{$rule} == 1) {		
#all changed
	 while (s/ uh  ((($b_bnd)  )*r) / \@\@r  $1 /) {
	     if ($opt_d) { &debug_format(__LINE__); }
	 }
    }
}


sub do_ou_l {
#no boundaries allowed between /ou/ and /l/, either syllable or morpheme
#(c.f. holey and holy, differentiated in some accents)
#nb also do ouw and lw
    if ($rulescore{$rule} == 1) {		
	while (s/ ouw*  (lw*) / oul  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#also applies to uu (see urban voices CD)
	while (s/ uu  (lw*) / uul  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
#some accents do not differentiate them - allow internal boundaries
    if (($rulescore{$rule} == 2) || ($rulescore{$rule} == 3)){
	while (s/ ou  (($b_bnd)  )*(lw*) / oul  $1$3 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}

#other neutralisations - /uh/ -> /o/ _lC
#/e/ -> /a/ _l
#/uu/ -> /uul/ _l
#environments etc. may vary by person, age etc.
	if ($rulescore{$rule} == 3) { 
	    while (s/ uh  (($b_bnd)  )*(lw*)  ((($b_bnd)  )*($c)) / o  $1$3 $4 /) {
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	    while (s/ e  (($b_bnd)  )*(lw*) / a  $1$3 /) {
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	    while (s/ uu  (($b_bnd)  )*(lw*) / uul  $1$3 /) {
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}

    }
}

sub do_class {
#ah usually 'trap' in cardiff, but 'palm' before fricative
    if ($rulescore{$rule} == 1) {		
	while (s/ ah  ((($b_n_wrd)  )*($c_frc)) / aa  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_t_r {
    if ($rulescore{$rule} == 1) {		
#applied to words and compounds
#previous segment must be one of a few short vowels
#not sure if category is a factor, but can't access category unless scripts are implemented differently
	while (s/ (u|uh|e|o|i)  t  ($b_wrd|$b_cmp)  ($v|$s) / $1  r  $2  $3 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}


sub do_ur_ir {
#precedes non-rhotic - necessary, but simplest for rule formation

#Wells says that for N_UK rule applies to monosyllables
#I'm extending it (after checking with Leeds speaker) to all unit-final /ir/ that doesn't precede /r V/

#rule applies to ur, ir, and iur
#(iur produced from ur as a conversion)

#ir, ur, iur realised as monophthongs in other environments in these accents - don't need an allophone

#consonant cluster in australian
    if ($rulescore{$rule} == 3) {		
	while (s/ (i)r  r  ((($b_n_sll)  )*($c)) / $1$1r  r  $2 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}	    
    }
#/ir/ in monosyllabic roots in welsh pronounced as /y @@r/, e.g. 'beer'
    if ($rulescore{$rule} == 2) {		
#don't add /y/ if it follows /y/ (nb if it's initial the first match will match boundary
	while (s/ ([^y$s]+  )(($s)  )*(i)r  r  ((($c)  )*($b_frf)) / $1y  $2\@\@r  r  $5 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}	    
	while (s/ (($s)  )*(i)r  r  ((($c)  )*($b_frf)) / $1\@\@r  r  $4 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}	    
    }
    if ($rulescore{$rule} <= 3) {		
#word-finally or in word-final consonant cluster (all left over matches)
	while (s/ (i)r  r  ((($b_n_sll)  |($c)  )*($b_wrd)) / $1$1  \@r  r  $2 /) { 	
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#only /ir/ in australian, not /ur/, so omit australian here
	if ($rulescore{$rule} <= 2) {		
	    while (s/ (iu)r  r  ((($b_n_sll)  |($c)  )*($b_wrd)) / $1  \@r  r  $2 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	    while (s/ (u)r  r  ((($b_n_sll)  |($c)  )*($b_wrd)) / $1$1  \@r  r  $2 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}
	
#Wells doesn't mention these:
#let's also do those with derivational endings beginning in a consonant, e.g. beardless, cheerful, demurely
	if ($rulescore{$rule} == 2) {		
	    while (s/ (i)r  r  ((($b_n_sll)  |($c)  )*($b_frf)  ($c)) / \@\@r  r  $2 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }	    
	}
#all left-over matches
	while (s/ (i)r  r  ((($b_n_sll)  |($c)  )*($b_frf)  ($c)) / $1$1  \@r  r  $2 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}

#again, omit australian here
	if ($rulescore{$rule} <= 2) {		
	    while (s/ (iu)r  r  ((($b_n_sll)  |($c)  )*($b_frf)  ($c)) / $1  \@r  r  $2 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	    while (s/ (u)r  r  ((($b_n_sll)  |($c)  )*($b_frf)  ($c)) / $1$1  \@r  r  $2 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}
    }
#southern us, /ir/ is /ii @/ before r + word boundary or cons, stays /ir/ before r + V
    if ($rulescore{$rule} == 4) {		
	while (s/ ir  ((($b_n_wrd)  )*r  ($b_wrd|$b_cmp|$c)) / ii  @  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ ir  ((($b_n_wrd)  )*r  ($b_n_wrd)  ($c)) / ii  @  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_ur_or {
#applies to environments other than before /r V/, i.e. /r/ followed by consonant or word/compound boundary
#should precede non_rhotic rule
#tour = tor

    if ($rulescore{$rule} == 1) {		
	while (s/ ur  ((($b_bnd)  )*(r  )((($b_bnd)  ($c))|($b_wrd)|($b_cmp))) / or  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($rulescore{$rule} == 2) {		
	while (s/ ur  ((($b_bnd)  )*(r  )((($b_bnd)  ($c))|($b_wrd)|($b_cmp))) / our  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_glottal_stop {
#need to use morpheme boundaries in this - note implications for names, 'newtown' must be two free morphemes if it is to block glottal stop, c.f. 'newton' with glottal stop
#used after syllabic, e.g. seventy
#reid - environments in edinburgh: order of incidence is (from low to high) word-medial (intervocalic?), word-final before vowel, word-final before pause, word-final before consonant.  Learned words affect likelihood?
#see macaulay and Trevelyan for glasgow (not yet included)

#the following from murray (abd1)
#gs used before syllabics, before medial unstressed vowels, syllable-finally before consonants, after a vowel and word-finally.  Not used in syllable-initial clusters, before stressed vowels.  Final clusters - used after nlr or syllabic, not used after m,f,s,k,ch,sh,th.  NB may be used before a cons in these cases, or t deleted - test is what is used before a vowel
#only environments where it doesn't occur are before stress in the same word, or word-initially or in syllable-initial clusters
#not sure if two in one word is really ok

    if ($rulescore{$rule} == 1) {		# for general scots (from murray)
# after vowel or some consonants, preceding compound or word boundary
	while (s/ ($v|$c_syl|n|l|r)  (($b_n_sll)  )*t  ($b_cmp|$b_wrd) / $1  $2\?  $4 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
# after vowel or some consonants, syllable-final before an unstressed vowel or a consonant ($b_sll is boundary including a syllable boundary or word end)
	while (s/ ($v|$c_syl|n|l|r)  (($b)  )*t  ($b_sll)  ($v|$c) / $1  $2\?  $4  $5 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
# after vowel or some consonants, can be syllable-initial (but not word-initial or free-morpheme-initial) before an unstressed weak vowel, e.g. twenty
# $b here is overgeneral - intended for ==, but also covers boundaries specified in some other examples, e.g. word-ends; this doesn't matter
	while (s/ ($v|$c_syl|n|l|r)  (($b_n_fri)  )*t  (($b)  )*($v_n_stg) / $1  $2\?  $4$6 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#in final clusters
	while (s/ ($v|$c_syl|n|l|r)  (($b_n_fri)  )*t  (($b_n_fri)  )*(s|th) / $1  $2\?  $4$6 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#before syllabic cons
	while (s/ ($v|$c_syl|n|l|r)  (($b)  )*t  (($b)  )*($c_syl) / $1  $2\?  $4$6 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

#2 is Cardiff (from Wells
    if ($rulescore{$rule} == 2)  {
#before syllabic n
	while (s/ ($v|$c_syl|n|l|r)  (($b)  )*t  (($b)  )*(n\!) / $1  $2\?  $4$6 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#word-final before pause or consonant (Mees)
#let's make it after a vowel
	while (s/ (($v)  (($b)  )*)t  (($b_utt)|(($b_wrd)  ($c))) / $1  \?  $5 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_ing {
#nb need b_frf boundary in matches to distinguish e.g. willingly from re-incarnation

# for e.g. scotland, includes syllabic /n/
    if (($rulescore{$rule} == 2)){ 
#/i ng/ may or may not follow syllable division (eat-ing, pu-dding), must be unstressed

#some go to syllabic, let's try this for a likely set
#these two rules ordered re each other
#nb these rules needn't be ordered re glottal stop rule
	while (s/ ($v|s|sh|l|n|r)  (($b)  )*(t|\?|d|s|z|f|v|th|dh)  (($b)  )*i  ng  ($b_frf) / $1  $2$4  $5n\!  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

#leftovers to /i n/
    if (($rulescore{$rule} == 1) || ($rulescore{$rule} == 2)){ 
	while (s/ ($c|$v)  (($b)  )*i  ng  ($b_frf) / $1  $2i  n  $4 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}


sub do_dark_l {
    if ($rulescore{$rule} == 1) {		# for rp etc.
#dark utterance-finally
	while (s/ ll*  ($b_utt) / lw  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#dark word-finally before consonant in next word, or before consonant in same word
#blocked by vowel in next word, c.f. 'feel that' vs 'feel it'
#rule out syllable-initial cluster, i.e. /l y/, /l w/
	while ((/ (ll*)  (($b)  )*($c) /) && ($4 ne "y")&& ($4 ne "w")){
	    s/ ll*  ((($b)  )*($c)) / lw  $1 /;
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#can have l y, l w across a syll boundary, e.g. 'elwyn'
	while (s/ (ll*)  (($b_sll)  )($c) / lw  $2  $4 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#'value' etc. done as clear l, but maybe variable
    }

#as 1 but retains ll - not sure if this actually occurs in these environments
    if ($rulescore{$rule} == 4) {		# for cardiff
#dark utterance-finally
	while (s/ l  ($b_utt) / lw  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#dark word-finally before consonant in next word, or before consonant in same word
#blocked by vowel in next word, c.f. 'feel that' vs 'feel it'
#rule out syllable-initial cluster, i.e. /l y/, /l w/
	while ((/ (l)  (($b)  )*($c) /) && ($4 ne "y")&& ($4 ne "w")){
	    s/ l  ((($b)  )*($c)) / lw  $1 /;
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#can have l y, l w across a syll boundary, e.g. 'elwyn'
	while (s/ (l)  (($b_sll)  )($c) / lw  $2  $4 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#'value' etc. done as clear l, but maybe variable
    }

    if ($rulescore{$rule} == 2) {		# for general american
#from wells:
#relatively clear preceding a stressed vowel (assume must follow vowel or word boundary, not consonant)
#dark elsewhere:

#preceding unstressed vowel
	while (s/ ll*  (($b)  )*($v) / lw  $1$3 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#preceding consonant
	while (s/ ll*  (($b)  )*($c) / lw  $1$3 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#word final
	while (s/ ll*  ($b_wrd) / lw  $1 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }

    if ($rulescore{$rule} == 3) {		# for southern us
#clear between vowels, or after /ai/, /oi/, or before /y/.  Make it clear before any vowels (not sure about this one), unless it's word-final
#let's say it's clear preceding vowel in next word

#dark elsewhere

#unlike rest of US, not dark before unstressed vowel - leave clear

#dark word-finally or pre-consonantally
#NB mustn't follow |ae|, |oi|, |ai|, or precede |y|

#needed to set variables to do this over sentences: $c_drk and #c_drk
	while (s/ ($v_drk)  (($b)  )*ll*  (($b_wrd)  ($c)|($b_utt)|($c_drk)) / $1  $2lw  $4 /) { 
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }

}

sub do_us_eh {
#applies to /ah/ and /a/, and /oa/
#lots of groups here, don't match up neatly with natural classes so haven't set up variables
#done for monosyllables and their derivatives, though there are some counterexamples to this (see Wells) 
#bounded by free-initial and free-final boundaries

    if ($rulescore{$rule} > 0) {		# rulescore 1 not yet used
#environment before /m/, /n/
	while (s/ ($b_fri)  ([^\.]+  )*(ah|a|oa)  (($b_n_wrd)  )*(m|n)  ($b_frf) / $1 $2 eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    if ($rulescore{$rule} > 1) {
#environment before /f/, /th/, /s/
	while (s/ ($b_fri)  ([^\.]+  )*(ah|a|oa)  (($b_n_wrd)  )*(f|th|s)  ($b_frf) / $1  $2eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    if ($rulescore{$rule} > 2) {
#environment before /d/, /b/, /g/, /sh/
	while (s/ ($b_fri) ([^\.]*) (ah|a|oa)  (($b_n_wrd)  )*(d|b|g|sh)  ($b_frf) / $1 $2 eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    if ($rulescore{$rule} > 3) {
#environment before /v/, /z/
	while (s/ ($b_fri) ([^\.]*) (ah|a|oa)  (($b_n_wrd)  )*(v|z)  ($b_frf) / $1 $2 eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    if ($rulescore{$rule} > 4) {
#environment before /p/, /t/, /k/
	while (s/ ($b_fri) ([^\.]*) (ah|a|oa)  (($b_n_wrd)  )*(p|t|k)  ($b_frf) / $1 $2 eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    if ($rulescore{$rule} > 5) {
#environment before /l/
	while (s/ ($b_fri) ([^\.]*) (ah|a|oa)  (($b_n_wrd)  )*(l|lw)  ($b_frf) / $1 $2 eh  $4$6  $7 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_i_reduction {

#for australian english, change unstressed /i/ to /@/ unless before a velar
#i.e. preceded by consonant, or boundary
#should follow -ing reduction in case I want to add broad australian
#should precede tap rule
    if ($rulescore{$rule} == 1) {
	while (s/ (($c)|($b))  i  (($b_bnd)  )*($c_n_vel) / $1  \@  $4$6 /) {  
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }
}

sub do_syllab {
#should follow i_reduction for aus
#let's make it after alveolar stops and frics following a stressed vowel
#let's include glottal stop
#need a check to see if accent is non-rhotic, and include @r (though accent must be non-rhotic to get sequence @r n)
    if ($rulescore{$rule} == 1) {
#consequential change to syllabics
	while (s/ (($s)  ($v)  (($b_n_wrd)  )*($c_asf|\?)  (($b_n_wrd)  )*)@  n / $1n! /) {  
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#let's do /s/, /z/ whether after stressed vowel or not
	while (s/ ((($b_n_wrd)  )*(s|z)  (($b_n_wrd)  )*)@  n / $1n! /) {  
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
	if ($rulescore{do_non_rhotic} > 0) {
	    while (s/ (($s)  ($v)  (n  )*(($b_n_wrd)  )*($c_asf|\?)  (($b_n_wrd)  )*)\@r  n / $1n! /) {  
		if ($opt_d) { 	&debug_format(__LINE__);	 }
	    }
#NB many of these already reduced under non-rhotic rule.  Can't currently find any examples
	    while (s/ ((($b_n_wrd)  )*(s|z)  (($b_n_wrd)  )*)\@r  n / $1n! /) {  
		if ($opt_d) { 	&debug_format(__LINE__);	 }
	    }
	}
    }
}

sub do_taps {
#US
    if ($rulescore{$rule} == 1){
#at present haven't allowed t/d which follows an initial word or free morpheme boundary
#following vowel, n or r preceding unstressed weak vowel or syllabic l, any intervening boundaries allowed after t/d, mustn't be word/compound/free morph boundary before, i.e. can only have $b_n_fri
#INCLUDE L E.G. FAULTY?
	while (s/ ($v|n|r)  (($b_n_fri)  )*[td]  (($b)  )*(l\!|$v_n_stg) / $1  $2t\^  $4$6 /) { 
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#intervocalic, stressed or unstressed, t/d preceding word/compound boundary e.g. 'not always'
#NB scope overlaps with previous rule
	while (s/ ($v)  (($b_n_fri)  )*[td]  (($b_wrd|$b_cmp)  )(($s)  )*($v) / $1  $2t\^  $4$6$8 /) { 
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }

#Cardiff, t only, intervocallically
    if ($rulescore{$rule} == 2) { 
	while (s/ ($v|n|r)  (($b_n_fri)  )*[t]  (($b)  )*(l\!|$v_n_stg) / $1  $2t\^  $4$6 /) { 
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
#intervocalic, stressed or unstressed, t/d preceding word/compound boundary e.g. 'not always'
#NB scope overlaps with previous rule
	while (s/ ($v)  (($b_n_fri)  )*[t]  (($b_wrd|$b_cmp)  )(($s)  )*($v) / $1  $2t\^  $4$6$8 /) { 
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }


#Ireland
    elsif ($rulescore{$rule} == 3) {
# this is for intervocalic t before word-boundaries or compound boundaries only, stressed or not
# not sure whether d is exactly the same, just done t
	while (s/ ($v)  (($b_n_fri)  )*t  (($b_wrd|$b_cmp)  )(($s)  )*($v) / $1  $2t^  $4  $6$8 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }
#AUS - /t/ voiced between vowels - call it a tap - Wells not sure if it is the same as /d/.  No more info - let's assume not word-initial (or compound initial, or free morph initial) or before stressed vowel within word.  Can precede stressed vowel in another word
    elsif ($rulescore{$rule} == 4) {
# this is for intervocalic t
	while (s/ ($v)  (($b_n_fri)  )*t  (($b)  )*($v) / $1  $2t^  $4$6 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
	while (s/ ($v)  (($b_n_fri)  )*t  ($b_wrd)  (($s)  )*($v) / $1  $2t^  $4  $5$7 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }
}

sub do_tapped_r {
#realisation can vary by position
#romaine edinburgh, word-final r likely to be approx before pause or word-end+cons, tap before word-end+vowel.  What about other r's? 
#murray:  

#approx word-finally before pause or consonant in next word, e.g. car, car park
#approx in syll-final cluster, e.g. card
#tap word-initially

#tap word-internally intervocalically, tap before vowel in next word, e.g. hurry, car alarm
#taps word-initially
#taps variable in initial clusters, e.g. drain, true.  Mainly dependent on cons, possibly to some extent on vowel - base rules on cons

#let's do intervocalic for all
#am assuming other word-initial r's follow cluster rules
    if (($rulescore{$rule} == 1) || ($rulescore{$rule} == 2) ||
	 ($rulescore{$rule} == 3) ){
#tap between two vowels, regardless of boundary and stress
	while (s/ ($v)  (($b)  )*r  (($b)  )*(($s)  )*($v) / $1  $2t\^  $4$6$8 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

    if (($rulescore{$rule} == 1) || ($rulescore{$rule} == 2)){
#tap word-initially
	while (s/ ($b_utt)  r / $1  t\^ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

#for murray, abd1
    if ($rulescore{$rule} == 2){
#tap at start of free-unit, e.g. 'unreal' (not sure about this - maybe just tap at start of initial word in string, perhaps others go by cluster rule)
	while (s/ ($b_fri)  r / $1  t\^ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#initial clusters:
#mostly approx after:  t, k, g, sh
#generally seems to be a tap after:  f, v, p, b, d, th.  However, varies somewhat.  Word boundary taken care of elsewhere
	while (s/ (th|f|v|p|b|d)  (($b_n_wrd)  )*r / $1  $2t\^ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub do_scots_long {

#must be stressed (includes tertiary stress for compounds) 
#many articles on this, I'm following Scobbie, Hewlett and Turk in Urban Voices and only applying rule to /ii/ and /uu/.  (Also need to cover /ir/ and /ur/, and /iu/)  Applies in theory to /u/, but don't seem to be any examples.  Don't need to do /iy/ as always unstressed
#They include /ai/ but /ae/ already noted in lexicon
#(could add a rule or /ai/-/ae/ due to variability by class - see Scobbie et al for e.g. crisis, hydro)
#morphological condition:  applies to morpheme-final vowels (free morphs only)
#consonantal condition:  applies to vowels before voiced fricative or r when consonant is morpheme final (free morphs only)
#hiatus:  applies to vowels before other vowels (Agutter 1988)

#nb Murray claimed to say near and neat the same, but I haven't excluded vowels before /r/
# morphological condition, i.e. free-morph final - no variable set for this

    if ($rulescore{$rule} == 1) {		
	while (s/ ($s)  (ii|ir|uu|ur|u|iu)  \}/ $1  $2;  \}/) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
# consonantal condition - before certain consonants which are free-morph final
# intervening boundary such as == is unlikely but included, occurs in e.g. news
	while ( (/ ($s)  (ii|ir|uu|ur|u|iu)  (($b)  )*($c)  \}/) &&
		(($5 eq "r") || 
		 ($CONS{$5} =~ /\[\+vce\].*\[\+frc\]/))) { 
	    s/ ($s)  (ii|ir|uu|ur|u|iu)  (($b)  )*($c)  \}/ $1  $2;  $3$5  \}/;
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
# hiatus
	while (s/ ($s)  (ii|ir|uu|ur|u|iu)  (($b)  )*($v) / $1  $2;  $3$5 /) {
	    if ($opt_d) { &debug_format(__LINE__);	 }
	}
    }
#switch /iu;/ to /uu;/
    while (s/ iu; / uu; /) {
	if ($opt_d) { &debug_format(__LINE__);	 }
    }
}

sub do_ty_dy {
#for now, let's try converting all unstressed '[td] y' to 'ch/jh'
#might want some '[td] y' retained for formal styles at later date
#what about word- or free-morpheme initial?  but can even have in stressed word-initial position, e.g. 'tune'.  However, for now let's block these, i.e. must follow plain syll boundary (syll boundary blocks rule, e.g. 'courtyard'
#some stressed sylls also follow this rule, e.g. multiTUDinous, so these included
#let's avoid cross-word-boundaries

    if ($rulescore{$rule} == 1) {		
#done as separate matches so some can be split off at a later date if desired
#all syllable-initial [td] y in unstressed syllables, except free-morpheme initial
	while (s/ ($b_n_fri)  t  (($b_n_fri)  )*y  ($v) / $1  ch  $2$4 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ ($b_n_fri)  d  (($b_n_fri)  )*y  ($v) / $1  jh  $2$4 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#let's also do internal [td] y preceding stressed syllables where they are syllable initial and precede /ur/, e.g. mature
	while (s/ ($b_isl)  t  (($b_n_fri)  )*y  (($s)  ur) / $1  ch  $2$4 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ ($b_isl)  d  (($b_n_fri)  )*y  (($s)  ur) / $1  jh  $2$4 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#let's add in 's t y' in unstressed syllables except free-morpheme initial
	while (s/ ($b_n_fri)  s  t  (($b_n_fri)  )*y  ($v) / $1  s  ch  $2$4 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
#correct syllable boundaries
	    while (s/\.(.{0,1})  s  ch /$1  s  \.  ch /) { 
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}
    }
#cardiff, change all word-internal /t iu/ and /d iu/, including word initial
#could do cross-word as well, but haven't
    if ($rulescore{$rule} == 2) {		
	while (s/ t  (($s)  )*iu / ch  $1uu /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ d  (($s)  )*iu / jh  $1uu /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}



sub do_non_rhotic {
# non-rhotic nonlinking
#nb /r/ occuring alone in a morpheme will result in an empty morpheme (boundaries retained for matching with orthog)

    if ($rulescore{$rule} == 1) {
#remove all rhotic r's in non-linking accents, before consonant, or before any word boundary (b_wrd includes utterance boundary) or any internal compound boundary regardless of following keysymbol
	while (s/ r  ((($b)  )*($c|$b_wrd|$b_cmp)) / $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

#nonrhotic linking (2) or nonrhotic linking with intrusive /r/ (3)
    elsif (($rulescore{$rule} == 2)|| ($rulescore{$rule} == 3)) { 
#remove pre-consonantal rhotic /r/ in linking accents, regardless of boundary
	while (s/ r  ((($b)  )*($c)) / $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#remove utterance-final /r/ in linking accents, unless opt_r was selected
	unless ($opt_r) {
	    while (s/ r  ($b_utt) / $1 /) {
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}
    }
    if ($rulescore{$rule} == 3) { 
#insert intrusive /r/ at word boundaries preceding vowel (or stress)
#let's also insert intrusive /r/ at internal boundaries after free morpheme preceding vowel (or stress), e.g. drawing
#both of these covered by $b_frf (free-root-final)
#I'm not making vowels into rhotic versions as these accents are non-rhotic, can be mapped together by map_unique if required

	while (s/ ($v_int)  ($b_frf)(\.*)($b)  ($v|$s) / $1  r  $2\.$4  $5 /) {
	    if ($opt_d) { &debug_format(__LINE__);  }
	}
    }
#let's reduce syllables which now have certain formats to syllabic consonants
#formats are [vsz] @r [lmn]
    while (s/ ([vsz])  (\@r)  ($c_0_syl) / $1  $3\! /) {
	if ($opt_d) { &debug_format(__LINE__); }
    }
}


sub do_sy_zy {
#Comments here are for sy, but apply to zy too
#for now, let's change '. s y' in unstressed sylls to . sh'
#. s y and . s [y] in base files which is unlikely to become sh has been changed to s . y, e.g. exudate, capsule
#haven't included word-boundaries or cross-syllable boundaries - could do these for a casual style, e.g. 'miss you'
#only unstressed syllables matched
#these rules are ordered within this function
#usurious marked with () notation in lexicon as rule would be blocked by stress in american
#nb "\. s [y]" changed to "s \. [y]" in base files to block rule, e.g. insular; however, maybe the two processes are linked.  Can't predict s y rule from [y] though as [y] has already been converted, but could perhaps predict [y] from ". y" + certain vowels
#not free morpheme initial

# e.g. grecian, friesian
    while (s/ ($b_n_fri)  ([sz])  (($b)  )*y  (($b_bnd)  )*\@  ((($b_bnd)  )*($c_0_syl)) / $1  $2h  $3$5$7! /) { 
	if ($opt_d) { &debug_format(__LINE__); }
    }
#final schwa, e.g. galatia
    while (s/ ($b_n_fri)  ([sz])  (($b)  )*y  ((($b_bnd)  )*\@  ($b_wrd|$b_cmp)) / $1  $2h  $3$5 /) { 
	if ($opt_d) { &debug_format(__LINE__); }
    }
# e.g. pressure.  Must follow rule above
    while (s/ ($b_n_fri)  ([sz])  (($b_n_sll)  )*y  ((($b_bnd)  )*\@r) / $1  $2h  $4 $5 /) { 
	if ($opt_d) { &debug_format(__LINE__); }
    }
	
#before non-schwa vowels
#this set may be prone to retention as s y; e.g. casual more likely to be s y than closure (which precedes @r)
#2 is just ireland at present
    if ($rulescore{$rule} != 2) {
	while (s/ ($b_n_fri)  ([sz])  (($b_n_sll)  )*y  ((($b_bnd)  )*($v)) / $1  $2h  $3$5 /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
# this converts results to syllabics
	    while (s/ ($b_n_fri)  ([sz]h)  \@  (($b_n_sll)  )*($c_0_syl) / $1  $2  $3$5! /) { 
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
    }

#this section alters /z ii @/ and /s ii @/ to zh-sh-forms for american.  Applies before schwa and @r, e.g. brazier, but doesn't apply across word boundary
#these might apply in casual british styles too
#haven't done anything for /[sz]/ or /sh/ in other situations, e.g. sociology
#need to block for some words, e.g. doesn't apply to axiom.  Seems to only apply after vowels
#a few words need to be blocked with syllable boundary changes:  osseous, potassium, physio... symposi... theseus, societe
    if ($rulescore{$rule} == 3) {	# just american accents
	while (s/ (($v)  (($b_bnd)  )*([sz]))  (($b_n_sll)  )*ii  (($b_bnd)  )*\@/ $1h  $6$8\@/) {
	    if ($opt_d) { &debug_format(__LINE__); }
# this converts results to syllabics
	    while (s/ ([sz]h)  \@  (($b_n_sll)  )*($c_0_syl) / $1  $2$4! /) { 
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
    }
}

sub conv_general {
#the following conversions apply to all accents

#make syllabics explicit for easy rules
#between syll bounds, nb $b_sll includes utterance bounds
#only second of a potential pair in one syllable should be syllabic, e.g. abysmal syllabic l not syllabic m
    if ($opt_d) {push (@debug, "       conv_general\n");}

    while (s/ (($b_sll)  (($c_n_syl|$b)  )*($c_0_syl))  ((($c_n_syl|$b)  )*($b_sll)) / $1\!  $6 /) {
	if ($opt_d) { &debug_format(__LINE__); }
    }
}

sub conv_ll {
#ll in non-welsh accents is |th l| medially
    if ($convertscore{$convert} == 1) { 
	while (s/ ($v)  (($b_n_wrd)  )*ll / $1  $2th  l /) {
	    if ($opt_d) { &debug_format(__LINE__);      }
	    while (s/\.($b)*  th  l /$1  th  \.  l /) {
		if ($opt_d) { &debug_format(__LINE__);      }
	    }
	}
    }
}


sub conv_ii2 {
#do ii2 first
    if ($convertscore{$convert} == 1) { 
	while (s/ ii2 / ii /) {
	    if ($opt_d) { &debug_format(__LINE__);      }
	}
    }
    elsif ($convertscore{$convert} == 2) { 
	while (s/ ii2 / y /) {
	    if ($opt_d) { &debug_format(__LINE__);      }
	}
    }
    &correct_bounds;
}

sub conv_y {
#if score is 1, do nothing - will be dealt with below
    if ($convertscore{$convert} == 2) {           
#not sure this is accurate, maybe only used for most common words?
#if done by frequency though, maybe need to do this on stem
	while (s/ n  \[y\] / n /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}     
    }
}

sub conv_basic {
# this for UK types, includes NZ and AUS
    if ($convertscore{$convert} < 5) { 
#multiple symbols before forward slash (delete those after), all in round brackets
	while (s/ \(([^\/]+)\/([^\)]+)\) / $1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#single symbols before forward slash (delete those after)
	while (s/ ([^ ]+)\/([^ ]+) / $1 /) {     
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#caps numberless vowel, with or without R, to lower
#nb haven't set a variable for this, using reg exp
	while (/ ([A-Z]+R*|\@\@R) / ) {  
	    s/$&/\L$&/;
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#caps1 to schwa or schwa-r
#nb haven't set a variable for this, using reg exp
	while (/ ([A-Z]+R*|\@\@R)1 / ) {  
	    if ($& =~ / [A-Z\@]+R1 / ) {  
		s/$&/ \@r /;
	    }
	    else {
		s/$&/ \@ /;
	    }
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#for e.g. Ireland, Cardiff
	if ($convertscore{$convert} == 2) {           
# irish and cardiff (all welsh?) follow american in use of syllabics
#maybe irish should be in american hierarchy!
	    while (s/ \[\@\] //) { 
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
	
#square brackets1 and any symbol(s) deleted, must precede rule for brackets without 1
	while (s/ \[(($c_n_num|$v_n_num|$b|$s| )+)1\] //) {       
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#square brackets and symbol to symbol
	while (s/ \[(($c_n_num|$v_n_num|$b|$s| )+)\] / $1 /) {    
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    
#for US-type accents
    elsif ($convertscore{$convert} >= 5) { 
#multiple symbols after forward slash (delete those before), all in round brackets
	while (s/ \(([^\/]+)\/([^\)]+)\) / $2 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#single symbols after forward slash (delete those before)
	while (s/ ([^ ]+)\/([^ ]+) / $2 /) {     
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#caps numberless vowel to schwa or schwa-r
#nb haven't set a variable for this, using reg exp
	while (/ ([A-Z]+R*|\@\@R) / ) {  
	    if (/ [A-Z\@]+R /) {
		s/$&/ \@r /;
	    }
	    else {
		s/$&/ \@ /;
	    }
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#caps1 to lower
#nb haven't set a variable for this, using reg exp
	while (/ ([A-Z]+R*|\@\@R)1 / ) {  
	    s/ ($1)1 / \L$1 /;
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#brackets1 and any symbol(s) to symbol(s), must precede rule for brackets without 1
	while (s/ \[(($c_n_num|$v_n_num|$b|$s| )+)1\] / $1 /) {    
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#brackets and symbol deleted
	while (s/ \[(($c_n_num|$v_n_num|$b|$s| )+)\] //) {          
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    &correct_bounds;		
}
 

sub conv_ah2 {
#/ah2/ is a split in the basic /ah/ keysymbol
    if  ($convertscore{$convert} == 2) {
	while (s/ ah2 / a /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    else {
	while (s/ ah2 / ah /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_fullfinal5 {
#welsh full final vowels (score 2) - this must precede second part (score 1)
    if  ($convertscore{$convert} == 2) {
#for V5 and [V5], e.g. distant
	while (s/ \[*([AEIOU]+)5\]* / \L$1 /) { # full final vowels
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#for [V50], e.g. level
	while (s/ \[([AEIOU]+)50\] / \L$1 /) { # full final vowels
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#for V05, e.g. fastest
	while (s/ ([AEIOU]+)05 / \L$1 /) { # full final vowels (/e/)
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

    elsif ( ($convertscore{$convert} == 1) || ($convertscore{$convert} == 3)){ 
#for [V50], e.g. level
	while (s/ \[([AEIOU]+)50\] //) { # delete
	    if ($opt_d) { &debug_format(__LINE__); }
	}

#for V05, e.g. fastest
	if ($convertscore{$convert} == 1) {
	    while (s/ ([AEIOU]+)05 / i /) { # convert to /i/
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}
	elsif ($convertscore{$convert} == 3){ 
#for schwa output
	    while (s/ ([AEIOU]+)05 / \@ /) { # convert to /@/
		if ($opt_d) { &debug_format(__LINE__); }
	    }
	}

#for V5 and [V5], e.g. distant:
#this for ireland, us etc. - makes syllabic consonants out of [V5]
	if  (($convertscore{conv_basic} == 2) || ($convertscore{conv_basic} == 5)) {
#for [V5], deletion
	    while (s/ \[([AEIOU]+)5\] //) {
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
#this for the rest - must come last.  For conv_fullfinal5 score 1, makes @ out of [V5], e.g. accountant
	else {
#for [V5], schwa
	    while (s/ \[([AEIOU]+)5\] / \@ /) { 
		if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
#for V5, all @
	while (s/ ([AEIOU]+)5 / \@ /) { 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    &correct_bounds;		
}

sub conv_eir_ir {
#square-near merger in NZ
    if ($convertscore{$convert} == 2) {
	while (s/ eir / ir /) {	
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_iu {
#iu phonemes in welsh
# iu3 remains as /iu/ only in this type
    if ($convertscore{$convert} == 2) {
	while (s/ iu3 / iu /) {	
	    if ($opt_d) { &debug_format(__LINE__); }
	}

# convert some other sequences to |iu|
# convert /y u/ and /y uu/ unless it is combined with initial orthographic 'y' - problem, don't have this information in string mode, only lexicon mode.  Not many words affected though
# need to extend program to read orthographies in order to do this 100% accurately
#  $aln only there in lexicon mode
        unless ((/ ($b_fri)  y  (($s)  )*uu* /) && ($aln =~ /[\{\<]y/)) {
	    while (s/ y  (($s)  )*uu* / $1iu /) {
	       if ($opt_d) { 	&debug_format(__LINE__); }
	    }
	}
	while (s/ y  (($s)  )*iu / $1iu /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ y  (($s)  )*ur / $1iur /) { # converts y ur to iur allophone
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ (sh  (($s)  )*)ur / $1iur /) { # converts sh ur to sh + iur allophone
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }

#iu3 phonemes elsewhere converted to /uu/, including nyc
    else {
	while (s/ iu3 / uu /) {		 
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_fullinit4 {
#northern english full prefixes
    if ($convertscore{$convert} == 2) {
	while (s/ ([AEIOU]+H*)4 / \L$1 /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#full /e/ in e.g. expect
	while (s/ E0 / e /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($convertscore{$convert} == 1) {
	while (s/ ([AEIOU]+H*)4 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#full /e/ in e.g. expect, becomes i in reduced form
	while (s/ E0 / i /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
#schwa for all
    elsif ($convertscore{$convert} == 3) {
	while (s/ ([AEIOU]+H*)4 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
#full /e/ in e.g. expect, becomes i in reduced form
	while (s/ E0 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
# adjust syllable boundaries
    &correct_bounds;		
}

sub conv_i_schwa_2 {
    if ($convertscore{$convert} == 1) {
	while (s/ I2 / i /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($convertscore{$convert} == 2) {
	while (s/ I2 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_i_schwa_6 {
    if ($convertscore{$convert} == 1) {
	while (s/ I6 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($convertscore{$convert} == 2) {
	while (s/ I6 / i /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_i_schwa_7 {
    if ($convertscore{$convert} == 1) {
	while (s/ I7 / i /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($convertscore{$convert} == 2) {
	while (s/ I7 / \@ /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}

sub conv_longschwa {
    if ($convertscore{$convert} == 1) {
	while (s/ \@\@r[23] / \@\@r /) {	# nb these accents are generally non-rhotic
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
    elsif ($convertscore{$convert} == 2) {
	while (s/ \@\@r2 / uu /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
	while (s/ \@\@r3 / ou /) {
	    if ($opt_d) { &debug_format(__LINE__); }
	}
    }
}




sub debug_format {
    my ($tmpline) = @_;
    push (@debug, "            \'$`$&$'\' -> \'$_\', matched on \'$&\', line $tmpline\n");
#check no extra spaces introduced or deleted by rules - these can mess up subsequent rules
    if (($_ =~ / \{,3\}[^ ]/) || ($_ =~ /[^ ] \{,3\}/) || ($_ =~ /[^\s] [^\s]/)) {
	push (@debug, "PROBABLE SPACING ERROR \'$&\', INTRODUCED AT LINE $tmpline\n");
    }
}

sub correct_bounds {
    
#first four merge boundaries
#nb can specify, say, }> using two $b.  Takes care of e.g. residuary in american english
    while (s/ \.  ($b)($b) / $1\.$2 /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
#nb can't specify == in this way as = doesn't occur separately
    while (s/ \.  \=\= / \=\.\= /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
    while (s/ ($b)($b)  \. / $1\.$2 /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
#nb can't specify == in this way as = doesn't occur separately
    while (s/ \=\=  \. / \=\.\= /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__);
	}
    }

#these are for adjustments re schwa and @r (note that \= doesn't occur under $b)
#don't do after @ or @r
#NB DOES NOT RESYLLABIFY ACROSS COMPOUNDS AND WORDS
    while (/ ($v_n_schwa)  ($b_int_sll)  (\@r*) /) {
	my $x1 = $1;
	my $x2 = $2;
	my $x3 = $3;
	my $x4 = $x2;
	$x4 =~ s/\.//;
	s/ $x1  ($b_int_sll)  $x3 / $x1  $x4  $x3 /;
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
    while (s/ ($v_n_schwa)  \.  (\@r*) / $1  $2 /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
#if this has left a bisyllabic word with 2 stresses, convert secondary to tertiary
    while (s/^ ([^\.]*)  \~  ([^\.]*\.[^\.]*  \*[^\.]*) $/ $1  \-  $2 /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
    while (s/^ ([^\.]*\.[^\.]*  \*[^\.]*)  \~  ([^\.]*) $/ $1  \-  $2 /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }

#these are for ii2 - treated as a vowel in base lex
    while (s/ y  ($b|\=)\.($b|\=) / y  $1$2 /) { 
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__); 
	}
    }
    while (s/ y  \. / y /) {
	if ($opt_d) {
	    push (@debug, "        correct_bounds\n");
	    &debug_format(__LINE__);
	}
    }
}

#calculates scores of converesions 
sub get_convertscore {
    my ($convertname) = @_;
#tests for application of rule by country, region then town, each level overriding the previous
    $convertscore{$convertname} = 1;
    if (exists ( $convert{$convertname}{ALL})) {
	$convertscore{$convertname} = $convert{$convertname}{ALL};
    }
    if (exists ( $convert{$convertname}{CNY}{$towns{$LOC}{CNY}})) {
	$convertscore{$convertname} = $convert{$convertname}{CNY}{$towns{$LOC}{CNY}};
    }
    if (exists ( $convert{$convertname}{REG}{$towns{$LOC}{REG}})) {
	$convertscore{$convertname} = $convert{$convertname}{REG}{$towns{$LOC}{REG}};
    }
    if (exists ( $convert{$convertname}{TWN}{$towns{$LOC}{TWN}})) {
	$convertscore{$convertname} = $convert{$convertname}{TWN}{$towns{$LOC}{TWN}};
    }
    if (exists ( $convert{$convertname}{PER}{$towns{$LOC}{PER}})) {
	$convertscore{$convertname} = $convert{$convertname}{PER}{$towns{$LOC}{PER}};
    }
    if ($opt_d) {
	printf "%-30s  %-s\n", "convertscore for $convertname", $convertscore{$convertname};
    }
    
}

#calculates scores of rules
sub get_rulescore {
    my ($rulename) = @_;

#tests for application of rule by country, region then town, each level overriding the previous

    $rulescore{$rulename} = 0;
    if (exists ( $rules{$rulename}{ALL})) {
	$rulescore{$rulename} = $rules{$rulename}{ALL};
    }
    if (exists ( $rules{$rulename}{CNY}{$towns{$LOC}{CNY}})) {
	$rulescore{$rulename} = $rules{$rulename}{CNY}{$towns{$LOC}{CNY}};
    }
    if (exists ( $rules{$rulename}{REG}{$towns{$LOC}{REG}})) {
	$rulescore{$rulename} = $rules{$rulename}{REG}{$towns{$LOC}{REG}};
    }
    if (exists ( $rules{$rulename}{TWN}{$towns{$LOC}{TWN}})) {
	$rulescore{$rulename} = $rules{$rulename}{TWN}{$towns{$LOC}{TWN}};
    }
    if (exists ( $rules{$rulename}{PER}{$towns{$LOC}{PER}})) {
	$rulescore{$rulename} = $rules{$rulename}{PER}{$towns{$LOC}{PER}};
    }
    if ($opt_d) {
	printf "%-30s  %-s\n", "rulescore for $rulename", $rulescore{$rulename};
    }
}
