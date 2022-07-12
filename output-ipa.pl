#!/usr/bin/perl
#this translates output of transform-text (in sampa format) to a basic web page which will display ipa characters
#in netscape, set preference fonts: encoding to western and variable width to a unicode font
#to turn syllable boundaries on or off, change value of $DOSYLL in output-sam

#use strict;
#use diagnostics;


use Getopt::Std;
getopts('f:i:');

our ($opt_f,$opt_i);
our ($IN);          #input file, if used

my ($wrd,$sem,$cat,$pro,$aln,$fre,$entry);  #word parts
my ($sam, $new);                            #old and new transcriptions
my ($num, $text, $cny);                     #for variation in input line
my $fault;

if ( (!$opt_f) && (!$opt_i) ){
    print STDERR "\nusage:  output-ipa.pl -[fi] [input]\n
\t-f file_of_pronunciation_strings or 
\t-i \"string input\" (stdinput in double quotes)\n";
    die "\tinput must be in SAMPA (line numbers and accent-codes allowed, \n\ttext lines are also generally acceptable if ending in \":   \")\n\n";
}

print "
\<html\>

\<head\>
\<META CONTENT\=\"text\/html\; CHARSET\=UTF\-8\"\>
\<\/head\>

\<body\>

";

if ($opt_f){			# file input
    $IN = $opt_f;
    open (IN) || die "Cannot open $IN\n";
    
  GETLINE:
    while (<IN>) {
	chomp;
	&operate_ipa;
    }
}
elsif ($opt_i) {		# stdinput
    my $input = $opt_i;
  GETLINE:
    while ($input =~ s/([^\n]+)//) {
	$_ = $1;
	&operate_ipa;
    }
}


sub operate_ipa {

    chomp;
#lexicon format - have to allow for : in pro field
    &get_format;		

    if (($pro) || ($text =~ /:   /)) {
	$pro =~ s/\'percent\'/\%/g;  #percent a problem in dos/transform-text interaction
       &do_chars;
    }
}


