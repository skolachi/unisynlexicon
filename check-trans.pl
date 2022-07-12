#!/usr/bin/perl
#checks transcriptions for validity
#checks RP and US versions, so two error messages may be given for one error

#use strict;
#use diagnostics;


use FindBin;
use lib $FindBin::Bin;
use Getopt::Std;
getopts('lmd');

our ($opt_l,$opt_d, $opt_m);

my ($error, $entry, $tmppron, $x);

#stores allowed positions from POSI file
my (%posinit, %posstress, %possyllcons, %posvowel, %posfin, %boundary);

#parts of transcription
my ($cats, $pron, $ortalign);      

unless (($#ARGV == 0)&& (($opt_l) || ($opt_m) || ($opt_d))) { die "\nusage: check-trans.pl -[lmd] [inputfile]\n\nchecks transcription format
-l option checks base lexicon, -m checks intermediate lexicon (from get-exceptions.pl or post-lex-rules.pl), -d option checks derived lexicon
\n";}

if ($opt_l) {$x = "[\+0]bas";}
elsif ($opt_d) {$x = "[\-0]bas";}
elsif ($opt_m) {$x = "[\+\-0]bas";}


our $IN = $ARGV[0];
open (IN) || die "Cannot open $IN for input: $1\n";

our $POSI = "$FindBin::Bin/uni_positions";
open (POSI) || die "Cannot open $POSI: $1\n";

&get_positions;			# reads in possible keysymbols
sub get_positions {
    while (<POSI>){
	chop;
	if ($_ =~ /^Cons:([^ ]+)(.*\[\+ini\].*)/) {
	    $posinit{$1} = $2;
	}
	if ($_ =~ /^Cons:([^ ]+)(.*\[\+syl\].*)/) {
	    $possyllcons{$1} = $2;
	}
	if ($_ =~ /^Cons:([^ ]+)(.*\[\+fin\].*)/) {
	    $posfin{$1} = $2;
	}
	elsif ($_ =~ /^Stress:([^ ]+)(.*)/) {
	    $posstress{$1} = $2;
	}
	elsif ($_ =~ /^Vowel:([^ ]+)(.*)/) {
	    $posvowel{$1} = $2;
	}
	elsif ($_ =~ /^Bound:([^ ]+)(.*)/) {
	    $boundary{$1} = $2;
	}
    }	
}

#don't bother with clusters etc - use check_uni_phon for that


while (<IN>) {
    chop;
    $entry = $_;
    if ($entry =~ /^([a-z\'\.\-]+):([^:]*):([A-Z\$\|\/]+): ([\{\<][a-z0-9A-Z\@ \!\^\?\-\~\*\.\[\]\/*\(\)\>\<\}\{\$\=\;]+[\}\>]) :([a-z\'\.\{\}\=\<\>\-]*):[0-9]*$/) {
	$cats = $3;
	$pron = $4;
	$ortalign = $5;
	&checkcat;
	&checkpron;
    }
    elsif ($entry =~ /^([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$/) {
	$wd = $1;
	$sem = $2;
	$cats = $3;
	$pron = $4;
	$ortalign = $5;
	$freq = $6;
	$error = "can't match line";
	if ($wd !~ /^[a-z\'\.\-]+$/) {
	    $error = join (',', $error, " error may be in word field \'$wd\'");
	}
	if ($cats !~ /^[A-Z\$\|\/]+$/) {
	    $error = join (',', $error, " error may be in cats field \'$cats\'");
	}
	if ($pron !~ /^ [\{\<] ([a-z0-9A-Z\@\!\^\?\-\~\*\.\[\]\/*\(\)\>\<\}\{\$\=\;]+ )+[\}\>] $/) {
	    $error = join (',', $error, " error may be in pron field \'$pron\'");
	}
	if ($ortalign !~ /^[a-z\'\.\{\}\=\<\>\-]*$/) {
	    $error = join (',', $error, " error may be in alignment field \'$ortalign\'");
	}
	&error;
    }
    elsif (/./) {
	$error = "can't match line, may be incorrect number of fields";
	&error;
    }
}

print "finished checking file \'$IN\'\n";

sub checkcat {
    while ($cats =~ s/^([A-Z]+)(\_[a-z\-]+)*[\|\/]*//) {
	my $cat = $1;
#list of possible cats
	if ($cat !~ /^(NN|NNS|NNP|NNPS|VB|VBZ|VBP|VBD|VBN|VBG|JJ|JJR|JJS|RB|RBR|UH|POS|FW|MD|PRP|DT|IN|CC|CD|WP|LS|RP|EX|TO|PRP\$|WP\$|WRB|RBS|PDT|WDT)$/) {
	    $error = "can't match cat $cat";
	    &error;
	}
    }
}

sub checkpron {
#done bracket matching but nothing more complex re brackets
#haven't included allophones here

    $tmppron = $pron;

#general format    
    &brackets;
#reset tmppron, but remove round and square brackets - leave morpheme brackets
    $tmppron = $pron;
    $tmppron =~ s/[\(\)\[\]]//g;

#reset tmppron - now it's null
#do american sylls
    $tmppron = $pron;
#    $tmppron =~ s/[\{\}\<\>\$]//g;
    $tmppron =~ s/  / /g;
    $tmppron =~ s/ \[[^1\]]*\] / /g;
    $tmppron =~ s/(\[|1\])//g;
    $tmppron =~ s/ \(([^\/]*)\/([^\)]+)\) / $2 /g;
    $tmppron =~ s/ ([^ ]+)\/([^ ]+) / $2 /g;
    &symbols;			# checks all units are valid symbols

#do british sylls    
    $tmppron = $pron;
#    $tmppron =~ s/[\{\}\<\>\$]//g;
    $tmppron =~ s/  / /g;
    $tmppron =~ s/ \[[^\]]*1\] / /g;
    $tmppron =~ s/[\[\]]//g;
    $tmppron =~ s/ \(([^\/]*)\/([^\)]+)\) / $1 /g;
    $tmppron =~ s/ ([^ ]+)\/([^ ]+) / $1 /g;
    &symbols;			# checks all units are valid symbols
}


sub symbols {
    while ($tmppron =~ s/([^ \/]+)[ \/]*//) {
	my $symbol = $1;
#consonant
	unless( ((exists ($posinit{$symbol})) && ($posinit{$symbol} =~ /$x/)) ||
#stress
	       ( (exists ($posstress{$symbol})) &&($posstress{$symbol} =~ /$x/)) ||
#vowel	
	       ((exists ($posvowel{$symbol})) && ($posvowel{$symbol} =~ /$x/)) ||
#syll cons
	       ((exists ($possyllcons{$symbol})) && ($possyllcons{$symbol} =~ /$x/)) ||
#final cons
	       ((exists ($posfin{$symbol})) &&($posfin{$symbol} =~ /$x/)) ||
#boundaries
	       ((exists ($boundary{$symbol})) && ($boundary{$symbol} =~ /$x/)) ||
#special case for .4 - not in list as a symbol
	       ($symbol eq ".4")) {
	    $error = "can't match symbol $symbol";
	    &error;
	}
    }
}

sub brackets {
#matching square and round brackets (pron)
    while ($tmppron =~ s/\[//) {
	if ($tmppron !~ s/\]//) {
	    $error = "mismatched \[\]";
	    &error;
	}
    }
    while ($tmppron =~ s/\]//) {
	if ($tmppron !~ s/\[//) {
	    $error = "mismatched \[\]";
	    &error;
	}
    }
    while ($tmppron =~ s/\(//) {
	if ($tmppron !~ s/\)//) {
	    $error = "mismatched \(\)";
	    &error;
	}
    }
    while ($tmppron =~ s/\(//) {
	if ($tmppron !~ s/\)//) {
	    $error = "mismatched \(\)";
	    &error;
	}
    }

#save count to match with ort, except square or round
    my $countbrpron = 0;
#matching curly and angle brackets (morpheme), and == (joined bound morphemes)
    while ($tmppron =~ s/\{//) { # nb opposite directions for curlies
	$countbrpron++;
	if ($tmppron !~ s/\}//) {
	    $error = "mismatched \{\}";
	    &error;
	}
    }
    while ($tmppron =~ s/\}//) {
	$countbrpron++;
	if ($tmppron !~ s/\{//) {
	    $error = "mismatched \{\}";
	    &error;
	}
    }
    while ($tmppron =~ s/\<//) {  #nb same direction for angles
	$countbrpron++;
	if ($tmppron !~ s/\<//) {
	    $error = "mismatched \<\<";
	    &error;
	}
    }
    while ($tmppron =~ s/\>//) {
	$countbrpron++;
	if ($tmppron !~ s/\>//) {
	    $error = "mismatched \>\>";
	    &error;
	}
    }
    while ($tmppron =~ s/\=//) {
	$countbrpron++;
	if ($tmppron !~ s/\=//) {
	    $error = "mismatched \=\=";
	    &error;
	}
    }

#matching ort brackets
#matching curly and angle brackets (morpheme), and == (joined bound morphemes)
    my $countbrort = 0;
    my $tmport = $ortalign;
    while ($tmport =~ s/\{//) { # nb opposite directions for curlies
	$countbrort++;
	if ($tmport !~ s/\}//) {
	    $error = "mismatched \{\}";
	    &error;
	}
    }
    while ($tmport =~ s/\}//) {
	$countbrort++;
	if ($tmport !~ s/\{//) {
	    $error = "mismatched \{\}";
	    &error;
	}
    }
    while ($tmport =~ s/\<//) {  #nb same direction for angles
	$countbrort++;
	if ($tmport !~ s/\<//) {
	    $error = "mismatched \<\<";
	    &error;
	}
    }
    while ($tmport =~ s/\>//) {
	$countbrort++;
	if ($tmport !~ s/\>//) {
	    $error = "mismatched \>\>";
	    &error;
	}
    }
    while ($tmport =~ s/\=//) {
	$countbrort++;
	if ($tmport !~ s/\=//) {
	    $error = "mismatched \=\=";
	    &error;
	}
    }
#only do for base lexicon - some of them are deleted by map-unique
    if (($countbrort != $countbrpron)  &&  ($ARGV[0] eq "-l")) {
	$error = "mismatched brackets in orthography and pronunciation";
	&error;
    }
}

sub error {
    print "error \"$error\" in entry\n\t $entry\n";
}

