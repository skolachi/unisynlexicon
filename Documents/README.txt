Unisyn version 1.3
Author:  Susan Fitt 
         Centre for Speech Technology Research
         University of Edinburgh
 	 unisyn@fittconway.plus.com

For further information, or to report bugs, mail the author
or see CSTR Unisyn project website, www.cstr.ed.ac.uk/projects/unisyn/

This lexicon and supporting scripts are released free of charge for 
use for ACADEMIC AND RESEARCH PURPOSES ONLY.


The tar file should contain the following files:


-------------
Documentation:

	BUG_FIXES.txt
	README.txt
	Documentation1_3.pdf
	Unisyn_Lexicon_License.pdf

-------------
Lexicon:

	unilex

-------------
Scripts are written for perl 5.6.0 and will not run under earlier versions.
Scripts:

	check-phon.pl
	check-trans.pl
	create-unilex-template.pl
	get-exceptions.pl
	make-lex.pl
	map-unique.pl
	output-fest.pl
	output-ipa.pl
	output-sam.pl
	post-lex-rules.pl
	read-text.pl
	transform-text.pl

-------------
Modules:

	Readtext.pm

-------------
Supporting files:

	uni_freqs
	uni_scores
	uni_towns
	uni_positions
	uni_rules
	uni_exceptions
	uni_sam

-------------
To get started, read the documentation, or try transform-text.pl to see 
what the system can do.

-------------
Known Bugs:

- transform-text.pl: typing 0 at the standard input subcommand line equates to 
typing 'return' (i.e. quits subcommand line)
- Documentation1_3.pdf: p. 59, vowel V1 ('anchovy') maps to 'v' in US accents,
 not '@'
- Documentation1_3.pdf: p. 66, tertiary stress should display as '-' (hyphen)


------------
Improvements and bug fixes since 1.1 (see also BUG_FIXES.txt)

check-phon.pl:     now has -a option to allow certain accent-specific phonotactic 
                   checks, and -m option to allow checking of intermediate lexica

check-trans.pl:    now has -m option to allow checking of intermediate lexica

create-unilex-template.pl: new script which reads a word list and creates from it 
                   an entry template for adding new words to unilex

make-lex.pl:       now has -r option to allow retention of word-final /r/ in lexica for 
                   r-linking accents, e.g. RP. 

output-sam.pl:     bug fix to include affix boundaries in symbol matches

post-lex-rules.pl: 3 new variables used in matches:
                   $v_n_schwa, $b_int_sll - used to improve resyllabification rules. 
                   Also, resyllabification now does not occur across word or compound 
                   boundaries
                   $b_frf_n_sll - improves do_sus_weak function

		   bug fix in regexp for do_sus_break

		   now has -r option to allow retention of word-final /r/ in lexica for 
                   r-linking accents, e.g. RP. This option is available via make-lex.pl 
                   but not transform-text.pl
		   
read-text.pl       minor changes for parsing strings of initials, e.g. in names such 
                   as S.E. Fitt		   
		   
transform-text.pl  minor change for parsing strings of initials

uni_exceptions     bug fixes for 'queensland' (Australian accent) and 'durham' (New 
                   York accent)

uni_rules          additions to allowed strings to account for certain accents 
                   (e.g. /ng g d/ is an allowable cluster in New York, and /a @/ in 
                   Southern American)

uni_sam            bug fix changing symbol M to W

unilex             addition of 982 entries, around 886 new headwords

		   correction of a number of morphological errors (e.g. 'cryptologies'). 
                   (Please note that a number of morphological inaccuracies still remain 
                   unfixed due to resource constraints.)

                   some pronunciation additions and corrections (e.g. 'bialystok', 'charles')


Many thanks to the users of unisyn for finding errors and making suggestions.

PLEASE NOTE THAT THE PDF DOCUMENTATION HAS NOT BEEN UPDATED.

