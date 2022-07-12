#!/usr/bin/perl
#combines get-exceptions, read-text type operations, and post-lex-rules
#stores exceptions lexicon in memory
#text parsed into sentences.  For word-lists, use full stops to force line-breaks

#use strict;
#use diagnostics;

use Getopt::Std;
getopts('uw');

our ($opt_u,$opt_w);
my $dos;  #two options for keyboard input style
my $DOS;  #two options for keyboard input style

#this is for getting path to other programs
use FindBin;
use lib $FindBin::Bin;
$SIG{__DIE__} = sub {};

#for Readtext module
use Readtext;

#supported towns listed in towns file
our $TOWNS = "$FindBin::Bin/uni_towns";
open (TOWNS) || die "Cannot open $TOWNS: $!\n";


my $needhelp = 1;
my $LOC = "NONE";
my $OLDLOC = "NONE";
my $FORMAT = "key";
my $NUMS = "n";
my $TEXT = "n";
my $D = "-o";
my ($O, $NUM, $MULTI, $in, $line_num, $TMPLOC, $store, $inputtext, $input, $uniqoutput, $failed, $finished, $line, $tmpinput, $newstring, $string, $output, $input_sav);
my (%towns, %CHECK);
our ($INFILE, $OUT);
my (%parsinglex);  #store lexicon
my (@command, $c, $oldin);             #store old input-line commands

while (<TOWNS>) {
    if (/\$towns\{(.*)\}\{(.*)\}.*\"(.*)\"/) {
	$towns{$1}{$2} = $3;
	$CHECK{$1} = 0;  #this for checking if I already have a lexicon for accent
    }
}

