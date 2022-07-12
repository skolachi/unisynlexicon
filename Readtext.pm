package Readtext;

require 5.005_62;
#use strict;
#use warnings;

require Exporter;

our @ISA = qw(Exporter);

$Readtext::string;
$Readtext::sent;
$Readtext::loc;
$Readtext::towns;
my $newnum;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Readtext ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

#our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT_OK = qw($Readtext::string $string %Readtext::lexout &parse_lex &make_sent_and_transform);


our @EXPORT = qw(
	
);
our $VERSION = '0.01';


# Preloaded methods go here.


use FindBin;
#use lib "/projects/unisyn/sue/Scripts/Final";

sub parse_lex {
    undef %Readtext::lexout;   #need to clear it in case I call multiple accents in one session
    my (@lex) = @_;
    foreach my $entry (@lex) {
	$_ = $entry;
	if ($_ =~ /^([^:]+):([^:]*):([^:]*): ([^:]+) :/) {  
	    my $wd = $1;
	    my $sem = $2;
	    my $cat = $3;
	    my $pro = $4;                    
#lets allow for unstressed words
#simple rules only - could be improved by using proper parsing instead, in make_sent_and_transform function
	    if ($sem =~ /\,unstressed/) {
#done as uns_uns to avoid confusion with actual words
		$Readtext::lexout{uns_uns}{$wd} = $pro;
	    }
	    elsif ($sem =~ /before\-vowel/) {  #pre-vocalic variants
		$Readtext::lexout{vow_vow}{$wd} = $pro;
	    }
	    elsif (exists $Readtext::lexout{$wd} == 0) {
		$Readtext::lexout{$wd} = $pro;
	    }

#let's allow de-stressing of some words, e.g. pronouns like my (PRP$), I (PRP), conjunctions (CC)
#words are only marked in the lexicon with an unstressed form if the vowel differs as well as the stress
#nb match not terminated, but not worrying about it here - shouldn't affect other cats (PRP|VBD etc. probably also unstressed)

	    if (($cat =~ /(PRP\$|PRP|CC)/)  ||
		($wd =~ /^(be|is|was|in|on)$/)) {
		$pro =~ s/[\*\~\-] //g;
		$Readtext::lexout{uns_uns}{$wd} = $pro;
	    }
#save cats for stress-shift	    
	    $Readtext::lexout{cat_cat}{$wd} = $cat;
	}
    }
    return (%Readtext::lexout);
}
    
    
sub make_sent_and_transform {
# $arrayref is text, $lexref is parsed lexicon from parse_lex
# $locref is towncode, $townsref is townarray

    my ($arrayref, $lexref, $locref, $townsref) = @_;
    local $_ = $$arrayref;            #this is text line
    $Readtext::loc = $$locref;
    %$Readtext::towns = %$townsref;

    $Readtext::string = "";
    $Readtext::sent = "";
    my $singquot = 0;
    my $oldcat = "";
    my $oldwd = "";


#these punctuations are used to determine word boundaries, and some word-form alternations

#these are punctuations (asterisk occurs occasionally as bullet point etc.
    my $punc = '[\s\.\,\;\:\"\!\?\(\)\-\*\[\]]+';  
#these are punctuations which can be automatically deleted at the start of the phrase
    my $delpunc = '[\s\"\(\*\[\-]+';  
#these are not punctuations
#leave hyphen out - treat separately - can be wd or non-wd char
#leave full stop out to allow for e.g. dot.com
    my $notpunc = '[^\s\,\;\:\"\!\?\(\)]+';  
#these generally correspond to  phrase breaks
    my $int_end = '[\,\.\:\;\-\!\?]+';    
#sentence ends
    my $sent_end = '[\.\!\?]+';         
#not sentence ends
    my $notsent_end = '[^\.\!\?]+';         

#do some pre-processing, e.g. numbers NB this is fairly basic, just done to get started on some common omissions from the lexicon
    my $input = &preprocess($_);
#change to lower case
    $input =~ s/([A-Z])/\l$1/g;

#to allow for dot.com, or other missed word-internal dots
    $input =~ s/($sent_end)([^a-zA-Z])/$1 $2/g;
    $input =~ s/($sent_end)$/$1 /;

    while ($input =~ s/($sent_end[^ ]|$notsent_end)*($sent_end +)*//) {
	$Readtext::sent = $&;   #parse into sentences

#this gets rid of single quotes left at the start of a sentence, if a break was made after full stop in the previous sentence
	$Readtext::sent =~ s/^[\'\`] //;

#step through word by word
#get rid of punctuation and save
#single quote tricky (confusable with apostrophe), so is hyphen/dash

	$Readtext::sent =~ s/^($delpunc)+//;
	while ($Readtext::sent =~ s/^($notpunc)($punc)*//) {
	    my $txtwd = $1;
	    my $tmppunc = $1;  
#correct for wrongly trapped full stops
	    if ($txtwd =~ s/\.$//) { $tmppunc =~ s/^/\./; }

#deal with hyphen by treating it as a punctuation if separated by space
	    if ($txtwd =~ s/\s(\-)\s*$//) {
		$tmppunc = $1;
	    }
#deal with single quotes by finding pairs - first one may not precede certain words, which are in lexicon, must follow space or other punc or start of line
#initially part of word rather than punc
	    if ($singquot == 0) {
		if( ($txtwd !~ /^\'(cause|cos|em|n\'|tis)$/) && ($txtwd =~ s/^[\'\`]//)) { 
		    $singquot = 1;
		}
	    }
#second single quote may sometimes follow punctuation - so may occur at end of word, or start of next one.  Sometimes, though, is stranded after a single quote in a separate sentence - potential problem so don't use $singquot == 1 to test
	    if ($txtwd =~ s/[\'\`]$//)   {
		$singquot = 0;
	    }
#may be at start of next string - strip it off, with any following punctuation, here
	    elsif ($Readtext::sent =~ s/^[\'\`]($punc)*//)   {
		my $tmpsav = $1;
		if ($tmpsav =~ /([^\s])/) {
		    $tmppunc = $tmpsav;
		}
		$singquot = 0;
	    }

#NOW GET ACTUAL PRONS

#put in pre-vocalic (and pre-pausal) forms of the etc
#remember vowels are specified in base lexicon form

	    if (($Readtext::sent =~ /($punc)*([\w\-]+)/) && ($lexref->{$2} =~ /^[\{\<] [AEIOUaeiou\@\*\~\-0-9]+ /) && (exists $lexref->{vow_vow}->{$txtwd})) {
		$Readtext::string = join ('#.#', $Readtext::string, $lexref->{vow_vow}->{$txtwd});
           }	    
#put unstressed forms in unless sentence or clause final
	    elsif ( (($Readtext::sent =~ /[^\s]/) && ($tmppunc !~ /$int_end/)) &&
		    (exists $lexref->{uns_uns}->{$txtwd})) {
#'have/had/has' unstressed before past verb only - restress if cat is not VBN
		if ((($oldwd eq "had") || ($oldwd eq "have")
		     || ($oldwd eq "has")) && 
		    ($lexref->{cat_cat}->{$txtwd} !~ /VBN/)) {
		    $Readtext::string =~ s/(\#[^\#]*)h \@ ([dvz][^\#]*)$/$1h \* a $2/;
		}
		$Readtext::string = join ('#.#', $Readtext::string, $lexref->{uns_uns}->{$txtwd});
	    }
	    elsif ($lexref->{$txtwd}) {
#stress shift for adjectives preceding nouns - alter last word added from stress pattern /~ */ to /* ~/
		if (($lexref->{cat_cat}->{$txtwd} =~ /NN(P|S|PS)*/) 
		    && ($oldcat =~ /JJ/)) {
		    $Readtext::string =~ s/(\#[^\*\~\-\#]*)\~([\^\#\*\~\-]*)\*([^\#]*)$/$1\*$2\~$3/;
		}
#'s' in 'dollars','pounds', dropped if it precedes a noun (but not another number)
		elsif (($lexref->{cat_cat}->{$txtwd} =~ /NN(P|S|PS)*/) 
		       && ($lexref->{cat_cat}->{$txtwd} !~ /CD/) 
		    && (($oldwd eq "dollars") ||($oldwd eq "pounds"))) {
		    $Readtext::string =~ s/(\#[^\#]*\> )z (\>[^\#]*)$/$1$2/;
		}
#'have/had' unstressed before past verb only - restress if cat is not VBN
		elsif ((($oldwd eq "had") || ($oldwd eq "have")) && 
	
   ($lexref->{cat_cat}->{$txtwd} !~ /VBN/)) {
		    	 $Readtext::string =~ s/(\#[^\#]*)h \@ ([dv][^\#]*)$/$1h \* a $2/;
		}
#now join pronunciation	of current word
		$Readtext::string = join ('#.#', $Readtext::string, $lexref->{$txtwd});
#store old cat to see if it's an adjective in next round
	    }

	    else {
		$Readtext::string = join ('#.#', $Readtext::string, $txtwd);
		$Readtext::string = join ('', $Readtext::string, " NOT_IN_LEXICON");
          }
	    $oldcat = $lexref->{cat_cat}->{$txtwd};
	    $oldwd = $txtwd;
	}
	
$Readtext::string =~ s/^\#\.//;
	$Readtext::string =~ s/$/\#/;
	return "$Readtext::string\n";
    }
}


sub preprocess {
    my ($tmpsent) = @_;
    my $newsent = "";
    my $NUM;

    $tmpsent =~ s/^/ /;
    $tmpsent =~ s/$/ /;


#VARIOUS SYMBOLS
#NB improved by dropping the s before a noun - see pronunciation lines in make_sent_and_transform
    $tmpsent =~ s/\%/ percent/g;

    $tmpsent =~ s/([0-9])ft([^a-z])/$1 foot$2/g;
    $tmpsent =~ s/([0-9])x([0-9])/$1 by $2/g;

#NB m can be million, mile etc.
    $tmpsent =~ s/\$([0-9]+[,\.]*[0-9]*)m/$1 million dollars/g;
    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)m\$/$1 million dollars/g;
    $tmpsent =~ s/\£([0-9]+[,\.]*[0-9]*)m/$1 million pounds/g;
    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)m\£/$1 million pounds/g;

    $tmpsent =~ s/\$([0-9]+[,\.]*[0-9]*)bn/$1 billion dollars/g;
    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)bn\$/$1 billion dollars/g;
    $tmpsent =~ s/\£([0-9]+[,\.]*[0-9]*)bn/$1 billion pounds/g;
    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)bn\£/$1 billion pounds/g;

    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)bn([^a-z])/$1 billion$2/g;

    $tmpsent =~ s/\$(1)\.([0-9])/$1 dollar $2/g;
    $tmpsent =~ s/\$(1[^0-9,\.])/$1 dollar/g;
    $tmpsent =~ s/([^0-9]1)\$/$1 dollar/g;
    $tmpsent =~ s/([^0-9]1)\.([0-9])\$/$1 dollar $2/g;
    $tmpsent =~ s/\$([0-9]+)\.([0-9]+)/$1 dollars $2 /g;
    $tmpsent =~ s/([0-9]+)\.*([0-9]+)\$/$1 dollars $2 /g;
    $tmpsent =~ s/\$([0-9]+,*[0-9]*)/$1 dollars/g;
    $tmpsent =~ s/([0-9]+,*[0-9]*)\$/$1 dollars/g;

    $tmpsent =~ s/\£(1)\.([0-9])/$1 pound $2/g;
    $tmpsent =~ s/\£(1[^0-9,\.])/$1 pound/g;
    $tmpsent =~ s/([^0-9]1)\£/$1 pound/g;
    $tmpsent =~ s/([^0-9]1),*([0-9])\£/$1 pound $2/g;
    $tmpsent =~ s/\£([0-9]+)\.([0-9]+)/$1 pounds $2 /g;
    $tmpsent =~ s/([0-9]+)\.*([0-9]+)\£/$1 pounds $2 /g;
    $tmpsent =~ s/\£([0-9]+,*[0-9]*)/$1 pounds/g;
    $tmpsent =~ s/([0-9]+,*[0-9]*)\£/$1 pounds/g;
    $tmpsent =~ s/([^0-9]1)p([^a-z])/$1 penny$2/g;
    $tmpsent =~ s/([0-9]+[,\.]*[0-9]*)p([^a-z])/$1 pence$2/g;

#WEB ADDRESSES - disallow ) to make matching easier
    while ($tmpsent =~ /(((http\:\/\/|www)+)(\.[^\s\.\n\)]+)*)\b/) {
	my $first = $`;
	my $url = $1;
	my $copy = $url;
	$copy =~ s/http:\/\// h t t p /;       #put spaces in to treat them as letters
	$copy =~ s/www/ w w w /;       #put spaces in to treat them as letters
	$copy =~ s/\./ dot /g;
	$copy =~ s/\// forward slash /g;
	$tmpsent =~ s/\b\Q$url\E\b/$copy/;
    }

#POSTCODES
    while ($tmpsent =~ /\b([A-Z][A-Z][0-9]{1,2} [0-9][A-Z][A-Z])\b/) {
	my $first = $`;
	my $postcode = $1;
	my $last = $';
	my $copy = $postcode;
	$copy =~ s/(.)/$1 /g;       #put spaces in to treat them as letters
	$tmpsent =~ s/\b$postcode\b/$copy/;
    }

#PHONE NUMBERS (let's just do xxx-xxx or 0xxx-xxx-xxx)
    while ($tmpsent =~ /\b((0[0-9][0-9][0-9])*\-[0-9][0-9][0-9]\-[0-9][0-9][0-9][0-9])\b/) {
	my $first = $`;
	my $phone = $1;
	my $last = $';
	my $copy = $phone;
	$copy =~ s/(.)/$1 /g;       #put spaces in to treat them as letters
	$copy =~ s/0/zero/g;
	$tmpsent =~ s/\b$phone\b/$copy/;
    }


#NUMBERS - quick fix to cover most numbers and situations, NOT comprehensive or 100% accurate

#let's assume most 1xxx numbers are dates
#not done as while s/// since that doesn't work if dates only separated by one char
    while ($tmpsent =~ /([^0-9]1[0-9])([0-9][0-9][^0-9])/) {
	$tmpsent =~ s/([^0-9]1[0-9])([0-9][0-9][^0-9])/ $1 $2/;
    }

#decimals (not as money)
    $tmpsent =~ s/\b0\.([0-9])/nought point $1/g;
    $tmpsent =~ s/([^\$\£][0-9]+)\.([0-9]+[^\$\£])/$1 point $2/g;
    $tmpsent =~ s/^([0-9]+)\.([0-9]+[^\$\£])/$1 point $2/g;
#does 0-999, and thousands not already parsed as dates e.g. 7,000, 7000, up to 999,999


#remove , from nums
    $tmpsent =~ s/([0-9])\,([0-9])/$1$2/g;
    while ($tmpsent =~ /[^0-9]([0-9]{1,6})[^0-9]/) {
	$NUM = $1;
	my $REPLACE = &do_nums($NUM);
	$tmpsent =~ s/$NUM/$REPLACE/;
    }

#ACRONYMS
#a few acronyms (remember text is still case-differentiated (at least, most texts are) - can add more here, if they are letter-by-letter pronunciations
    my $acro = 'US|UN|SAS|KGB|CEO|TV|UK|GEC|MP|PM|AM|ATM|MI5|MI6|PR|GM|ID|FBI|DNA|MSc|PhD|BBC';

    while ($tmpsent =~ /\b($acro)\b/) {  #\W is non-word char
	my $first = $`;
	my $acromatch = $1;
	my $last = $';
	my $copy = $acromatch;
	$copy =~ s/(.)/$1 /g;       #put spaces in to treat them as letters
	$tmpsent =~ s/\b$acromatch\b/$copy/;
    }
    $tmpsent =~ s/^ //;
    $tmpsent =~ s/ $//;
    return $tmpsent;
}

sub do_nums {
    my ($tmpnum) = @_;
    my $tmpnumsav = $tmpnum;
    $newnum = "";

#xx,xxx - big thousands
    if ($tmpnumsav =~ /^([1-9][0-9]{1,2})([0-9][0-9][0-9])$/) {
	$tmpnum = $1;
	&do_num_parts ($tmpnum);
	$newnum = join ('', $newnum, " thousand ");
	$tmpnumsav =~ /^([1-9][0-9][0-9]*),*([0-9][0-9][0-9])$/;
	$tmpnum = $2;
    }
    $newnum = &do_num_parts($tmpnum);
    return "$newnum";
}

sub do_num_parts {
    my ($tmpnum) = @_;
#x,xxx - thousands
    if ($tmpnum =~ s/^([1-9])([0-9][0-9][0-9])$/$2/) {
	if ($1 eq "1") {
	    $newnum = "one thousand";
	}
	elsif ($1 eq "2") {
	    $newnum = "two thousand";
	}
	elsif ($1 eq "3") {
	    $newnum = "three thousand";
	}
	elsif ($1 eq "4") {
	    $newnum = "four thousand";
	}
	elsif ($1 eq "5") {
	    $newnum = "five thousand";
	}
	elsif ($1 eq "6") {
	    $newnum = "six thousand";
	}
	elsif ($1 eq "7") {
	    $newnum = "seven thousand";
	}
	elsif ($1 eq "8") {
	    $newnum = "eight thousand";
	}
	elsif ($1 eq "9") {
	    $newnum = "nine thousand";
	}
	if ($tmpnum !~ s/000//) {
	    $newnum = join ('', $newnum, " and ");
	}
	$tmpnum =~ s/^0+//;
    }
#100-999
    if ($tmpnum =~ s/([1-9])([0-9][0-9])/$2/) {
	if ($1 eq "1") {
	    $newnum = join ('', $newnum, "one hundred");
	}
	elsif ($1 eq "2") {
	    $newnum = join ('', $newnum, "two hundred");
	}
	elsif ($1 eq "3") {
	    $newnum = join ('', $newnum, "three hundred");
	}
	elsif ($1 eq "4") {
	    $newnum = join ('', $newnum, "four hundred");
	}
	elsif ($1 eq "5") {
	    $newnum = join ('', $newnum, "five hundred");
	}
	elsif ($1 eq "6") {
	    $newnum = join ('', $newnum, "six hundred");
	}
	elsif ($1 eq "7") {
	    $newnum = join ('', $newnum, "seven hundred");
	}
	elsif ($1 eq "8") {
	    $newnum = join ('', $newnum, "eight hundred");
	}
	elsif ($1 eq "9") {
	    $newnum = join ('', $newnum, "nine hundred");
	}
#country-dependent
	if ($tmpnum !~ s/00//) {
	    if ($Readtext::towns->{$Readtext::loc}->{CNY} eq "US") {
		$newnum = join ('', $newnum, " ");
	    }
	    else {
		$newnum = join ('', $newnum, " and ");
	    }
	}
	$tmpnum =~ s/^0+//;
    }

    if ($tmpnum =~ s/^0([0-9])$/$1/) {  #this mostly for dates, e.g. 1901
	$newnum = join ('', $newnum, " o ");
    }
#10-19
    if ($tmpnum =~ s/^1([0-9])$//) {
	if ($1 eq "0") {
	    $newnum = join ('', $newnum, "ten");
	}
	elsif ($1 eq "1") {
	    $newnum = join ('', $newnum, "eleven");
	}
	elsif ($1 eq "2") {
	    $newnum = join ('', $newnum, "twelve");
	}
	elsif ($1 eq "3") {
	    $newnum = join ('', $newnum, "thirteen");
	}
	elsif ($1 eq "4") {
	    $newnum = join ('', $newnum, "fourteen");
	}
	elsif ($1 eq "5") {
	    $newnum = join ('', $newnum, "fifteen");
	}
	elsif ($1 eq "6") {
	    $newnum = join ('', $newnum, "sixteen");
	}
	elsif ($1 eq "7") {
	    $newnum = join ('', $newnum, "seventeen");
	}
	elsif ($1 eq "8") {
	    $newnum = join ('', $newnum, "eighteen");
	}
	elsif ($1 eq "9") {
	    $newnum = join ('', $newnum, "nineteen");
	}
    }
#20-99
    elsif ($tmpnum =~ s/^([2-9])([0-9])$/$2/) {
	if ($1 eq "2") {
	    $newnum = join ('', $newnum, "twenty");
	}
	elsif ($1 eq "3") {
	    $newnum = join ('', $newnum, "thirty");
	}
	elsif ($1 eq "4") {
	    $newnum = join ('', $newnum, "forty");
	}
	elsif ($1 eq "5") {
	    $newnum = join ('', $newnum, "fifty");
	}
	elsif ($1 eq "6") {
	    $newnum = join ('', $newnum, "sixty");
	}
	elsif ($1 eq "7") {
	    $newnum = join ('', $newnum, "seventy");
	}
	elsif ($1 eq "8") {
	    $newnum = join ('', $newnum, "eighty");
	}
	elsif ($1 eq "9") {
	    $newnum = join ('', $newnum, "ninety");
	}
	if ($2 =~ /[1-9]/)  {
	    $newnum = join ('', $newnum, '-');
	}
	else {
	    $tmpnum =~ s/0//;
	}
    }
#second digit of 21-99, and 0-9
    if ($tmpnum =~ s/^([0-9])$//) {
	if ($1 eq "0") {
	    $newnum = join ('', $newnum, 'zero');
	}
	elsif ($1 eq "1") {
	    $newnum = join ('', $newnum, "one");
	}
	elsif ($1 eq "2") {
	    $newnum = join ('', $newnum, "two");
	}
	elsif ($1 eq "3") {
	    $newnum = join ('', $newnum, "three");
	}
	elsif ($1 eq "4") {
	    $newnum = join ('', $newnum, "four");
	}
	elsif ($1 eq "5") {
	    $newnum = join ('', $newnum, "five");
	}
	elsif ($1 eq "6") {
	    $newnum = join ('', $newnum, "six");
	}
	elsif ($1 eq "7") {
	    $newnum = join ('', $newnum, "seven");
	}
	elsif ($1 eq "8") {
	    $newnum = join ('', $newnum, "eight");
	}
	elsif ($1 eq "9") {
	    $newnum = join ('', $newnum, "nine");
	}
    }
    return "$newnum";
}


1;
__END__
    
# Documentation
    
    =head1 NAME
    
    Readtext - Perl extension for unisyn programs
    
    =head1 SYNOPSIS
    
    use Readtext;
    
    =head1 DESCRIPTION
    
    Two functions:
    1 parse lexicon with exceptions in to a format ready for constructing pronunciation strings
    2 to turn text into pronunciation strings - no accent-specific rules here at present
    
    
    =head2 EXPORT
    
    None by default.
    
    
    =head1 AUTHOR
    
    S. Fitt
    
    =head1 SEE ALSO
    
    perl(1).
    
    =cut