sub do_chars {
    my $ipa = "";

#here come the symbols
#swap position of diacritics
    $pro =~ s/(\=)(.)/$2$1/;
	while ($pro =~ s/(.)//) {
	    $sam = $1;
	    if ($sam =~ /^[a-z]$/) {
		$new = $sam;
	    }
	    else {
#warning output from sampa script
		if ($sam eq ",") {
		    if ($pro =~ s/^ (WARNING, [^\s]+ NOT MAPPED TO SAMPA)//) {
			$new = $1;
		    }
		}
#consonants
		elsif ($sam eq "?") { $new = "\&\#660;"; }
		elsif ($sam eq "4") { $new = "\&\#638;"; }
		elsif ($sam eq "S") { $new = "\&\#643;"; }
		elsif ($sam eq "Z") { $new = "\&\#658;"; }
		elsif ($sam eq "T") { $new = "\&\#952;"; }
		elsif ($sam eq "D") { $new = "\&\#240;"; }
		elsif ($sam eq "N") { $new = "\&\#331;"; }
		elsif ($sam eq "5") { $new = "\&\#619;"; }
		elsif ($sam eq "K") { $new = "\&\#620;"; }
		elsif ($sam eq "M") { $new = "\&\#653;"; }
		
#vowels
		elsif ($sam eq "E") { $new = "\&\#603;"; }
		elsif ($sam eq "\{") { $new = "\&\#230;"; }
		elsif ($sam eq "A") { $new = "\&\#593;"; }
		elsif ($sam eq "O") { $new = "\&\#596;"; }
		elsif ($sam eq "Q") { $new = "\&\#594;"; }
		elsif ($sam eq "V") { $new = "\&\#652;"; }
		elsif ($sam eq "I") { $new = "\&\#618;"; }
		elsif ($sam eq "@") { $new = "\&\#601;"; }
		elsif ($sam eq "U") { $new = "\&\#650;"; }
		elsif ($sam eq "7") { $new = "\&\#612;"; }
		elsif ($sam eq "\}") { $new = "\&\#649;"; }
		elsif ($sam eq "3") { $new = "\&\#604;"; }
		elsif ($sam eq "2") { $new = "\&\#248;"; }
		elsif ($sam eq "9") { $new = "\&\#339;"; }
		
#diacritics
		elsif ($sam eq "=") { $new = "\&\#809"; }  #syllabic
		elsif ($sam eq ":") { $new = "\&\#720"; }  #long
		elsif ($sam eq "\`") { $new = "\&\#692;"; }   #rhoticised
#stresses
		elsif ($sam eq "\"") { $new = "\&\#712;"; }
		elsif ($sam eq "%") { $new = "\&\#716;"; }
#syllable boundaries (must be turned on in output-sam script)
		elsif ($sam eq "\$") { $new = "\."; }
		
#approximant r two chars in sampa
		elsif (($sam eq "\\") && ($ipa =~ s/r$//)) { $new = "\&\#633;"; }
#raised 'a' three chars in sampa, two in ipa
		elsif (($sam eq "\_") && ($ipa =~ /\&\#230\;$/) && 
					  ($pro =~ s/^r//)) {
		    $new = "\&\#797;"; }
#rhoticised schwa was two chars in sampa, has one char in unicode
		elsif (($sam eq "\`") && ($ipa =~ s/\&\#601\;$//)) { $new = "\&\#6002;"; }
		
#leave spaces as is
		elsif ($sam eq " ")  { $new = " "; }
#leftovers
		else {
		    $new = "\<b\>\?\<\/b\>";
		    $fault = join ('', $fault, $sam);
		}
	    }
	    $ipa = join ('', $ipa, $new,);
	}
	
#output - only some fields will be used for any one output
    print "$cny$num$text$wrd$sem$cat\<FONT FACE\=\"Arial Unicode MS\"\,\"Lucida Sans Unicode\",\"MS Mincho\"\>$ipa\<\/FONT FACE\>$aln$fre\n\<p\>";
    $text = "";         #clear used variable
    if ($fault) {
	print "\nWARNING, COULDN'T MATCH SAMPA CHARACTER \'$fault\'\n\<p\>";
	undef $fault;
    }
}
    
    
    
print "\<\/body\>

\<\/html\>
";
    
    
sub get_format {
#for lexicon transformation
    $entry = $_;
    if ($_ =~ /^([^: ]+:)([^: ]*:)([^: ]+:)( .+ )(:[^: ]*)(:[^:]*)$/) {
#NB some fields optional
#including : in fields to remain unchanged
	$wrd = $1;
	$sem = $2;
	$cat = $3;
	$pro = $4;
	$aln = $5;
	$fre = $6;
	$aln =~ s/\</\&\#060/;  #need to mark these so they are ok in html file
#leave out checks here on format - if it's got this far it should be ok
    }


#for strings of prons, taken straight from base lexicon and joined with syllable markers, e.g. /#{ h * or r s }#.#{ r * ee s }#/
#note hash here, not in compounds e.g. / { h * or r s }.{ r * ee s } /
#transform-text output
    else { 
	$wrd = "";
	$sem = "";
	$cat = "";
	$aln = "";
	$fre = "";
#optional country name
	if (($text eq "")  && (s/^([a-z][a-z][a-z]\:  )//)){
	    $cny = $1;
	}
	else {
	    $cny = "";
	}
#optional numbering
	if (($text eq "") && (s/^( *[0-9]+[\.\:]*)//)){
	    $num = $1;
	}
	else {
	    $num = "";
	}
#optional text - marked by 3 spaces (nb may be on multiple lines - don't want to use paragraph input as it may be a lexicon with line format)
#sampa input should have @ or " or % on every line
	if (/(.*NOT_IN_LEXICON.*)/) {   #oov words
	    $text = $_;
	    $pro = "";
	    &do_chars;
	    $text = "";
	}
	elsif (($_ !~ /[\@\%\"\$]/) && ($_ !~ /:   /) && (!$text)){     #first line of multi-line text
	    $text = $_;
	    $pro = "";
	}
	elsif (($_ !~ /[\@\%\"\$]/) && ($text)){  #other lines of multi-line text
	    $text = join ('', $text, $_);
	}
#allow for text lines with $ or % or " in or @ - let's assume SAM line will have words of the format [a-z][A-Z][a-z], or $ in middle of a word, or will have a " (primary stress) or @ (schwa) , or /i/, or /I/, or syllabic /\=/, or /u/ in every word - not sure if this is 100% correct, but is v. likely to work for now
	elsif (($_ !~  /[a-z][A-Z][a-z]/) && ($_ !~  /[^0-9 ]\$[^0-9 ]/) && ($_ =~ /[\@\%\"\$]/) && ($_ !~ /:   /) 
	       && ($_ !~ /^\s*([^\s]*[\@\"Iiu\=][^\s]*\s*)*$/) 
	       && (!$text) ){     #first line of multi-line text
	    $text = $_;
	    $pro = "";
	}
	elsif (($_ !~  /[a-z][A-Z][a-z]/) && ($_ !~  /[^0-9 ]\$[^0-9 ]/) && ($_ =~ /[\@\%\"\$]/) 
	       && ($_ !~ /^\s*([^\s]*[\@\"Iiu\=][^\s]*\s*)*$/) 
	       && ($text)){  #other lines of multi-line text
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
