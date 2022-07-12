;;; Unilex scheme definition.

;; EDI version with Gorbals addenda based on jane data: for use with jane voice
;; Due to inter-variation among the Gorbals speakers a separate lexicon is required for each; 
;; ediG is for use with john voice (male 60s) 
;; ediG2 is for use with jane voice (female 30s-40s) 
;; and ediG3 will be for use with emma voice (female teenager)

(defvar unilexdir (path-append lexdir "unilex"))

(require 'pos)
(require 'unilex_phones)

(define (unilex-ediG3_lts_function word feats)
  "(unilex-ediG3_lts_function word feats)
Function called for UNILEX when word is not found in lexicon.  Uses
LTS rules trained from the original lexicon, and lexical stress
prediction rules."
  (require 'lts)
  (if (not (boundp 'unilex-edi_lts_rules))
      (load (path-append unilexdir "unilex-edi_lts_rules.scm")))
  (let ((dcword (downcase word))
        (syls) (phones))
    (if (string-matches dcword "[a-z\-]*")
        (begin
          (set! phones (lts_predict dcword unilex-edi_lts_rules))
          (set! syls (lex.syllabify.phstress phones))
          )
        (set! syls nil))
    (list word nil syls)))

;; This list is built by manually taking pronounciations for abbreviations
;; from their full entries in the compiled lexicon.

(define (unilex-ediG3_addenda)
  "(unilex-ediG3_addenda)
Add entries to the current lexicon.  These are basically
words that are not in the keyword lexicon."
(lex.add.entry
   '("Jan" nnp ((( jh a ) 1)((n y uu @r ) 0)((t^ ii ) 0))))
  (lex.add.entry
   '("Feb" nnp ((( f e ) 1)((b r uu @r ) 0)((t^ ii ) 0))))
  (lex.add.entry
   '("Mar" nnp  ((( m ar r ch ) 1))))
  (lex.add.entry
   '("Apr" nnp ((( ei ) 1)((p r i l ) 0))))
  (lex.add.entry
   '("Jun" nnp ((( jh uu n ) 1))))
  (lex.add.entry
   '("Jul" nnp  (((jh uu ) 0)(( l ae ) 1))))
  (lex.add.entry
   '("Aug" nnp ((( oo ) 1)((g @ s t ) 0))))
  (lex.add.entry
   '("Sep" nnp (((s e p ) 0)(( t e m ) 1)((b @r r ) 0))))
  (lex.add.entry
   '("Sept" nnp (((s e p ) 0)(( t e m ) 1)((b @r r ) 0))))
  (lex.add.entry
   '("Oct" nnp (((oo k ) 0)(( t ou ) 1)((b @r r ) 0))))
  (lex.add.entry
   '("Nov" nnp (((n ou ) 0)(( v e m ) 1)((b @r r ) 0))))
  (lex.add.entry
   '("Dec" nnp (((d i ) 0)(( z e m ) 1)((b @r r ) 0))))
  (lex.add.entry
   '("'s" pos (((@ z) 0))))
  (lex.add.entry 
   '("*" nn ((( a ) 1)((s t @r ) 0)((t^ i s k ) 0))))
  (lex.add.entry 
   '("%" nn (((p @r r ) 0)(( s e n ? ) 1))))
  (lex.add.entry 
   '("&" nn ((( a m ) 1)((p @r r ) 0)(( s a n d ) 2))))
  (lex.add.entry 
   '("$" nn ((( d oo ) 1)((l @r r ) 0))))
  (lex.add.entry 
   '("#" nn ((( h a sh ) 1))))
  (lex.add.entry 
   '("@" n (((ae t) 1))))
  (lex.add.entry 
   '("+" cc ((( p l uh s ) 1))))
  (lex.add.entry 
   '("^" nn ((( k a ) 1)((t^ @ ? ) 0))))
  (lex.add.entry 
   '("~" nn ((( t i l ) 1)((d @ ) 0))))
  (lex.add.entry 
   '("=" nns ((( ii ) 1)((k w @ l z ) 0))))
  (lex.add.entry 
   '("/" nn ((( s l a sh ) 1))))
(lex.add.entry 
   '("\\" nn ((( b a k ) 1)(( s l a sh ) 3))))
  (lex.add.entry 
   '("_" nn ((( uh n ) 1)((d @r r ) 0)(( s k our r ) 2))))
  (lex.add.entry 
   '("|" nn ((( v er r ) 2)((? i ) 0)((k l! ) 0)(( b ar r ) 1))))
  (lex.add.entry 
   '(">" nn ((( g r ei ? ) 1)((@r r ) 0)(( dh @ n ) 0))))
  (lex.add.entry 
   '("<" nn ((( l e s ) 1)(( dh @ n ) 0))))
  (lex.add.entry 
   '("[" nn ((( l e f t ) 3)(( b r a ) 1)((k i ? ) 0))))
  (lex.add.entry 
   '("]" nn ((( t^ ai ? ) 3)(( b r a ) 1)((k i ? ) 0))))
  (lex.add.entry 
   '(" " nn ((( s p ei s ) 1))))
  (lex.add.entry 
   '("\t" nn  ((( t a b ) 1))))
  (lex.add.entry 
   '("\n" nn  ((( n y uuu ) 1)(( l ai n ) 3))))
  (lex.add.entry '("." punc nil))
  (lex.add.entry '("'" punc nil))
  (lex.add.entry '(":" punc nil))
  (lex.add.entry '(";" punc nil))
  (lex.add.entry '("," punc nil))
  (lex.add.entry '("-" punc nil))
  (lex.add.entry '("\"" punc nil))
  (lex.add.entry '("`" punc nil))
  (lex.add.entry '("?" punc nil))
  (lex.add.entry '("!" punc nil))

;; Gorbals emma addenda - Glaswegian words and variants for this speaker
;; also includes pseudo words for disfluencies
;; some words are from the john and jane data, retained here to extend the addenda for emma

	(lex.add.entry
   		'("a" (dt full) (((uh) 1))))
	(lex.add.entry
   		'("a" (dt reduced) (((@) 0))))
       	(lex.add.entry
   		'("a" (in full) (((uh) 1)))) ;; Glaswegian a = "of"
    	(lex.add.entry
    		'("a" (in reduced) (((@) 0))))	;; Glaswegian a = "of"	
	(lex.add.entry
   		'("aboot" in (((@) 0) ((b uu ?) 1))))
	(lex.add.entry
   		'("accent" nn (((a k) 1) ((s e n ?) 0)))) ;; emma + jane instead of s n! ?
	(lex.add.entry
   		'("accents" nns (((a k) 1) ((s e n ? s) 0)))) ;; emma instead of s n! ? s
      (lex.add.entry
   		'("ach" uh (((@ x) 1))))
     (lex.add.entry 
		'("Aez" prp|vbp  (((ei z) 0)))) ;; emma I's for I'm
	(lex.add.entry
   		'("akch" nil (((a k ch ) 1)))) ;; cut off version of "actually" in "actually a"
        (lex.add.entry
   		'("actually" rb (((a k) 1) ((ch @ l) 0) ((ii) 0))))
	(lex.add.entry
   		'("aff" in (((a f) 1))))
	(lex.add.entry
   		'("aff" jj (((a f) 1))))
	(lex.add.entry
   		'("aff" nn (((a f) 1))))
	(lex.add.entry
   		'("aff" rp (((a f) 1))))
	(lex.add.entry
   		'("again" rb (((@) 0) ((g ei n) 1)))) ;; nil tag required as build_utts insisting on @ g e n otherwise
	(lex.add.entry
   		'("Ahl" nil (((@ l) 0))))
	(lex.add.entry
   		'("ahv" nil (((a v) 0))))
	(lex.add.entry 
		'("ain" jj (((ei n) 1)))) ;; emma "own" (eg my own area)
	(lex.add.entry 
		'("ait" nil (((ei ?) 0)))) ;; emma variant of "that"
	(lex.add.entry 
		'("akay" nil (((@) 0) ((k ei) 1)))) ;; emma variant of okay
	(lex.add.entry
   		'("alang" in (((@) 0) ((l a ng) 1))))
	(lex.add.entry
   		'("annette's" nnp|vbz (((@) 0) ((n e ? z) 1))))
	(lex.add.entry 
		'("anyhing" nil (((e) 1) ((n i) 0) ((h i n) 0))))
	(lex.add.entry 
		'("anyhoo" nil (((e) 1) ((n ii) 0) ((h uuu) 2))))
	(lex.add.entry
   		'("anymair" rb (((e) 2) ((n ii) 0) ((m eir r) 1))))	
        (lex.add.entry
    		'("ar" nil (((a r) 0))))	 ;; disfluency (jane)
	(lex.add.entry 
		'("araq" nnp (((a) 0) ((t^ a k) 1)))) ;; emma variant pronunciation of Iraq
        (lex.add.entry
    		'("aren't" vbp|rb (((ar r n ?) 1))))
	(lex.add.entry 
		'("ast" vbd (((a s t) 1))))  ;; emma variant "asked"
	(lex.add.entry 
		'("ast" vbn (((a s t) 1))))  ;; emma variant "asked"
        ;; (lex.add.entry
    	;;	'("at" (in full) (((a ?) 1))))
        ;;(lex.add.entry
    	;;	'("at" (in full) (((a t) 1))))	;; ie without T-glottaling
	(lex.add.entry 
		'("ats" nn|vbz (((@ ? s) 1)))) ;; emma - variant of it's
	(lex.add.entry
   		'("auntie's" nn|pos (((a n ?) 1) ((ii z) 0))))
        (lex.add.entry
   		'("auntie's" nn|vbz (((a n ?) 1) ((ii z) 0))))	
	(lex.add.entry 
		'("av" (vb full) (((a v) 1)))) ;; emma (h)ave
	(lex.add.entry 
		'("av" (vb reduced) (((@ v) 0)))) ;; emma (h)ave
	(lex.add.entry 
		'("av" (vbp full) (((a v) 1)))) ;; emma (h)ave
	(lex.add.entry 
		'("av" (vbp reduced) (((@ v) 0)))) ;; emma (h)ave
	(lex.add.entry
   		'("aw" uh (((oo) 1))))  ;; aw, interjection
	(lex.add.entry
   		'("aw" dt (((oo) 1))))  ;; variant of all, everybody
	(lex.add.entry
   		'("aw" pdt (((oo) 1)))) ;; all
	(lex.add.entry
   		'("aw" rb (((oo) 1)))) ;; all
	(lex.add.entry
   		'("awra" pdt|dt (((oo) 1) ((t^ @) 0)))) ;; all the
	(lex.add.entry
   		'("awready" rb (((oo) 2) ((r e) 1) ((d ii) 0))))
	(lex.add.entry
	        '("awright" rb (((oo) 0) ((r ai ?) 1)))) ;; alright
	(lex.add.entry 
		'("az" (vbz full) (((a z) 1)))) ;; emma - (h)as
	(lex.add.entry 
		'("az" (vbz reduced) (((@ z) 0)))) ;; emma - (h)as
	(lex.add.entry 
		'("baft" nn (((b a f t) 1)))) ;; emma - mispronunciation of raft
      (lex.add.entry
	        '("Barras" nnp (((b a) 1) ((t^ @ z) 0)))) ;; Barras market
	(lex.add.entry 
		'("Basti" nnp (((b a s) 1) ((t ii) 0)))) ;; emma -  a friend's nickname?
	(lex.add.entry
   		'("baw" nn (((b oo) 1))))
	(lex.add.entry 
		'("Benidorm" nnp (((b e) 1) ((n i) 0) ((d or r m) 2))))
	(lex.add.entry 
		'("bonin" nil (((b ou n) 1) ((a n) 0)))) ;; emma - ?
	(lex.add.entry
   		'("boxing's" nn|vbz (((b oo k s) 1) ((i n z) 0))))
	(lex.add.entry
   		'("Brigton" nil (((b r i g) 1) ((t @ n) 0))))
	(lex.add.entry
   		'("brilliant" jj (((b r @) 1) ((l y @ n ?) 0))))
	(lex.add.entry
   		'("brooh" nil (((b r uu) 1)))) ;; a disfluency
	(lex.add.entry
   		'("broon" jj (((b r uu n) 1))))
	(lex.add.entry
   		'("broon" nn (((b r uu n) 1))))
	(lex.add.entry
   		'("Broon" nnp (((b r uu n) 1))))
	(lex.add.entry
   		'("brother's" nn|pos (((b r uh) 1) ((dh @r r z) 0))))
	(lex.add.entry
   		'("brother's" nn|vbz (((b r uh) 1) ((dh @r r z) 0))))
       	(lex.add.entry
   		'("bruh" nil (((b r @) 1))))  ;; disfluency (jane)
	(lex.add.entry
   		'("Buckie" nnp (((b uh k) 1) ((ii) 0)))) ;; short form for Buckfast Tonic wine
      	(lex.add.entry
   		'("buh" nil (((b @) 1))))  ;; disfluency (jane)
	(lex.add.entry 
		'("buhdnie" md|rb (((b uh d) 0) ((n ii) 0)))) ;; emma mispronunciation for wouldnae
	;; (lex.add.entry
   	;;	'("built" vbd (((b @ l ?) 1))))
	(lex.add.entry
   		'("built" vbn (((b @ l ?) 1))))
	(lex.add.entry 	
		'("ca" md (((k @) 0)))) ;; emma - shortened form of can
	(lex.add.entry 	
		'("ca" vb (((k @) 0)))) ;; emma - shortened form of can
	(lex.add.entry 	
		'("ca" vbp (((k @) 0)))) ;; emma - shortened form of can
	(lex.add.entry
   		'("Calton" nil (((k a l) 1) ((? @ n) 0))))
	(lex.add.entry
   		'("Cambuslaing" nil (((k a m) 1) ((b @ s) 0) ((l a ng) 2))))
	(lex.add.entry
   		'("cannae" md|rb (((k a) 1) ((n ii) 0))))
	(lex.add.entry
   		'("can't" md|rb (((k a n ?) 1))))
	(lex.add.entry 
		'("Cark" nnp (((k ar r k) 1)))) ;; mispron? of a surname
	(lex.add.entry
   		'("cas" nil (((k a s) 1))))  ;; disfluency (jane)
	(lex.add.entry
   		'("Castlemilk" nnp (((k a) 2) ((s l!) 0) ((m oo l k)  1))))
	(lex.add.entry
   		'("Cathkin" nnp (((k a f) 1) ((k i n) 0)))) ;; jane: th fronting; cathkin is the place but she says almost kafkin
	(lex.add.entry
   		'("Cathie" nnp (((k a th) 1) ((ii) 0))))
	(lex.add.entry
   		'("celtic" nil (((s e l ?) 1) ((i k) 0)))) ;; needed as build_utts insists on keltic
	(lex.add.entry
   		'("chantelle" nnp (((sh @ n) 0) ((t e l) 1)))) ;; emma pron
        (lex.add.entry
   		'("cheerie's" nil (((ch irr t^) 1) ((ii z) 0)))) ;;  representing a Gaelic word jane mentions
	;;(lex.add.entry
   	;;	'("child's" nn|pos (((ch ai l d z) 1))))
      	;;(lex.add.entry
   	;;	'("child's" nn|vbz (((ch ai l d z) 1)))) 
	;;(lex.add.entry
   	;;	'("children's" nns|pos (((ch i l) 1) ((d r @ n z) 0))))
	(lex.add.entry
   		'("christ" nnp (((k r ai s t) 1))))
	(lex.add.entry
   		'("christ's" nnp|pos (((k r ai s t s) 1))))
	(lex.add.entry
   		'("christ's" nnp|vbz (((k r ai s t s) 1))))	
	(lex.add.entry
   		'("chuh" nil (((ch uuu) 1)))) ;; disfluency (jane);  in "do you [know]" chuuu or ch@ know  
	(lex.add.entry
   		'("chuh" nil (((ch @) 0))))
	(lex.add.entry
   		'("claes" nn (((k l ei z) 1))))
	(lex.add.entry
   		'("Croon" nnp (((k r uu n) 1))))
      	(lex.add.entry
   		'("continually" rb (((k uh n) 0) ((t i) 1) ((n y @ l) 0) ((ii) 0))))
        (lex.add.entry
   		'("cos" nil (((k @ z) 0)))) ;; nil tag required as build_utts insisting on s
        (lex.add.entry
   		'("couldn't" md|rb (((k uu d) 1) ((n! ?) 0))))
	(lex.add.entry
   		'("couldnae" md|rb (((k uu d) 1) ((n ii) 0))))
	(lex.add.entry
   		'("Crownie" nnp (((k r ow n) 0) ((ii) 0))))
	(lex.add.entry 
		'("cuhn" nil (((k uh n) 0)))) ;; emma - disfluency
	(lex.add.entry
   		'("dae" vb (((d ei) 1))))
	(lex.add.entry
   		'("dae" nnp (((d ei) 1)))) ;; changed from d ae to try to fix build_utts problem! So this is the wrong pron for dae as nnp but dae as verb more likely in Glaswegian
      (lex.add.entry
   		'("daein" vbg (((d ei) 1) ((i n) 0))))
	(lex.add.entry
   		'("dah" nil (((d @) 0))))
	(lex.add.entry
   		'("dampsies" nns (((d a m p) 1) ((s ii z) 0))))
	(lex.add.entry
   		'("Danny'd" nnp|md (((d a n) 1) ((i d) 0))))
	(lex.add.entry
   		'("Danny'll" nnp|md (((d a n) 1) ((@ l!) 0))))
	(lex.add.entry
   		'("Deanie" nnp (((d ii) 1) ((n ii) 0))))
	(lex.add.entry
   		'("debbie's" nnp|pos (((d e) 1) ((b ii z) 0))))
	(lex.add.entry
   		'("didnae" vbd|rb  (((d i d) 1) ((n ii) 0))))
	(lex.add.entry
   		'("didn't" vbd|rb (((d i d) 1) ((n! ?) 0))))
	(lex.add.entry
   		'("didye" vbd|prp  (((d i) 1) ((ch iii) 0)))) ;; variant of did you in "where did you ..."	
	(lex.add.entry
   		'("dih" nil  (((d @) 0)))) ;; disfluency	
	(lex.add.entry
   		'("dinnae" vbd|rb  (((d i) 1) ((n ii) 0))))
	(lex.add.entry
   		'("doesnae" vbd|rb  (((d uh z) 1) ((n ii) 0))))
	(lex.add.entry
   		'("doesn't" vbz|rb (((d uh z) 1) ((n! ?) 0))))
(lex.add.entry
   		'("donnae" vbd|rb  (((d ou) 1) ((n ii) 0)))) ;; emma variant of dinnae
	(lex.add.entry
   		'("don't" vbp|rb (((d ou n ?) 1))))
	(lex.add.entry
   		'("doon" in (((d uu n) 1))))
	(lex.add.entry 
		'("doun" nil (((d ou n) 1)))) ;; emma - don't
      (lex.add.entry
   		'("drop" vb (((d r a p) 1))))
      (lex.add.entry
   		'("drop" vbp (((d r a p) 1))))
      (lex.add.entry
   		'("drap" vb (((d r a p) 1))))
      (lex.add.entry
   		'("drap" vbp (((d r a p) 1))))
	(lex.add.entry
   		'("drapped" vbd (((d r a p t) 1)))) ;; dropped
	(lex.add.entry
   		'("drapped" vbn (((d r a p t) 1)))) ;; dropped
      	(lex.add.entry
   		'("drapping" vbg (((d r a p) 1) ((i n) 0))))
	(lex.add.entry
   		'("Dreiss" nnp (((d r ii s) 1)))) ;; Christian name, spelling and pron differ from usual rules 
	(lex.add.entry
   		'("dropping" vbg (((d r a p) 1) ((i n) 0))))
      	(lex.add.entry
   		'("dunkies" nns (((d uh ng ) 1) ((k ii z) 0))))
	(lex.add.entry 
		'("dut" vbp|rb (((d uh ?) 0))))  ;; emma - another variant of don't
	(lex.add.entry
   		'("dya" nil (((jh uuu) 1))))	;; in "do you [know]" jh uuu or jh @ know  
        (lex.add.entry
   		'("Edinburghian" jj  (((e) 1) ((d i m) 0) ((b uh) 2) ((t^ ii @ n) 0))))
        (lex.add.entry
   		'("Edinburghian" nn  (((e) 1) ((d i m) 0) ((b uh) 2) ((t^ ii @ n) 0))))
	(lex.add.entry 
		'("ee" uh (((ii) 0)))) ;; interjection
	(lex.add.entry 
		'("eed" vb (((ii d) 1)))) ;; emma - (n)eed
	(lex.add.entry 
		'("eed" vbp (((ii d) 1)))) ;; emma - (n)eed
	(lex.add.entry 
		'("ees" prp|vbz (((iii z) 1)))) ;; emma - (h)e's
	(lex.add.entry
   		'("efter" in (((e f) 1) ((t @r r) 0)))) ;; Glaswegian after
	(lex.add.entry
   		'("ei" in (((ei) 1))))  ;; "of" e.g.  of us sounds like ei us
	(lex.add.entry 
		'("eis" nil (((ei z) 1)))) ;; emma - disfluency
	;;(lex.add.entry
   	;;	'("either" cc (((ii) 1) ((dh @r r) 0)))) ;; need nil tag as otherwise build_utts insists in ae dh @r r
	;;(lex.add.entry
   	;;	'("either" dt (((ii) 1) ((dh @r r) 0)))) ;; need nil tag as otherwise build_utts insists in ae dh @r r
	;;(lex.add.entry
   	;;	'("either" in (((ii) 1) ((dh @r r) 0)))) ;; need nil tag as otherwise build_utts insists in ae dh @r r	
	;;(lex.add.entry
   	;;	'("either" rb (((ii) 1) ((dh @r r) 0)))) ;; need nil tag as otherwise build_utts insists in ae dh @r r
	(lex.add.entry
   		'("er" (prp full) (((er r) 1))))
	(lex.add.entry
   		'("er" (prp reduced) (((@ r) 0))))
	(lex.add.entry
   		'("er" (prp$ full) (((er r) 1))))
	(lex.add.entry
   		'("er" (prp$ reduced) (((@ r) 0))))		
	(lex.add.entry
   		'("errathing" nn (((e t^) 1) ((@) 0) ((th i ng) 2))))
	(lex.add.entry
   		'("ersel" prp (((er) 3) ((s e l) 1))))
	(lex.add.entry 
		'("esel" prp (((@)0 ) ((s e l) 1)))) ;; emma - (h)e(r)sel(f)
	(lex.add.entry
   		'("ev" nil (((e v) 0)))) ;; disfluency
	(lex.add.entry
   		'("evenchlly" rb (((i) 0) ((v e n) 1) ((ch l) 0) ((ii) 0)))) ;; variant of eventually
      (lex.add.entry 
		'("everyhing" nn (((e v) 1) ((r i) 0) ((h i n) 2)))) ;; emma - everything
	(lex.add.entry
   		'("everything's" nn|pos (((e v) 1) ((r i) 0) ((th i ng z) 2))))
	(lex.add.entry
   		'("everything's" nn|vbz (((e v) 1) ((r i) 0) ((th i ng z) 2))))
	(lex.add.entry 
		'("everytime" nn (((e v) 1) ((r i) 0) ((t ai m) 2)))) ;; emma
	(lex.add.entry 
		'("evran" nil (((e v) 1) ((r @ n) 0)))) ;; emma variant of everything
	(lex.add.entry 
		'("expec" vb (((i k) 0) ((s p e k) 1)))) ;; emma - expect
	(lex.add.entry 
		'("expec" vbp (((i k) 0) ((s p e k) 1)))) ;; emma - expect
	(lex.add.entry 
		'("fa" cc (((f @) 0)))) ;; emma - for
	(lex.add.entry 
		'("fa" in (((f @) 0)))) ;; emma - for
	(lex.add.entry
   		'("fae" (in full) (((f ei) 1))))
	(lex.add.entry
   		'("fae" (in reduced) (((f @) 0))))
	(lex.add.entry
   		'("faither" nn (((f ei) 1) ((dh @r r) 0))))
	(lex.add.entry
   		'("faither" nnp (((f ei) 1) ((dh @r r) 0))))
	(lex.add.entry 
		'("fak" nn (((f a k) 1)))) ;; emma - fact 
        (lex.add.entry
   		'("feimily" nn (((f ei) 1) ((m @) 0) ((l ii) 0)))) 
        (lex.add.entry
   		'("feimilies" nn (((f ei) 1) ((m i) 0) ((l ii z) 0)))) ;; jane uses this once, elsewhere pronounces as family in lexicon, so here have different spelling to distinguish
	(lex.add.entry
   		'("feart" jj (((f irr ?) 1))))
      	(lex.add.entry
   		'("fuh" nil (((f) 1))))  ;; disfluency (jane)
	(lex.add.entry 
		'("fi" cc (((f ii) 1)))) ;; emma - for
	(lex.add.entry 
		'("fi" in (((f ii) 1)))) ;; emma - for
	(lex.add.entry
   		'("fif" nil (((f i f) 1))))  ;; disfluency (jane)
	(lex.add.entry 
		'("fighta" nil (((f ai ?) 1) ((@) 0)))) ;; emma - fighting
      (lex.add.entry
   		'("financh" nil (((f ae) 1) ((n a n ch) 0)))) ;; disfluency (jane)
	(lex.add.entry 
		'("firrem" nil (((f i) 1) ((t^ @ m) 0))))  ;; emma - "from them"
	(lex.add.entry
   		'("fitbaw" nn (((f i ?) 1) ((b oo) 3))))
	(lex.add.entry
   		'("folk's" nn|pos (((f ou k s) 1))))
	(lex.add.entry
   		'("folk's" nn|vbz (((f ou k s) 1))))
	(lex.add.entry
   		'("followed" vbd (((f oo) 1) ((l ii d) 0))))
	(lex.add.entry
   		'("followed" vbn (((f oo) 1) ((l ii d) 0))))
	(lex.add.entry
   		'("found" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"	
	(lex.add.entry
   		'("found" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"	
	(lex.add.entry
   		'("fraid" nil (((f r ei d) 1)))) ;; e.g. 'fraid not
        (lex.add.entry
   		'("fuh" nil (((f) 1))))  ;; disfluency (jane)
	(lex.add.entry
   		'("fulla" jj|in (((f uh) 1) ((l @) 0)))) ;; "full of"		
	(lex.add.entry
   		'("fun" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"
	(lex.add.entry
   		'("fun" vbn (((f uh n) 1)))) ;; Glaswegian variant of "found"
      (lex.add.entry 
		'("ga" nil (((g @) 0)))) ;; emma - go(ing) 	
	(lex.add.entry
   		'("guh" nn (((g @) 0)))) ;; disfluency, cut version of gonna
	(lex.add.entry
   		'("gae" nn (((g ei) 1))))
	(lex.add.entry
   		'("gae" vb (((g ei) 1))))
      	(lex.add.entry
   		'("gaelic" jj (((g a l) 1) ((i k) 0))))
	(lex.add.entry
   		'("gaun" vbg (((g oo) 1) ((i n) 0)))) ;; going
	(lex.add.entry 
		'("gauna" nil (((g oo n) 1) ((@) 0)))) ;; emma - going to 
	(lex.add.entry
   		'("gei" nil (((g ei) 1)))) ;; disfluency when saying game (jane)
	(lex.add.entry 
		'("gie" vb (((g iii) 1)))) ;; emma - give
	(lex.add.entry 
		'("gie" vbp (((g iii) 1)))) ;; emma - give
	(lex.add.entry
   		'("Gilmartin" nnp (((g i l) 0) ((m ar r) 1) ((? i n) 0))))
	(lex.add.entry 
		'("gimpy" jj (((g i m p) 1) ((ii) 0)))) ;; emma - ??
	(lex.add.entry
   		'("Glassford" nnp (((g l uh s) 1) ((f @r r d) 0)))) ;; street
      	(lex.add.entry
   		'("Glesga" nnp (((g l e z) 1) ((g @) 0)))) ;; Glasgow
      	(lex.add.entry
   		'("glockenspiel" nn (((g l oo) 1) ((k @ n) 0) ((sh p ii l) 0))))
	(lex.add.entry
   		'("gobsmacked" jj (((g oo b) 1) ((s m a k t) 0))))
	(lex.add.entry
   		'("goh" nil (((g @) 0))))
	(lex.add.entry
   		'("gonnae" vbg|to (((g oo) 1) ((n ii) 0))))
	(lex.add.entry
   		'("Gorbals" nnp (((g our) 1) ((b @ l z) 0))))
	(lex.add.entry 
		'("goti" vb|to (((g ou) 1) ((? ii) 0)))) ;; emma - go to
	(lex.add.entry 
		'("goti" vbp|to (((g ou ?) 1) ((ii) 0)))) ;; emma - go to
	(lex.add.entry 
		'("granda" nn (((g r a n) 1) ((d @) 0)))) ;; emma - grandad
	(lex.add.entry 
		'("groonded" vbd (((g r uu n d) 1) ((i d) 0)))) ;; emma - grounded
	(lex.add.entry 
		'("groonded" vbn (((g r uu n d) 1) ((i d) 0)))) ;; emma - grounded
	(lex.add.entry
   		'("ha'" vb (((h @) 0)))) ;; shortened form of have
	(lex.add.entry
   		'("ha'" vbp (((h @) 0))))	
	(lex.add.entry
   		'("Hallside" nnp (((h oo l ) 0) ((s ai d) 1))))
	(lex.add.entry
   		'("hame" nn (((h ei m) 1))))
	(lex.add.entry
   		'("Hampden" nnp (((h a m) 1) ((d n!) 0))))
	(lex.add.entry
   		'("harmless" jj (((h eir m) 1) ((l @ s) 0))))
	(lex.add.entry 
		'("Hartson" nnp (((h ar r) 1) ((? s n!) 0))))
	(lex.add.entry 
		'("haud" nn (((h oo d) 1)))) ;; emma - hold
	(lex.add.entry 
		'("haud" vb (((h oo d) 1)))) ;; emma - hold
	(lex.add.entry 
		'("haud" vbp (((h oo d) 1)))) ;; emma - hold
	(lex.add.entry
   		'("hauf" nn (((h oo f) 1))))
	;;(lex.add.entry
   	;;	'("have" (vb reduced) (((h @) 0))))
	;;(lex.add.entry
   	;;	'("have" (vbp reduced) (((h @) 0))))
	(lex.add.entry
   		'("he'd" prp|md (((h iii d) 1))))
	(lex.add.entry
   		'("heid" nn (((h ii d) 1))))
       (lex.add.entry
   		'("he'll" prp|md (((h iii l) 1))))
        (lex.add.entry
   		'("here's" nn|vbz (((h irr r z) 1))))
        (lex.add.entry
   		'("here's" rb|vbz (((h irr r z) 1))))
        (lex.add.entry
   		'("he's" (prp|vbz full) (((h iii z) 1))))
      	;;(lex.add.entry
   	;;	'("he's" (prp|vbz reduced) (((h i z) 0))))
        (lex.add.entry
   		'("heterosexual" jj (((h e t) 2) ((t^ @) 0) ((s e k) 1) ((sh @ l) 0))))
       (lex.add.entry
   		'("heterosexual" nn (((h e t) 2) ((t^ @) 0) ((s e k) 1) ((sh @ l) 0))))
       (lex.add.entry
   		'("hing" nn (((h i ng) 1))))
	(lex.add.entry 
		'("hings" nns (((h i ng z) 1))))
	(lex.add.entry
   		'("hink" vb (((h i ng k) 1)))) ;; Glaswegian: think
	(lex.add.entry
   		'("hink" vbp (((h i ng k) 1)))) ;; Glaswegian: think
	(lex.add.entry 
		'("hinking" vbg (((h i ng k) 1) ((i n) 0)))) ;; thinking
	(lex.add.entry 
		'("hinking" nn (((h i ng k) 1) ((i n) 0)))) ;; thinking
	(lex.add.entry 
		'("hinks" vbz (((h i ng k s) 1)))) ;;  "thinks" 
	(lex.add.entry 
		'("hoffah" nil (((h oo f) 1) ((@) 0)))) ;; emma - ?
	(lex.add.entry 
		'("hoffy" nil (((h oo f) 1) ((ii) 0)))) ;; emma - ?
	(lex.add.entry
   		'("home's" nn|pos (((h ou m z) 1))))
	(lex.add.entry
   		'("home's" nn|vbz (((h ou m z) 1))))
	(lex.add.entry
   		'("hoose" nn (((h uu s) 1))))
	(lex.add.entry
   		'("hooses" nns (((h uu s) 1) ((i z) 0))))
	;; (lex.add.entry
   	;;	'("howtuh" nil (((h ow) 1) ((uu @) 0))))	 ;; variation for this speaker "how to"
	(lex.add.entry
   		'("how's" wrb|vbz (((h ow z) 1))))
	(lex.add.entry
   		'("how've" wrb|vbp (((h ow) 1) ((@ v) 0))))
	(lex.add.entry
   		'("i'd" prp|vbp (((a d) 1))))
	(lex.add.entry
   		'("ih" nil (((i y) 0)))) ;; disfluency
 	(lex.add.entry 
		'("illuminous" nil (((i) 0) ((l uu) 1) ((m i) 0) ((n @ s) 0)))) ;; emma (luminous)
	(lex.add.entry
   		'("i'll" prp|md (((ae l) 1))))
      (lex.add.entry
   		'("i'm" prp|vbp (((a m) 1))))
    	(lex.add.entry
    		'("im" prp (((i m) 1)))) ;; emma (h)im
	;;(lex.add.entry 
	;;	'("imm" nil (((i m) 1)))) ;; emma - (h)im 
	(lex.add.entry
   		'("immmm" nil (((i m m m m) 0))))  ;; disfluency 
	(lex.add.entry
   		'("ind" nil (((i n t) 0))))
	(lex.add.entry 
		'("inta" in (((i n) 1) ((? @) 0)))) ;; emma - into
	(lex.add.entry
   		'("intit" vb|rb (((i n) 1) ((i ?) 0))))	
	;; (lex.add.entry
   	;;	'("intit" vb|rb (((i n ?) 1) ((i ?) 0))))
	(lex.add.entry
   		'("int" vb|rb (((i n ?) 0))))
	(lex.add.entry
   		'("intae" in (((i n) 1) ((t ei) 0))))		
	(lex.add.entry
   		'("into" in (((i n) 1) ((t @) 0))))
	(lex.add.entry
   		'("inty" vbz|rb (((i n ?) 1) ((ii) 0))))  ;; isn't he, hasn't he
	(lex.add.entry 
		'("ir" nn (((irr r) 1)))) ;; emma - here
	(lex.add.entry 
		'("ir" rb (((irr r) 1)))) ;; emma - here
	(lex.add.entry 
		'("is" prp (((h i z) 1)))) ;; (h)is
	(lex.add.entry 
		'("is" prp$ (((h i z) 1)))) ;; (h)is
	(lex.add.entry
   		'("i's" prp|vbp (((a z) 1))))
	(lex.add.entry
   		'("isnae" vbz|rb (((i z) 1) ((n ii) 0))))
	(lex.add.entry
   		'("isn't" vbz|rb (((i z) 1) ((n! ?) 0))))
	(lex.add.entry
   		'("it'd" prp|md 	(((i ?) 1) ((@ d) 0))))
	(lex.add.entry
   		'("it'll" prp|md (((i ?) 1) ((l!) 0))))
	(lex.add.entry
   		'("it's" nn|vbz (((i ? s) 1))))
	(lex.add.entry
   		'("i've" prp|vbp (((ae v) 1))))
	(lex.add.entry
   		'("iz-sell" prp (((i z) 3) ((s e l) 1)))) ;; himself	
	(lex.add.entry 
		'("Jarvie" nil (((jh ar r) 1) ((v ii) 0))))
	(lex.add.entry 
		'("Jean" nil (((jh ii n) 1)))) ;; nnp but need nil here or it uses the first itr finds which is the French pronunciation
	(lex.add.entry
   		'("job's" nn|vbz (((jh oo b z) 1))))
      (lex.add.entry 
		'("jsss" nil (((jh s) 1)))) ;; emma - disfluency  
	(lex.add.entry
   		'("juck" nil (((jh uh k) 0))))
	(lex.add.entry
   		'("juh" nil (((jh uh) 1)))) ;; disfluency (jane)
	(lex.add.entry 
		'("jum" nil (((jh @ m) 1)))) ;; emma - disfluency
	(lex.add.entry 
		'("jus" nil (((jh @ s) 1)))) ;; emma - jus(t)
	(lex.add.entry 
		'("ka" nil (((k @) 0)))) ;; emma - ca(n)
	(lex.add.entry
   		'("kah" nil (((k @) 0))))
	(lex.add.entry
   		'("kih" nil (((k @) 0))))
	(lex.add.entry
   		'("Kilburney" nnp (((k i l) 0) ((b @@r r) 1) ((n ii) 0))))
	(lex.add.entry 
		'("killt" vbd (((k i l ?) 1)))) ;; emma - killed
	(lex.add.entry 
		'("killt" vbn (((k i l ?) 1)))) ;; emma - killed
	(lex.add.entry
   		'("koh" nil (((k @) 0))))
	(lex.add.entry
   		'("lah" in (((l @) 1)))) ;; like
        (lex.add.entry
   		'("lah" jj (((l @) 1)))) ;; like
	(lex.add.entry
   		'("laht" nil (((l a ?) 1)))) ;;  instance of "like that"
	(lex.add.entry
   		'("lassie's" (nn|pos girls) (((l a s) 1) ((ii z) 0))))
	(lex.add.entry 
		'("lat" nil (((l a ?) 0)))) ;; emma - like that
	(lex.add.entry
   		'("live" nil (((l i v) 1)))) ;; required only when building utts!!!!!! REMOVE AFTER
	;;(lex.add.entry
   	;;	'("ll" nil (((l) 0)))) ;; hack bug fix for now...build_utts insisting we'll is well so have to separate contraction in utts.data for now (well appears in utts more frequently)
	(lex.add.entry
   		'("lowis" nnp (((l ou) 1) ((i s) 0)))) ;; actually a mispron for Rose
	(lex.add.entry
   		'("lum" nn (((l uh m) 1))))
	(lex.add.entry
   		'("ma" prp$ (((m a) 1))))
	(lex.add.entry 
		'("macadamian" nil (((m @) 2) ((k @) 0) ((d ei) 1) ((m ii) 1) ((@ n) 0)))) ;; emma - ?
	(lex.add.entry
   		'("ma's" nnp|pos (((m a z) 1))))
        (lex.add.entry
   		'("ma's" nnp|vbz (((m a z) 1))))
        (lex.add.entry
   		'("ma's" nn|pos (((m a z) 1))))
        (lex.add.entry
   		'("ma's" nn|vbz (((m a z) 1))))
	(lex.add.entry
   		'("mair" jjr (((m eir r) 1))))
	(lex.add.entry
   		'("mair" rbr (((m eir r) 1))))
	(lex.add.entry
   		'("maw" nn (((m oo) 1))))		;; maw  mother
	(lex.add.entry
   		'("McFaggan" nnp (((m @ k) 0) ((f a jh) 1) ((@ n) 0))))
	(lex.add.entry 
		'("meeta" nil (((m ii) 1) ((? @) 0)))) ;; emma - "(...asked) me to" with T-glottal
	(lex.add.entry 
		'("mei" nil (((m ei) 1)))) ;; emma - disfluency, (make)
	(lex.add.entry
   		'("mih" nil (((m @) 0)))) ;; jane disfluency, emma (minute said fast in "wait a minute")
	(lex.add.entry
   		'("mihm" nil (((m @ m) 0))))	;; disfluency
	(lex.add.entry
   		'("Millerson" nnp (((m i l) 0) ((er r s n!) 0))))
	(lex.add.entry 
		'("modies" nn (((m oo) 1) ((d ii z) 0)))) ;; emma (modern studies)
	(lex.add.entry 
		'("molestering" vbg (((m @) 0) ((l e s t) 1) ((@r t^) 0) ((i n) 0)))) ;; emma - molesting
	(lex.add.entry 
		'("Mosera" nnp (((m oo z) 0) ((ir t^) 1) ((@) 0))))
	(lex.add.entry
   		'("musta" md|vbp (((m uh s t) 1) ((@) 0)))) ;; variant of must've
	(lex.add.entry
   		'("my" prp$ (((m ei) 1))))
	(lex.add.entry
   		'("n'" cc (((@ n) 0))))		
	(lex.add.entry
   		'("nae" rb (((n ei) 1))))
	(lex.add.entry
   		'("naebody" nn (((n ei) 1) ((b @) 0) ((d ii) 0))))
	(lex.add.entry
   		'("naebody's" nn|vbz (((n ei) 1) ((b @) 0) ((d ii z) 0))))
	(lex.add.entry
   		'("naewhere" rb (((n ei) 1) ((hw eir r) 3))))
	(lex.add.entry
   		'("na" nil (((n @) 0)))) ;;  'n' I ("and I" compressed at start of sentence)(jane)
	(lex.add.entry
   		'("nah" uh (((n @) 0))))
	(lex.add.entry
   		'("naah" uh (((n aa) 0)))) ;; jane, emma
	(lex.add.entry
   		'("naw" rb (((n oo) 1))))
      (lex.add.entry
   		'("naw" uh (((n oo) 1))))
	(lex.add.entry 
		'("nea" nil (((n ii) 1)))) ;; emma - disfluency (need)
	(lex.add.entry
   		'("ned" nn (((n e d) 1))))
	(lex.add.entry
   		'("neds" nns (((n e d z) 1))))
	(lex.add.entry 
		'("neen" nil (((n ii n) 0)))) ;; emma - "not even"
	(lex.add.entry 
		'("Nicka" nnp (((n i k) 1) ((@) 0))))  ;; emma - Nicola
	(lex.add.entry 
		'("nicolaz" nnp (((n i) 1) ((k @) 0) ((l a z) 0)))) ;; emma - nicola+disfluency 
	(lex.add.entry
   		'("nih" nil (((n @) 0))))
	(lex.add.entry 
		'("nikah" nil (((n i) 1) ((k @) 0)))) ;; emma - nic(ol)a
     (lex.add.entry
   		'("nnnn" nil (((n) 0)))) ;; disfluency (emma)
	(lex.add.entry
   		'("noo" jj (((n uuu) 1))))
	(lex.add.entry
   		'("noo" nnp (((n uuu) 1))))
	(lex.add.entry
   		'("noo" rb (((n uuu) 1))))
	(lex.add.entry 
		'("nughin" nn (((n uh) 1) ((i n) 0)))) ;; emma - nothing
	(lex.add.entry
   		'("nuhv" nil (((n @ v) 0)))) ;; "and I've"
    	(lex.add.entry
   		'("num" nil (((n @ m) 1)))) ;; emma (n' I'm)
	(lex.add.entry 
		'("numties" nns (((n uh m) 1) ((t ii z) 0)))) ;; emma
	(lex.add.entry 
		'("nuttin" nn (((n uh) 1) ((? i n) 0)))) ;; emma - variant of "nothing"
	(lex.add.entry
   		'("o'" in (((@) 0)))) ;; of
	(lex.add.entry
   		'("och" uh (((o x) 1))))
	;;(lex.add.entry
   		;;'("o'er" in (((ou @r r) 1))))
        (lex.add.entry
   		'("of" (in full) (((uh v) 1))))    		
    	 (lex.add.entry
    		'("of" (in reduced) (((@ v) 0))))
	(lex.add.entry 
		'("oli" jj (((ou) 1) ((l ii) 0)))) ;; emma - variant of "only"
	(lex.add.entry 
		'("oli" nn (((ou) 1) ((l ii) 0)))) ;; emma - variant of "only"
	(lex.add.entry 
		'("oli" rb (((ou) 1) ((l ii) 0)))) ;; emma - variant of "only"
	(lex.add.entry 
		'("oo" uh (((uuu) 0))))
      (lex.add.entry
    		'("oor" nn (((uu ur) 1)))) ;; hour
    	(lex.add.entry
    		'("oor" prp$ (((uu ur) 1))))  ;; our 
      	(lex.add.entry
    		'("oors" nns (((uu ur z) 1)))) ;; hours
      	(lex.add.entry
    		'("oors" prp (((uu ur z) 1)))) ;; ours
	(lex.add.entry
   		'("oot" in (((uu ?) 1))))
	(lex.add.entry
   		'("oot" jj (((uu ?) 1))))
	(lex.add.entry
   		'("oot" rp (((uu ?) 1))))
	(lex.add.entry
   		'("ootside" (in contrast-with-inside) (((uu ?) 1) ((s ai d) 3))))
	(lex.add.entry
   		'("ootside" (in non-contrastive-usage) (((uu ?) 3) ((s ai d) 1))))
	(lex.add.entry
   		'("ootside" (jj contrast-with-inside) (((uu ?) 1) ((s ai d) 3))))
	(lex.add.entry
   		'("ootside" (jj non-contrastive-usage) (((uu ?) 3) ((s ai d) 1))))
	(lex.add.entry
   		'("ootside" (nn contrast-with-inside) (((uu ?) 1) ((s ai d) 3))))
	(lex.add.entry
   		'("ootside" (nn non-contrastive-usage) (((uu ?) 3) ((s ai d) 1))))
	(lex.add.entry
   		'("ootside" (rb contrast-with-inside) (((uu ?) 1) ((s ai d) 3))))
	(lex.add.entry
   		'("ootside" (rb non-contrastive-usage) (((uu ?) 3) ((s ai d) 1))))
	(lex.add.entry
   		'("ot" nil (((o ?) 0)))) ;; disfluency (jane)
	(lex.add.entry
   		'("papped" jj (((p a p t) 1))))
	(lex.add.entry
   		'("papped" vbd (((p a p t) 1))))
	(lex.add.entry
   		'("papped" vbn (((p a p t) 1))))
	(lex.add.entry 
		'("phota" nn (((f ou) 1) ((? @) 0)))) ;; emma - photo
	(lex.add.entry
   		'("pih" nil (((p i) 0))))
	(lex.add.entry
   		'("Plenderleys" nnps (((p l e n d) 1) ((er r) 0) ((l ii z) 0))))
	(lex.add.entry 
		'("prah" nil (((p r @) 1)))) ;; emma - disfluency
	(lex.add.entry
   		'("puh" nil (((p @) 0)))) ;; disfluency john, jane 
	(lex.add.entry
   		'("puhs" nil (((p @ s) 0)))) ;; disfluency jane  
	(lex.add.entry
   		'("pullt" nil (((p uh l t) 0)))) ;; variant of pulled
	(lex.add.entry
   		'("ra" (dt full) (((t^ uh) 1)))) ;; Glaswegian ra for "the"
	(lex.add.entry
   		'("ra" (dt reduced) (((t^ @) 0))))	;; Glaswegian ra for "the"
	(lex.add.entry
   		'("ragirra" nn (((t^ @) 0) ((g e) 1) ((t^ @r r) 0))))  ;; a variant of together
	(lex.add.entry
   		'("ragirra" rb (((t^ @) 0) ((g e) 1) ((t^ @r r) 0)))) ;; a variant of together			
	(lex.add.entry
   		'("rah" nil (((t^ @) 0))))
	(lex.add.entry
   		'("really" rb (((t^ i @ l) 1) ((ii) 0))))	
	(lex.add.entry
   		'("retard" nil (((t^ ii) 1) ((t ar r d) 0)))) ;; emma - need nil tag as build_utts insists on vrb pron with i instead of nn with ii
	(lex.add.entry
   		'("rewind" nil (((t^ ii) 3) ((w ai n d) 1)))) ;; need nil tag or build_utts insists on wind=air pron
      (lex.add.entry 
 		'("ri" nil (((t^ ii) 1)))) ;; emma - disfluency 
	(lex.add.entry 
		'("righty" nil (((t^ ai ?) 1) ((ii) 0)))) ;; emma
	(lex.add.entry
   		'("rih" nil (((t^ i) 0)))) ;; disfluency
	(lex.add.entry
   		'("rilly" rb (((t^ i l) 1) ((ii) 0)))) ;; variant of really		
	(lex.add.entry
   		'("rimah" nil (((t^ i) 0) ((m @) 0))))  ;; disfluency 
	(lex.add.entry
   		'("rirra" nil (((t^ i t^) 1) ((@) 0))))  ;; variant for this speaker of wi ra (with the)	
	(lex.add.entry
   		'("rirrer" nil (((t^ i t^) 1) ((er) 0))))  ;; variant for this speaker of wi ra (with the)	
	(lex.add.entry
   		'("roond" jj (((t^ uu n d) 1))))
	(lex.add.entry
   		'("roond" nn (((t^ uu n d) 1))))
	(lex.add.entry
   		'("ruby's" nnp|pos (((t^ uu) 1) ((b ii z) 0))))
	(lex.add.entry
   		'("ruby's" nnp|vbz (((t^ uu) 1) ((b ii z) 0))))
	(lex.add.entry
   		'("ruh" nil (((t^ @) 0))))
	(lex.add.entry
   		'("Rulligan" nnp (((t^ uh l) 1) ((i g) 0) ((@ n) 0))))
	(lex.add.entry 
		'("Sa" nil (((s @) 0)))) ;; emma disfluency or sentence start "it's a"
	(lex.add.entry
   		'("said" vbd (((s ei d) 1))))
	(lex.add.entry
   		'("said" vbn (((s ei d) 1))))
	(lex.add.entry
   		'("sake" nil (((s ei k) 1))))	;; using nil tag because build_utts wants to put (((s a) 1) ((k ei) 0))) drink
	(lex.add.entry
   		'("says" vbz (((s ei z) 1))))
	(lex.add.entry
   		'("scunnered" jj (((s k uh n) 1) ((@r r d) 0))))
	(lex.add.entry
   		'("scunnered" vbd (((s k uh n) 1) ((@r r d) 0))))
	(lex.add.entry
   		'("scunnered" vbn (((s k uh n) 1) ((@r r d) 0))))
	(lex.add.entry
   		'("scuse" vb (((s k y uuu z) 1))))
	(lex.add.entry
   		'("seither" nil (((s ae) 1) ((dh @r r) 0)))) ;; ("it's either" at sentence start)
	(lex.add.entry
   		'("selotape" nn (((s e l) 1) ((@) 0) ((t ei p) 0))))
	(lex.add.entry
   		'("Seenan" nnp (((s ii n) 0) ((@ n) 0))))
	(lex.add.entry
   		'("Seenans" nnp (((s ii n) 0) ((@ n z) 0))))
      	(lex.add.entry
   		'("separate" vb (((s e) 1) ((p @r) 0) ((t^ ei ?) 0)))) ;; nil tag was used as build_utts was insisting on adjective form t^ @ but for this speaker this will do for both
	(lex.add.entry
   		'("separate" vbp (((s e) 1) ((p @r) 0) ((t^ ei ?) 0))))
	(lex.add.entry
   		'("separate" jj (((s e) 1) ((p @r) 0) ((t^ ei ?) 0))))
	(lex.add.entry
   		'("sh" prp (((sh) 1)))) ;; she
	(lex.add.entry
   		'("she's" (prp|vbz full) (((sh iii z) 1))))
	(lex.add.entry
   		'("shez" prp|vbz (((sh e z) 1)))) ;; "she says" (jane)
	(lex.add.entry 
		'("shite" jj (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" nn (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" uh (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" vb (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" vbd (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" vbn (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" vbp (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" nn (((sh ai ?) 1))))
	(lex.add.entry 
		'("shite" uh (((sh ai ?) 1))))
	(lex.add.entry 
		'("shiteheid" nn (((sh ai ?) 1) ((h ii d) 3))))
	(lex.add.entry 
		'("shiteheids" nns (((sh ai ?) 1) ((h ii d z) 3))))
	(lex.add.entry 
		'("shitehoose" nn (((sh ai ?) 1) ((h uu s) 3))))
	(lex.add.entry 
		'("shitehooses" nns (((sh ai ?) 1) ((h uu s) 2) ((i z) 0))))
	(lex.add.entry 
		'("shites" nns (((sh ai ? s) 1))))
	(lex.add.entry 
		'("shites" vbz (((sh ai ? s) 1))))
	(lex.add.entry 
		'("shitiest" jjs (((sh ai ?) 1) ((ii) 0) ((i s t) 0))))
	(lex.add.entry 
		'("shiting" jj (((sh ai ?) 1) ((n!) 0))))
	(lex.add.entry 
		'("shiting" nn (((sh ai ?) 1) ((n!) 0))))
	(lex.add.entry 
		'("shiting" vbg (((sh ai ?) 1) ((n!) 0))))
	(lex.add.entry
   		'("shouldnae" md|rb (((sh uu d) 1) ((n ii) 0)))) 
	(lex.add.entry
   		'("shuh" nil (((sh @) 1)))) ;; disfluency, sometimes she
	(lex.add.entry
   		'("sho" rb (((sh ou) 1))))
	(lex.add.entry 
		'("shu" nil (((sh uu) 1)))) ;; emma - disfluency
	(lex.add.entry
   		'("sih" nil (((s i) 0))))
	(lex.add.entry
   		'("sihs" nil (((s i s) 1)))) ;; disfluency
	(lex.add.entry 
		'("Snackerjack" nnp (((s n a k) 2) ((@r r) 0) ((jh a k) 1))))
	(lex.add.entry
   		'("sohnny" jj (((s oo) 1) ((n ii) 0)))) ;; john talks of "the sohnny (?) pawn"
	(lex.add.entry
   		'("somebody's" nn|pos (((s uh m) 1) ((b @) 0) ((d ii z) 0))))
	(lex.add.entry
   		'("somebody's" nn|vbz (((s uh m) 1) ((b @) 0) ((d ii z) 0))))
	(lex.add.entry
   		'("somehing" nn (((s uh m) 1) ((h i n) 0)))) ;; emma, jane - variant of something
      (lex.add.entry 
		'("somehmm" nn (((s uh m) 1) ((m) 0)))) ;; emma - another variant of something
	(lex.add.entry 
		'("someye" nil (((s uh m) 1) ((ae) 0)))) ;; emma - disfluency, something
	(lex.add.entry
   		'("son's" nn|pos (((s uh n z) 1))))
	(lex.add.entry
   		'("son's" nn|vbz (((s uh n z) 1))))
	(lex.add.entry
   		'("squad" nn (((s k w a d) 1))))
	(lex.add.entry
   		'("sreally" nil (((s r i) 1) ((l ii) 0)))) ;; it's really (jane)
	(lex.add.entry
   		'("ssss" nil (((s) 0)))) ;; disfluency (jane)
	(lex.add.entry
   		'("staun" vb (((s t oo n) 1)))) ;; stand
	(lex.add.entry
   		'("staun" vbp (((s t oo n) 1)))) ;; stand
	(lex.add.entry
   		'("stauning" vbg (((s t oo n) 1) ((i n) 0))))
      	;;(lex.add.entry
   	;;	'("stay" vb (((s t ai) 1))))
      	;;(lex.add.entry
   	;;	'("stay" vbp (((s t ai) 1))))
      	(lex.add.entry
   		'("stayed" vbd (((s t ai d) 1))))
      	(lex.add.entry
   		'("stayed" vbn (((s t ai d) 1))))
	(lex.add.entry
   		'("stewart" nnp (((s t uuu @r r ?) 1))))
	(lex.add.entry 
		'("sti" nil (((s t ii) 1)))) ;; emma - variant of still
	(lex.add.entry
   		'("stih" nil (((s t @) 0)))) ;; a disfluency
	(lex.add.entry
   		'("stotted" vbg (((s t oo ?) 1) ((i d) 0))))
	(lex.add.entry
   		'("stotting" vbg (((s t oo ?) 1) ((i n) 0))))
	(lex.add.entry
   		'("Strathdewe" nnp (((s t r a th) 1) ((jh uu) 2))))
	(lex.add.entry
   		'("Strathdewie" nnp (((s t r a th) 1) ((jh uu) 2) ((ii) 0))))
	(lex.add.entry
   		'("striped" jj (((s t r i) 1) ((p i ?) 0))))
	(lex.add.entry
   		'("stupid" jj (((s ch uu) 1) ((p i d) 0))))
        (lex.add.entry
   		'("stupid" nn (((s ch uu) 1) ((p i d) 0))))
        (lex.add.entry
   		'("stupider" jjr (((s ch uu) 1) ((p i d) 0) ((@r r) 0))))
        (lex.add.entry
   		'("stupidest" jjs (((s ch uu) 1) ((p i d) 0) ((i s t) 0))))
        (lex.add.entry
   		'("stupidities" nns (((s ch uu) 0) ((p i d) 1) ((@) 0) ((? ii z) 0))))
        (lex.add.entry
   		'("stupidity" nn (((s ch uu) 0) ((p i d) 1) ((@) 0) ((? ii) 0))))
        (lex.add.entry
   		'("stupidly" rb (((s ch uu) 1) ((p i d) 0) ((l ii) 0))))
        (lex.add.entry
   		'("stupidness" nn (((s ch uu) 1) ((p i d) 0) ((n @ s) 0))))
        (lex.add.entry
   		'("stupid's" nn|pos (((s ch uu) 1) ((p i d z) 0))))
        (lex.add.entry
   		'("stupid's" nn|vbz (((s ch uu) 1) ((p i d z) 0))))	
        (lex.add.entry
   		'("suh" nil (((s @) 0)))) ;; disfluency; short "so"
	(lex.add.entry 
		'("suhma" nn (((s uh) 1) ((m @) 0)))) ;; emma - another variant of something
	(lex.add.entry 
		'("suhmat" nn (((s uh m) 0) ((a ?) 0)))) ;; emma - another variant of something
	(lex.add.entry
   		'("suade" nil (((s w ei d) 1)))) ;; disfluency (jane) splitting persuade
	(lex.add.entry
   		'("sumbdy" nn (((s uh m) 1) ((d ii) 0)))) ;; somebody
	(lex.add.entry
   		'("sumbdy'll" nn|md (((s uh m) 1) ((d ii @ l) 0))))
	(lex.add.entry
   		'("sumbdy's" nn|pos (((s uh m) 1) ((d ii z) 0))))
	(lex.add.entry
   		'("sumbdy's" nn|vbz (((s uh m) 1) ((d ii z) 0))))
	(lex.add.entry
   		'("sumdy" nn (((s @ m) 1) ((d ii) 0)))) ;; emma - another variant of somebody
	(lex.add.entry 
		'("sumhin" nn (((s uh m) 1) ((i n) 0)))) ;; emma - another variant of something
	(lex.add.entry
   		'("susie's" nnp|pos (((s uu) 1) ((z ii z) 0))))
	(lex.add.entry
   		'("suspended" jj (((s @) 0) ((s p e n d) 1) ((ii d) 0))))
	(lex.add.entry
   		'("suspended" vbd (((s @) 0) ((s p e n d) 1) ((ii d) 0))))
	(lex.add.entry
   		'("suspended" vbn (((s @) 0) ((s p e n d) 1) ((ii d) 0))))
	(lex.add.entry 
		'("suttin" nn (((s uh) 1) ((? i n) 0)))) ;; emma - variant of "something" with glottal
	(lex.add.entry
   		'("swally" nn (((s w a) 1) ((l ii) 0))))
	(lex.add.entry 
		'("sweared" vbd (((s w eir r d) 1)))) ;; emma
	(lex.add.entry 
		'("sweared" vbn (((s w eir r d) 1)))) ;; emma
	(lex.add.entry 
		'("swumming" nn (((s w uh m) 1) ((i n) 0)))) ;; emma - swimming
	(lex.add.entry 
		'("swumming" vbg (((s w uh m) 1) ((i n) 0)))) ;; emma - swimming
	(lex.add.entry
   		'("tae" nil (((t ei) 1)))) ;; need nil tag as build_utts insisting on tae nnp t ae
	;;(lex.add.entry
   	;;	'("tae" (in full) (((t e) 0))))
	;;(lex.add.entry
   	;;	'("tae" (in full) (((t ei) 1))))
	;;(lex.add.entry
   	;;	'("tae" (in reduced) (((t @) 0))))
	;;(lex.add.entry
   	;;	'("tae" (to full) (((t e) 0))))
	;;(lex.add.entry
   	;;	'("tae" (to full) (((t ei) 1))))
	;;(lex.add.entry
   	;;	'("tae" (to reduced) (((t @) 0))))
	(lex.add.entry
   		'("tay" nil (((t ei) 1))))	;; disfluency (jane)
	(lex.add.entry 
		'("teeh" nil (((t ii) 1)))) ;; emma - disfluency
	(lex.add.entry
   		'("telt" vbd (((t e l ?) 1)))) ;; told
	(lex.add.entry
   		'("telt" vbn (((t e l ?) 1))))  ;; told
	(lex.add.entry
   		'("teuchter" nn (((ch uu x) 1) ((t @r r) 0)))) ;; contemptuous word for Highlander but used by Glaswegians for anyone from outside Glasgow as jane does for Edinburgh
	(lex.add.entry 
		'("tha" nil (((dh @) 1)))) ;; emma - disfluency (that)
	(lex.add.entry
   		'("the" (dt full) (((dh uh) 1))))
	(lex.add.entry
   		'("the" (dt reduced) (((dh @) 0))))
	(lex.add.entry
   		'("thah" nil (((th @) 0))))
	(lex.add.entry
   		'("that's" (in|vbz full) (((dh a ? s) 1))))
	(lex.add.entry
   		'("that's" (in|vbz reduced) (((dh @ ? s) 0))))
	(lex.add.entry
   		'("the" (dt full) (((dh uh) 1))))
	(lex.add.entry
   		'("the" (dt reduced) (((dh @) 0))))
	(lex.add.entry
   		'("theh" nil (((dh e) 0))))
	(lex.add.entry
   		'("them" (prp full) (((dh ei m) 1)))) ;; diff from lex for full
	(lex.add.entry
   		'("them" (prp full) (((dh e m) 1)))) ;; also occurs
	(lex.add.entry
   		'("them" (prp reduced) (((dh @ m) 0)))) ;; same as lex for reduced
	(lex.add.entry
   		'("themsels" nns (((dh e m) 3) ((s e l z) 1)))) ;; emma
	(lex.add.entry
   		'("themsels" prp (((dh e m) 3) ((s e l z) 1)))) ;; emma

	(lex.add.entry
   		'("thenan" nil (((dh e n) 1) ((@ n) 0)))) ;; one instance with jane: then + disfluency
	(lex.add.entry
   		'("there's" ex|vbz (((dh eir r z) 1))))
	(lex.add.entry
   		'("theym" prp (((dh ei m) 1)))) ;; variant of them, needed to deal with build_utts insisting on @
	(lex.add.entry
   		'("they're" prp|vbp (((dh eir r) 1))))
	(lex.add.entry
   		'("they've" prp|vbp (((dh ei v) 1))))
	(lex.add.entry
   		'("thih" nil (((th ) 0))))
	(lex.add.entry
   		'("thingmy" nn (((th i ng) 1) ((m ii) 0))))
      (lex.add.entry
   		'("thirteen" cd (((th eir r) 0) ((t ii n) 1))))
	(lex.add.entry
   		'("thirteen" ls (((th eir r) 0) ((t ii n) 1))))
	(lex.add.entry
   		'("thirteen" nn (((th eir r) 0) ((t ii n) 1))))
	(lex.add.entry
   		'("to" (in full) (((t uh) 0))))
	(lex.add.entry
   		'("to" (in full) (((t ei) 1))))
	(lex.add.entry
   		'("to" (in reduced) (((t @) 0))))
	(lex.add.entry
   		'("to" (to full) (((t uh) 0))))
	(lex.add.entry
   		'("to" (to full) (((t ei) 1))))
	(lex.add.entry
   		'("to" (to reduced) (((t @) 0))))	
	(lex.add.entry 
		'("trat" vbd (((t r a ?) 1)))) ;; emma - tried
	(lex.add.entry 
		'("trat" vbn (((t r a ?) 1)))) ;; emma - tried
	(lex.add.entry
   		'("troosers" nn (((t r uu) 1) ((z @r r z) 0))))
	(lex.add.entry
   		'("tuhv" nil (((t uh v) 1)))) ;; short form of "to have" in "used to have"
      (lex.add.entry
   		'("uch" uh (((uh x) 1))))
	(lex.add.entry 
		'("ucking" nil (((uh k) 1) ((i n) 0)))) ;; emma - "weef, ucking hing" for "wee fucking hing"
	(lex.add.entry
   		'("uhf" nil (((@ f) 0)))) ;; another variant of "of", included seperately to over-ride build_utts problem
	(lex.add.entry 
		'("uhn" nil (((@ n) 0)))) ;; emma disfluency
	(lex.add.entry 
		'("uht" nil (((@ ?) 0)))) ;; emma disfluency
        (lex.add.entry
   		'("uhv" prp|vbp (((uh v) 1)))) ;; I've
	(lex.add.entry
   		'("us" prp (((uh z) 1))))
	(lex.add.entry
   		'("use" nil (((y uuu z) 1)))) ;; need nil tag when building voice as build_utts insisting on nn pron uu s
	(lex.add.entry 
		'("Va" nil (((v @) 0)))) ;; emma - disfluency
	(lex.add.entry
   		'("wa" nil (((w @) 0)))) ;; disfluency; short we; also v. compressed "well I" (jane)
	(lex.add.entry 
		'("Waddell" nil (((w oo) 1) ((d l!) 0))))
	(lex.add.entry 
		'("wahan" nil (((w a) 1) ((@ n) 0)))) ;; emma - disfluency (one)
	(lex.add.entry 
		'("wasn" vbd|rb (((w @ z) 1) ((n!) 0)))) ;; emma - wasn('t)
	(lex.add.entry 
		'("wat" wdt (((w a ?) 0)))) ;; emma - what
	(lex.add.entry 
		'("wat" wp (((w a ?) 0)))) ;; emma - what
	(lex.add.entry 
		'("wat" vb (((w a ?) 0)))) ;; emma - want
	(lex.add.entry 
		'("wat" vbp (((w a ?) 0)))) ;; emma - want
	(lex.add.entry 
		'("waw" nn (((w oo) 0)))) ;; emma - variant of war
	(lex.add.entry
   		'("wean" nn (((w ei n) 1))))	;; child
	(lex.add.entry
   		'("weans" nns (((w ei n z) 1)))) ;; children			
	(lex.add.entry
   		'("wan" cd (((w a n) 1))))
	(lex.add.entry
   		'("wan" nn (((w a n) 1))))
	(lex.add.entry
   		'("wan" prp (((w a n) 1))))
	(lex.add.entry
   		'("wan" vb (((w a n) 1)))) ;; emma - want
	(lex.add.entry
   		'("wan" vbp (((w a n) 1)))) ;; emma - want
      (lex.add.entry
   		'("wance" nn (((w a n s) 1)))) ;; once
      	(lex.add.entry
   		'("wance" rb (((w a n s) 1)))) ;; once
      	(lex.add.entry
   		'("wans" nns (((w a n z) 1))))
	(lex.add.entry
   		'("want" nn (((w a n ?) 1))))
	(lex.add.entry
   		'("want" vb (((w a n ?) 1))))
	(lex.add.entry
   		'("want" vbp (((w a n ?) 1))))
	(lex.add.entry
   		'("wanted" vbd (((w a n ?) 1) ((i d) 0))))
	(lex.add.entry
   		'("wanted" vbn (((w a n ?) 1) ((i d) 0))))
	(lex.add.entry
   		'("wanting" vbg (((w a n ?) 1) ((i n) 0))))
	(lex.add.entry
   		'("was" (vbd full) (((w uh z) 1))))	
      	(lex.add.entry
   		'("washing" nn (((w a sh) 1) ((i n) 0))))  ;; jane and john
      	(lex.add.entry
   		'("washing" vbg (((w a sh) 1) ((i n) 0)))) ;; jane and john
	(lex.add.entry
   		'("wasnae" vbd|rb (((w uh z) 1) ((n ii) 0))))  ;; use uh for jane and i for john
	;; (lex.add.entry
   	;;	'("wasnae" vbd|rb (((w i s) 1) ((n ii) 0))))  ;; use uh for jane and i for john
      	(lex.add.entry
   		'("water" nn (((w a) 1) ((? @r r) 0)))) ;; jane
        (lex.add.entry
   		'("weather's" nn|vbz (((w e) 1) ((dh @r r z) 0))))
	(lex.add.entry 
		'("wedgied" nil (((w e jh) 1) ((ii d) 0)))) ;; emma - ?
	(lex.add.entry 
		'("weef" nil (((w ii f) 1)))) ;; emma - wee + disfluency (weef, ucking hing) 
	(lex.add.entry
   		'("weeve" nil (((w iii v) 1)))) ;; one instance with jane: wee + disfluency
	(lex.add.entry
   		'("we'd" prp|md (((w iii d) 1)))) 
	(lex.add.entry
   		'("we'll" prp|md (((w iii l) 1))))
	(lex.add.entry
   		'("we're" prp|vbp (((w ir r) 1))))
	(lex.add.entry
   		'("wernae" vbd|rb (((w er r) 1) ((n ii) 0))))
	(lex.add.entry
   		'("wers" (vbd full) (((w er r z) 1))))
	(lex.add.entry
   		'("wers" (vbd reduced) (((w @r r z) 0))))
	(lex.add.entry
   		'("we've" prp|vbp (((w iii v) 1))))
	(lex.add.entry
   		'("what's" wp|vbz (((hw oo ? s) 1))))
	(lex.add.entry
   		'("whe" nil (((w @) 0))))
	(lex.add.entry
   		'("where's" wrb|vbz (((hw eir r z) 1))))
	(lex.add.entry
   		'("Whitelock" nnp (((hw ai ?) 1) ((l oo k) 0))))
	(lex.add.entry 
		'("whuhl" nil (((hw uh l) 1)))) ;; emma - while
	(lex.add.entry 
		'("whut" nil (((hw uh ?) 1)))) ;; emma - variant of what
	(lex.add.entry
   		'("wi" in (((w i) 1)))) ;;  "with"
	(lex.add.entry 
		'("wi'" nil (((w i) 1))))  ;; with
	(lex.add.entry
   		'("wideo" nn (((w ai) 1) ((d ou) 0))))
	(lex.add.entry
   		'("wideos" nns (((w ai) 1) ((d ou z) 0))))
	(lex.add.entry
   		'("will" (md full) (((w uh l) 1))))
	(lex.add.entry
   		'("will" (md reduced) (((w @ l) 1))))
	(lex.add.entry
   		'("will" (vb full) (((w uh l) 1))))
	(lex.add.entry
   		'("will" (vb reduced) (((w @ l) 1))))
	(lex.add.entry
   		'("will" (vbp full) (((w uh l) 1))))
	(lex.add.entry
   		'("Williams" nnp (((w uh l) 1) ((y @ m z) 0))))
	(lex.add.entry
   		'("Willie'll" nnp|md (((w uh l) 1) ((ii) 0) ((@ l!) 0))))
	(lex.add.entry
   		'("willnae" md|rb (((w uh l) 1) ((n ii) 0))))
	(lex.add.entry
   		'("wind" nil (((w ai n d) 1)))) ;; emma - need nil tag when building voice as build_utts insisting on wind (air) pron.
	(lex.add.entry
   		'("windae" nn (((w i n) 1) ((d ei) 0))))
      (lex.add.entry
   		'("windaes" nns (((w i n) 1) ((d ii z) 0))))
	(lex.add.entry
   		'("wir" nil (((w irr r) 0))))
	(lex.add.entry
   		'("wirra" nil (((w i t^) 1) ((@) 0))))  ;; with the (wi ra)
	(lex.add.entry
   		'("wirrah" nil (((w i t^) 1) ((@) 0))))  ;; with a
	(lex.add.entry
   		'("wirrat" nil (((w i t^) 0) ((a ?) 1))))  ;; with that	
	(lex.add.entry
   		'("wirrem" in|pp (((w i t^) 1) ((@ m) 0))))  ;; with them
	(lex.add.entry
   		'("wirrus" in|pp (((w i t^) 1) ((@ z) 0))))  ;; with us		
	(lex.add.entry
   		'("withoot" in (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("withoot" nn (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("withoot" rb (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("wizza" in|dt (((w i z) 0) ((@) 0))))  ;; with the 
	(lex.add.entry
   		'("woman" nn (((w uh) 1) ((m i n) 0))))
	(lex.add.entry
   		'("women" nns (((w uh) 1) ((m @ n) 0))))
	(lex.add.entry
   		'("wos" (vbd full) (((w oo z) 1))))	;; variant pron to jane's usual w uh z
	(lex.add.entry
   		'("wouldnae" md|rb (((w uu d) 1) ((n ii) 0))))
	(lex.add.entry 
		'("wounae" nil (((w uu) 1) ((n ii) 0)))) ;; emma - variant of wouldnae
	(lex.add.entry 
		'("wound" nil (((w ow n d) 1)))) ;; need nil tag when building voice as build_utts insists on nn (w uu n d).
	(lex.add.entry 
		'("wrut" vbd (((t^ @ ?) 1)))) ;; emma - variant of wrote
	(lex.add.entry
   		'("wuh" nil (((w @) 0)))) ;; disfluency (jane, john)
	(lex.add.entry
   		'("wuhnae" vbd|rb (((w uh) 1) ((n ii) 0))))  ;; emma disfluency, wasnae
	(lex.add.entry 
		'("wuts" vbz (((w uh ? s) 1)))) ;; emma - wants
	(lex.add.entry
   		'("ya" nil (((y @) 1)))) ;; disfluency and short form yeah (jane)
	(lex.add.entry 
		'("yan" nil (((y @ n) 1)))) ;; emma - disfluency (and)
	(lex.add.entry
   		'("yat" nil (((y a ?) 1)))) ;; emma - disfluency (that)
	(lex.add.entry 
		'("yel" nil (((y e l) 1)))) ;; emma - disfluency (well)
	(lex.add.entry
   		'("yin" nns (((y i n) 1))))
	(lex.add.entry
   		'("yins" nns (((y i n z) 1))))
	(lex.add.entry 
		'("youn" nil (((y @ n) 1)))) ;; emma - you can
	(lex.add.entry
   		'("you're" prp|vbp (((y ur r) 1))))
      (lex.add.entry
   		'("yous" prp (((y uuu z) 1))))
	(lex.add.entry
   		'("youse" prp (((y uuu z) 1))))
	(lex.add.entry
   		'("you've" prp|vbp (((y uuu v) 1))))
	(lex.add.entry 
		'("yuch" nil (((y uh x) 0)))) ;; emma - interjection
	(lex.add.entry
   		'("yursel" nn (((y urr r) 3) ((s e l) 1)))) ;; yourself
	(lex.add.entry
   		'("yursel" prp (((y urr r) 3) ((s e l) 1)))) ;; yourself
	(lex.add.entry 
		'("zat" nil (((z a ?) 0)))) ;; emma "Is that...?"
)


(set! unilex-edi-backoff_rules
'(
(l! l)
(n! n)
(eir e)
(iii ii)
(n @)
(aa @)
(ae @)
(i @)
(irr @)
(iii @)
(ei @)
(er @)
(a @)
(eir @)
(uw @)
(@@r @)
(e @)
(oo @)
(our @)
(ow @)
(o @)
(uh @)
(u @)
(urr @)
(uuu @)
(i@ @)
(ur @)
(owr @r)
(hw w )
(s z)
(_ @)
                                                                               
))

(lex.create "unilex-ediG3")
(lex.set.compile.file (path-append unilexdir "unilex-edi.out"))
(lex.set.phoneset "unilex")
(lex.set.lts.method 'unilex-ediG3_lts_function)
;;(lex.set.pos.map english_pos_map_wp39_to_wp20)
(lex.set.pos.map nil)
(unilex-ediG3_addenda)

(provide 'unilex-ediG3)