if (($#ARGV != 0) || ((!$opt_w) && (!$opt_u))) {
    die "\nusage:  transform-text.pl -[uw] [base_lexicon]\n
transforms plain text into accent-specific pronunciation strings
\t-u for use on unix\n\t-w for use on windows (dos), or unix without command history
you will be asked for input (stdin or file)
\n\n"; 
}

if ($opt_w) {
    $dos = 1;
    $DOS = "dos/basic input";
}
elsif ($opt_u) {
    $dos = 0;
    $DOS = "unix input";
    use sigtrap qw(die normal-signals);  #for exit handling (restores stty on exit)
    $SIG{'INT'} = 'sigint_handler';
}
else {
    die "error in code (\$dos variable\)\n";
}


our $LEX = $ARGV[0];
open (LEX) || die "Cannot open lexicon $LEX: $!\n";

#now ask for input
$c = -1;    #used for storing commands

GETINPUT:
while () {
    my $tmparg;
    my $arg;
#go back to line mode
    $/ = "\n";

    print STDERR "Please type input";
    if ($needhelp == 1) {
	&stdin_usage;
    }
    else {print STDOUT "\n\n";}

    if ($dos == 0) {
	#for unix
	&get_input_advanced;    #includes basic line-editing and history
    }
    elsif ($dos == 1) {
	&get_input_basic;      #input for dos
     }

    my @inarray = split (/ /, $in);

    while ($arg = shift (@inarray)) {
#help
	if (($arg =~ /^\?+$/) || ($arg eq "-help")){
	    $needhelp = 1;
	    next GETINPUT;
	}
#settings
	elsif ($arg eq "-set") {
	    print STDERR "towncode\t$OLDLOC\nformat\t\t$FORMAT\nnumbers\t\t$NUMS\ntext\t\t$TEXT\nrule breakdown\t$D\nsystem\t\t$DOS\n\n";
	    next GETINPUT;
	}
#quit
	elsif ($arg eq "QUIT") {
	    last GETINPUT;
	}
	
#debugging options
	elsif ($arg eq "-d") {
	    $D = "-d";
	    $O = "-d";
	}
	elsif ($arg eq "-o") {
	    $D = "-o";
	    $O = "";
	}
	
#output format options
	elsif ($arg eq "-form") {
	    $arg = shift (@inarray);
	    if ($arg =~ /^(fest|sam|ipa|key)$/){ 
		$FORMAT = $&;
	    }
	    else {
		print STDERR "incorrect argument to -form\n";	
		next GETINPUT;
	    }	    
	}
#line number options
	elsif ($arg eq "-nums") {
	    $arg = shift (@inarray);
	    if ($arg eq "y") {
		$NUMS = "y";
		$NUM = '[0-9]+[\.\:]*[\s]+';
	    }
	    elsif ($arg eq "n") {
		$NUMS = "n";
		$NUM = "";
		$line_num = "";
	    }
	    else {
		print STDERR "incorrect argument to -nums\n";	
		next GETINPUT;
	    }	    
	}
#text output options
	elsif ($arg eq "-text") {
	    $arg = shift (@inarray);
	    if ($arg =~ /^[yn]$/) {
		$TEXT = $&;
	    }
	    else {
		print STDERR "incorrect argument to -text\n";	
		next GETINPUT;
	    }	    
	    
	}
	
#output to file
	elsif ($arg =~ /^>{1,2}/){
	    if ($') {$tmparg = $';}
	    else {$tmparg = shift (@inarray);}
	    if ($arg =~ /^\>\>/) {
		$OUT = ">>$tmparg";
		if (open (OUT) != 1 ) {
		    print STDERR "Cannot open file $OUT for writing: $!\n";	
		    next GETINPUT;
		}
		select OUT;
	    }
	    elsif ($arg =~ /^\>/) {
#for multiple accents, need to allow adding to the end of a file
#do this by deleting file, then opening as >>
		$OUT = ">$tmparg";
		if (open (OUT) != 1 ) {
		    print STDERR "Cannot open file $OUT for writing: $!\n";	
		    next GETINPUT;
		}
		select OUT;
	    }
	}
	
#towncode
	elsif ($arg eq "-a") {
	    $arg = shift (@inarray);
	    if ($arg !~ /\w/i) {  #for blank argument, or just spaces
		$arg = "NONE";
	    }
	  GETTOWNCODE:
	    while ($arg =~ /,$/) {
		$tmparg = shift (@inarray);
		if ($tmparg) {
		    $arg = join ('', $arg, $tmparg);
		}
		else {
#this for malformed input ending in comma
		    last GETTOWNCODE;   
		}
	    }	    
	    $TMPLOC = $arg;
	    $OLDLOC = $TMPLOC;
	}
#input from file
	elsif ($arg eq "-f") {
	    $arg = shift (@inarray);
	    $INFILE = $arg;
	    if (open (INFILE) != 1) {
		print STDERR "Cannot open file $INFILE for reading: $!\n";
		next GETINPUT;
	    }
	    else {
#whole file mode
		undef $/;
		$input = <INFILE>; 
	    }
	}
	
#rest of input line, if not preceded by certain chars, should be input text
# must contain at least one non-white-space
	elsif ($arg =~ /^\-/) {
	    print STDERR "unrecognised argument $arg, try again\n";
	    next GETINPUT;
	}	    
	elsif ($arg =~ /[^\s]/) {
	    if ($in !~ /\-f /) {     #-f is file input option
	      MAKESTRING:
		while ($tmparg = shift (@inarray)) {
#these chars precede other arguments
#need to allow for possibility of > or arguments starting with - following text string
		    if (($tmparg =~ /^[\>\?]/) || ($tmparg =~ /^\-./)) {
			unshift (@inarray, $tmparg);
			last (MAKESTRING);
		    }
		    else {
			$arg = join (' ', $arg, $tmparg);
		    }
		}
		$input = $arg;
	    }
	}
	else {
	    print STDERR "Bad or empty input, try again\n";
	    next GETINPUT;
	}
    }
#rule out this combination
    if (($FORMAT eq "ipa") && ($D eq "-d")) {
	print STDERR "-d and -form $FORMAT are incompatible\n";
	next GETINPUT;
    }

#other defaults
    if ($in !~ /\-a/) {  #reuse old town code if no new one given
	$TMPLOC = $OLDLOC;
    }
    if ($in !~ /\>/){    #use standard output if no file output given
	select STDOUT;
    }
    if ($TMPLOC =~ /\,/) {$MULTI = 1;} # used for multiple town codes
    else {$MULTI = 0;}
    
    
    my $n = 0;
#checking towncode
    while (($TMPLOC =~ s/\,*([^\s\,]+)//) || ($LOC eq "NONE")) {
	$LOC = $1;   
	if ((!$LOC) || (!$towns{$LOC}) ||  ($LOC eq "NONE")) {
	    print STDERR "need town code, options are:\n\n";
	    printf STDERR "%-4s  %-21s %-9s %-5s %s\n", "CODE", "TOWN\-NAME", "REGION", "CNTRY", "NOTES";
	    printf STDERR "%-4s  %-21s %-9s %-5s %s\n", "----", "----------", "------", "-----", "-----";
	    foreach my $town (sort keys %towns) {
		printf STDERR "%-4s  %-21s %-9s %-5s %s\n", $town, $towns{$town}{TWN}, $towns{$town}{REG}, $towns{$town}{CNY}, $towns{$town}{NOTES};
	    }
	    print "\n";
#clear old input
	    $input_sav = "";
	    $input = "";
	    next GETINPUT;
	}

	if ($input =~ /[\w]/) {
#simple changes to input to enable sentence splitting
#lets treat two line-ends as sentence end
	    $input =~ s/([\w][^\.\!\?\n]*)(\n[\s]*\n)+/$1\. \n/g;    
#this is to help differentiate between full stops and decimal points
	    $input =~ s/([\.\?\!]+[\)\"\'\]]*)\n/$1 \n/g;
	    $input =~ s/([\.\?\!]+[\)\"\'\]]*)$/$1 /g;
#let's delete ? and ! in certain non-sentence final situations, i.e. followed by commas (with or without quotes) or spaces lower-case letters
	    $input =~ s/[\?\!]([\"\']*,)/$1/g;
	    $input =~ s/[\?\!]([\"\']* [a-z])/$1/g;
#doesn't really allow for full stops in e.g. acronyms
#treat these here - allows for multiple caps but not single, e.g. S.E. Fitt but not S. Fitt
	    while ($input =~ /[A-Z]\.[A-Z]\./) {
		#remove the last ones first
		$input =~ s/([A-Z])\.([A-Z])\./$1 $2/;
		#then strip other internal ones
		$input =~ s/([A-Z])\.([A-Z])/$1 $2/;
	    }


#lets add full stop to input with no end punctuation
	    if ($input !~ /[\.\!\?][\W]*$/) {
		$input =~ s/$/\. /;    
	    }
	}

	if ($n > 0) {$input = $input_sav;} # keep input string for next accent
	else {$input_sav = $input;}
	&read_exceptions;

#do a sentence at a time
	while ($input =~ /[\w]/) {
	    &make_sent;               #parse input, make transcriptions strings
	    &transform_transcription;    #apply post-lex-rules, mappings etc.
	}
	$n++;
    }
#need to apply ipa-output to whole result
    if (($FORMAT eq "ipa") && ($store)){
	&format_ipa;             
    }
    $store = "";           #reset store for ipa formatting
    close OUT;
}

sub read_exceptions {

    if (($CHECK{$LOC}) == 0) {
	print STDERR "reading lexicon for $towns{$LOC}{TWN}, person $towns{$LOC}{PER}, please wait...\n";

#make an array of lexicon with exceptions - don't need to store these
	undef my @exc;
	@exc = split (/^/, `perl $FindBin::Bin/get-exceptions.pl -a $LOC -f $LEX`);
#error trapping in child process
	if ($?) {$line = __LINE__; print STDERR "error $? at get-exceptions, in $0 line $line\n"; undef $?;}
# make output temporary lexicon (structured to select unstressed variants etc.)

#hash of hashes (each hash is local lexicon, parsed ready for string output)
#store these by accent
	%{$parsinglex{$LOC}} = &Readtext::parse_lex(@exc);

	$CHECK{$LOC} = 1;
    }
}

sub make_sent {
    my $sent = "";

#split into basic units (like sentences)
#remember number may be empty
#must be a final punctuation - full stop will have been added for input with no puncutation
#allow for decimals, e.g. 9.4, and web addresses, e.g. www.cstr.ed.ac.uk
#allow question marks in web urls
    if ($input =~ s/^\s*($NUM){0,1}(([^\?\.\!]+|[0-9a-zA-Z\?\=\-]\.[0-9a-zA-Z\?\=\-]+)+[\?\.\!]+[\)\"\'\]]* )//) {
	$line_num = $1;
	$sent = $2;
	if ($O) {
	    $line = __LINE__;
	    print "input sentence split off at transform-text, line $line: $sent\n";
	}
	if ($TEXT eq "y") {
	    $inputtext = "$sent\:   ";
	}
	else {
	    $inputtext = "";
	}
#text processing - make text string into pronuncunciation string 
	$string = &Readtext::make_sent_and_transform(\$sent, \%{$parsinglex{$LOC}},\$LOC, \%towns);
	if ($?) {$line = __LINE__; print STDERR "error $? at read-text, in $0 line $line\n";undef $?;}
	else {
	    if ($O) {
		$line = __LINE__;
		print "input sentence is transformed by Readtext.pm, transform-text line $line, to: $string\n";
	    }
	}
    }
    elsif ($input =~ s/^\s*($NUM){0,1}([\?\.\!]+[\)\"\'\]]*)//) {
	#do nothing, just eliminate certain punctuations from start of string
    }
    else {
	$string = "";
	$line = __LINE__;
	print STDERR "\nerror in converting text to pronunciations at transform-text line $line, abandoning rest of input, problem input was $input\n\n";
	$input = "";
    }
}

sub transform_transcription {

#apply post-lex rules to found strings
    while ($string =~ /./) {
#split off words which weren't found in lexicon, process the rest (if any)
	if ($string =~ /(\.*\#[^\#]*NOT_IN_LEXICON\#\.*)/){
	    $failed = $1;
	    $newstring = $`;
	    $string = $';
	}
#this deals with strings not containing OOV words
	else {
	    $failed = "";
	    $newstring = $string;
	    $string = "";
	}

	if ($newstring) {
	    $output = `perl $FindBin::Bin/post-lex-rules.pl $O -a $LOC -i "$newstring"`;
	    if ($?) {$line = __LINE__; print STDERR "error $? at post-lex-rules, in $0 line $line\n";undef $?;}
	    $output =~ s/\n$//;

#let's also apply map-unique
	    if (! $O) {
		if ($MULTI == 1) {
		    if ($FORMAT ne "ipa") {
#line-by-line printing best for most options - you can see something happening
#But, don't print out for ipa format as this has html headers - instead store and print out as one block
			print "$LOC\:  ";
		    }
		    else {
			$store = join('', $store, "$LOC\:  ");
		    }
		}
		$uniqoutput = `perl $FindBin::Bin/map-unique.pl $O -a $LOC -i "$output"`;
		if ($?) {$line = __LINE__; print STDERR "error $? at map-unique, in $0 line $line\n";undef $?;}
#input for -fest and -sam
		$tmpinput = $uniqoutput;
	    }
	    else {
		if ($MULTI == 1) {print "$LOC\:  \n";}
		print $output;
		$output =~ /OUTPUT:\s+(.*)/;	# find line with finished pron
		$finished = $1;
		$uniqoutput = `perl $FindBin::Bin/map-unique.pl $O -a $LOC -i "$finished"`;
		if ($?) {$line = __LINE__; print STDERR "error $? at map-unique, in $0 line $line\n";undef $?;}
#input for -fest and -sam
		$uniqoutput =~ /(.*)(\n.\s)*$/;
		$tmpinput = $1;
	    }  

#different output formatting options
	    if ($FORMAT eq "fest") {
		if (! $O) { undef $uniqoutput; }
		else {
		   $uniqoutput =~ s/\n$/\nFEST:  /;
#not sure why this option prints out differently  - quick fix
		   $tmpinput =~ s/OUTPUT: +//;
                   $tmpinput =~ s/$/\n/; 
                }  
		my $festoutput;
		$festoutput = `perl $FindBin::Bin/output-fest.pl -i "$tmpinput"`;
		if ($?) {$line = __LINE__; print STDERR "error $? at output-fest, in $0 line $line\n";undef $?;}
		$uniqoutput = join ('', $uniqoutput, $festoutput);
	    }
	    elsif (($FORMAT eq "sam") || ($FORMAT eq "ipa")){
		if (! $O) { undef $uniqoutput; }
		else {
		   $uniqoutput =~ s/\n$/\nSAMPA:  /;
                   $tmpinput =~ s/OUTPUT: +//;
                }
		my $samoutput;
    		$samoutput = `perl $FindBin::Bin/output-sam.pl -a $LOC -i "$tmpinput"`;
		if ($?) {$line = __LINE__; print STDERR "error $? at output-sam, in $0 line $line\n";undef $?;}
		$uniqoutput = join ('', $uniqoutput, $samoutput);
	    }
	    if ($FORMAT ne "ipa") {
		if (! $O) {
		    print $line_num;
		    print $inputtext;
		    print $uniqoutput;
		}
		else {
		    $uniqoutput =~ s/(\n)([^\n]*\n)$/$1$line_num$inputtext$2/g;
		    print $uniqoutput;
		}
#these variables cleared so as not to repeat printout if any oov words found
		$line_num = "";   
		$inputtext = "";
	    }
	    else {
		$store = join('', $store, $line_num);
		$store = join('', $store, $inputtext);
		$store = join('', $store, $uniqoutput);
#these variables cleared so as not to repeat printout if any oov words found
		$line_num = "";   
		$inputtext = "";
	    }
	}
#these words will be the first in a sentence
	if ($FORMAT ne "ipa") {
	    if (($line_num) || ($inputtext)) {
		print $line_num;
		print $inputtext;
		print "\n$failed\n";
	    }
	    else {
		print "$failed\n";
	    }
	    $line_num = "";   
	    $inputtext = "";
	}
	else  {
	    $store = join('', $store, $line_num);
	    $store = join('', $store, $inputtext);
	    if (($line_num) || ($inputtext)) {
		$store = join('', $store, "\n", $failed, "\n");
	    }
	    else {
		$store = join('', $store, $failed, "\n");
	    }
	    $line_num = "";   
	    $inputtext = "";
	}
    }
}

sub format_ipa {
    if ($dos == 0) {
          $store =~ s/\\/\\\\/g;	# some \ already in sampa line
          $store =~ s/\$/\\\$/g; #these mess up command line
          $store =~ s/\`/\\\`/g; #these mess up command line
    }
    elsif ($dos == 1) {
 #escaping doesn't seem to work for % in dos
       $store =~ s/\%/\'percent\'/g; #these mess up command line
    }
    $store =~ s/\"/\\\"/g; #these mess up command line

    my $ipaoutput;
    $ipaoutput = `perl $FindBin::Bin/output-ipa.pl -i "$store"`;
   
    print $ipaoutput;   #this will contain basic html header
}

sub get_input_advanced {
    system "stty", '-icanon';
    system "stty", '-echo';
    my $c_old = $c;    #stores previous command
    $in = "";

#for some reason getc treats 0 as a failure - could do with fixing
GETCHAR:
    while (my $key = getc(STDIN)) {
	
#simple history - if control-p is entered, use previous command
	while ($key =~ /(\cP|\cN)/) {
#previous commands on control-p
	    while ($key =~ s/\cP//) {
		$in = $command[$c_old];
		if ($c_old == $c) {
		    print STDERR "$in"; 
		}
		else {
#erase previous command(s) from ^P from screen
		    my $len = length ($oldin);
		    for (my $l = 1; $l <= $len; $l++) {
			print STDERR "\010"; 
		    }
		    for (my $l = 1; $l <= $len; $l++) {
			print STDERR " "; 
		    }
		    for (my $l = 1; $l <= $len; $l++) {
			print STDERR "\010"; 
		    }
		    if ($c_old < 0 ) {   #this for end of history trail
			$in = "";
		    }
		    print STDERR "$in";  #print out previous commands
		}
		$c_old--;
		$key = getc(STDIN);
		$oldin = $in;
	    }
#next commands on control-n
	    if ($key =~ /\cN/) {
		$c_old++;
		$c_old++;
	    }
	    while ($key =~ s/\cN//) {
		$in = $command[$c_old];
#erase previous command(s) from ^P or ^N from screen
		my $len = length ($oldin);
		for (my $l = 1; $l <= $len; $l++) {
		    print STDERR "\010";
		}
		for (my $l = 1; $l <= $len; $l++) {
		    print STDERR " "; 
		}
		for (my $l = 1; $l <= $len; $l++) {
		    print STDERR "\010"; 
		}
		if ($c_old > $c ) {   #this for end of history trail
		    $in = "";
		}
		print STDERR "$in";  #print out previous commands
		$c_old++;
		$key = getc(STDIN);
		$oldin = $in;
	    }
	    $c_old--;
	    $c_old--;
	}
#end command line
	if ($key =~ /\n/) {	
	    print STDERR $key;
	    $in =~ s/^[\s]+//;      #remove initial and extra blanks
	    $in =~ s/[\s]+/ /g;      # - they mess up array
	    $c++;
	    $command[$c] = $in;     #store command for history
	    last GETCHAR;
	}
#deal with corrections (control-h, control-b, backspace)
	elsif ($key =~ /(\cH|\cB|\010)/) {
	    $in =~ s/.$//;          #erase last char
	    print STDERR "\010";
	    print STDERR " ";
	    print STDERR "\010";
	}
	else {
	    print STDERR $key;
	    $in = join ('', $in, $key);
	    $oldin = $in;
	}
#if nothing entered repeat request
	if (!$in) {
	    goto next GETINPUT;
	}
    }
    system "stty", 'icanon';
    system "stty", 'echo';
}

sub stdin_usage {
    print STDERR ", all arguments optional, towncode needed on first use\n";
    if ($dos == 0) {print STDERR"Basic history with ^P and ^N, basic line editing with ^H or ^B for delete\n";}
    elsif ($dos == 1) {print STDERR"Basic line editing generally available in dos with backspace\n";}
print STDERR "
usage:\t\[settings\] input

\tThe following settings persist until changed:

";
printf STDERR "%-10s %-31s %-20s\n", "", "to change towns:", "-a towncode (obligatory on first use)";
printf STDERR "%-10s %-31s %-20s\n", "", "to list town codes:", "-a ?";
printf STDERR "%-10s %-31s %-20s\n", "", "to use multiple town codes:", "-a xxx,yyy,zzz";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "output simplified for festival:", "-form fest";
printf STDERR "%-10s %-31s %-20s\n", "", "output in SAMPA:", "-form sam";
printf STDERR "%-10s %-31s %-20s\n", "", "output an html IPA file:", "-form ipa (use with > )";
printf STDERR "%-10s %-31s %-20s\n", "", "output in keysymbols (default):", "-form key";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "line nums repeated from input:", "-nums y";
printf STDERR "%-10s %-31s %-20s\n", "", "line nums not parsed (default):", "-nums n";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "text included in output:", "-text y";
printf STDERR "%-10s %-31s %-20s\n", "", "text not included (default):", "-text n";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "show rule breakdown:", "-d";
printf STDERR "%-10s %-31s %-20s\n", "", "plain output (default):", "-o";

print "\n\tOther options:

";
printf STDERR "%-10s %-31s %-20s\n", "", "text input from file:", "-f text_file";
printf STDERR "%-10s %-31s %-20s\n", "", "text input from keyboard:", "text strings";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "output to file:", "\>  outfile";
printf STDERR "%-10s %-31s %-20s\n", "", "append to file:", "\>\> outfile";
print STDERR "\n";
printf STDERR "%-10s %-31s %-20s\n", "", "show these options:", "?  or  -help";
printf STDERR "%-10s %-31s %-20s\n", "", "show current settingss:", "-set";
if ($dos == 0) {printf STDERR "%-10s %-31s %-20s\n", "", "quit:", "control\-c or QUIT";}
else {printf STDERR "%-10s %-31s %-20s\n", "quit:", "control\-d return or QUIT";}
	$needhelp = 0;
print STDERR "\n";
}


sub  sigint_handler {
    system "stty", 'icanon';
    system "stty", 'echo';
    exit(1);
}


sub get_input_basic {
    $in = <STDIN>;
#remove initial and extra blanks - they mess up array
#if nothing entered repeat request
     if ($in =~ /\cD/) {
	exit;
    }
	elsif (!$in) {
	next GETINPUT;
    }
   
    else {
      $in =~ s/^[\s]+//;
      $in =~ s/[\s]+/ /;
    }
}
