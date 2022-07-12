;;; Unilex scheme definition.

;; EDI version with Gorbals addenda

(defvar unilexdir (path-append lexdir "unilex"))

(require 'pos)
(require 'unilex_phones)

(define (unilex-ediG_lts_function word feats)
  "(unilex-ediG_lts_function word feats)
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
(define (unilex-ediG_addenda)
  "(unilex-ediG_addenda)
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

; Gorbals stuff

	(lex.add.entry
   		'("a" (dt full) (((uh) 1))))
	(lex.add.entry
   		'("a" (dt reduced) (((@) 0))))
        (lex.add.entry
   		'("a" (in full) (((uh) 1)))) ;; Glaswegian a for "of"
    	(lex.add.entry
    		'("a" (in reduced) (((@) 0))))	;; Glaswegian a for "of"	
	(lex.add.entry
   		'("aboot"  in (((@) 0) ((b uu ?) 1))))
	(lex.add.entry
   		'("across" in (((@) 0) ((k r uh s) 1))))
	(lex.add.entry
   		'("aff" in (((a f) 1))))
	(lex.add.entry
   		'("aff" jj (((a f) 1))))
	(lex.add.entry
   		'("aff" nn (((a f) 1))))
	(lex.add.entry
   		'("aff" rp (((a f) 1))))
	(lex.add.entry
   		'("Ahl" nil (((a l) 0)))) ;; disfluency
	(lex.add.entry
   		'("alang" in (((@) 0) ((l a ng) 1))))
	(lex.add.entry
   		'("arrem" in|pp (((uh t^) 1) ((@ m) 0))))  ;; of them
	(lex.add.entry
   		'("ats" (in|vbz full) (((a ? s) 1)))) ;; john: that's
	(lex.add.entry
   		'("ats" (in|vbz reduced) (((@ ? s) 0)))) ;; john: that's
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
	        '("awright" rb (((oo) 0) ((r ai ?) 1)))) ;; alright
	(lex.add.entry
   		'("baw" nn (((b oo) 1))))
	(lex.add.entry
   		'("belong" vb (((b i) 0) ((l a ng) 1))))
	(lex.add.entry
   		'("belong" vbp (((b i) 0) ((l a ng) 1))))
	(lex.add.entry
   		'("brooh" nil (((b r uu) 1)))) ;; a disfluency
	(lex.add.entry
   		'("broon" jj (((b r uuu n) 1))))
	(lex.add.entry
   		'("broon" nn (((b r uuu n) 1))))
	(lex.add.entry
   		'("Broon" nnp (((b r uuu n) 1))))
	(lex.add.entry
   		'("built" vbd (((b @ l ?) 1))))
	(lex.add.entry
   		'("built" vbn (((b @ l ?) 1))))
	(lex.add.entry
   		'("cannae" md|rb (((k a) 1) ((n ii) 0))))
	(lex.add.entry
   		'("Cathie" nnp (((k a th) 1) ((ii) 0))))
	(lex.add.entry
   		'("christ" nnp (((k r ai s ?) 1))))		
	(lex.add.entry
   		'("claes" nn (((k l ei z) 1))))
	(lex.add.entry
   		'("Croon" nnp (((k r uu n) 1))))
	(lex.add.entry
   		'("couldnae" md|rb (((k uu d) 1) ((n ii) 0))))
	(lex.add.entry
   		'("Crownie" nnp (((k r ow n) 0) ((ii) 0))))
	(lex.add.entry
   		'("dae" nil (((d ei) 1))))
	(lex.add.entry
   		'("dah" nil (((d @) 0))))
	(lex.add.entry
   		'("Danny'd" nnp|md (((d a n) 1) ((i d) 0))))
	(lex.add.entry
   		'("Danny'll" nnp|md (((d a n) 1) ((@ l!) 0))))
	(lex.add.entry
   		'("didnae" vbd|rb  (((d i d) 1) ((n ii) 0))))
	(lex.add.entry
   		'("dinnae" vbd|rb  (((d i) 1) ((n ii) 0))))
	(lex.add.entry
   		'("doon" in (((d uu n) 1))))
	(lex.add.entry
   		'("drapped" vbd (((d r a p t) 1)))) ;; dropped
	(lex.add.entry
   		'("drapped" vbn (((d r a p t) 1)))) ;; dropped
	(lex.add.entry
   		'("dunkies" nns (((d uh ng ) 1) ((k ii z) 0))))
	(lex.add.entry
   		'("eerhose" nil (((i@) 0) ((h ou s) 0)))) ;; disfluency
	(lex.add.entry
   		'("efter" in (((e f) 1) ((t @r r) 0))))		;; Glaswegian after
	(lex.add.entry
   		'("errathing" nn (((e t^) 1) ((@) 0) ((th i ng) 2))))
	(lex.add.entry
   		'("ev" nil (((e v) 0)))) ;; disfluency
	(lex.add.entry
   		'("everybody" nn (((e v) 1) ((r i) 0) ((b uh) 0) ((d ii) 0))))
	(lex.add.entry
   		'("everybody's" nn|pos (((e v) 1) ((r i) 0) ((b uh) 0) ((d ii z) 0))))
	(lex.add.entry
   		'("everybody's" nn|vbz (((e v) 1) ((r i) 0) ((b uh) 0) ((d ii z) 0))))
	(lex.add.entry
   		'("fae" (in full) (((f ei) 1))))
	(lex.add.entry
   		'("fae" (in reduced) (((f @) 0))))
	(lex.add.entry
   		'("faither" nn (((f ei) 1) ((dh @r r) 0))))
	(lex.add.entry
   		'("faither" nnp (((f ei) 1) ((dh @r r) 0))))
	(lex.add.entry
   		'("feart" jj (((f irr ?) 1))))
	(lex.add.entry
   		'("fitbaw" nn (((f i ?) 0) ((b oo) 0))))
	(lex.add.entry
   		'("found" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"	
	(lex.add.entry
   		'("found" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"	
	(lex.add.entry
   		'("fulla" jj|in (((f uh) 1) ((l @) 0)))) ;; "full of"				
	(lex.add.entry
   		'("fun" vbd (((f uh n) 1)))) ;; Glaswegian variant of "found"
	(lex.add.entry
   		'("fun" vbn (((f uh n) 1)))) ;; Glaswegian variant of "found"			
	(lex.add.entry
   		'("gae" nn (((g ei) 1))))
	(lex.add.entry
   		'("gae" vb (((g ei) 1))))
	(lex.add.entry
   		'("gaun" vbg (((g oo) 1) ((i n) 0))))
	(lex.add.entry
   		'("Gilmartin" nnp (((g i l) 0) ((m ar r) 1) ((? i n) 0))))
	(lex.add.entry
   		'("goh" nil (((g @) 0))))
	(lex.add.entry
   		'("Hallside" nnp (((h oo l ) 0) ((s ai d) 0))))
	(lex.add.entry
   		'("Hampden" nnp (((h a m) 1) ((d n!) 0))))
	(lex.add.entry
   		'("harmless" jj (((h eir m) 1) ((l @ s) 0))))
	(lex.add.entry
   		'("have" (vb reduced) (((h @) 0))))
	(lex.add.entry
   		'("have" (vbp reduced) (((h @) 0))))
	(lex.add.entry
   		'("heid" nn (((h ii d) 1))))
	(lex.add.entry
   		'("hink" vb (((h i ng k) 1)))) ;; Glaswegian: think
	(lex.add.entry
   		'("hink" vbp (((h i ng k) 1)))) ;; Glaswegian: think
	(lex.add.entry
   		'("hoose" nn (((h uu s) 1))))
	(lex.add.entry
   		'("hooses" nns (((h uu s) 1) ((i z) 0))))
	(lex.add.entry
   		'("how're" wrb|vbp (((h ow @r r) 1))))
	(lex.add.entry
   		'("howtuh" nil (((h ow) 1) ((uu @) 0))))	 ;; variation for this speaker "how to"
	(lex.add.entry
   		'("i" prp (((a) 1))))
	(lex.add.entry
   		'("i'd" prp|md (((a d) 1))))
        (lex.add.entry
   		'("i'd" prp|vbd (((a d) 1))))
        (lex.add.entry
   		'("i'd" prp|vbn (((a d) 1))))
	(lex.add.entry
   		'("ih" nil (((i y) 0))))
	(lex.add.entry
   		'("i'm" prp|vbp (((a m) 1))))
	(lex.add.entry
   		'("ind" nil (((i n t) 0))))
	(lex.add.entry
   		'("intit" vb|rb (((i n ?) 1) ((i ?) 0))))
	(lex.add.entry
   		'("int" vb|rb (((i n ?) 0))))
	(lex.add.entry
   		'("intae" in (((i n) 1) ((t ei) 0))))		
	(lex.add.entry
   		'("into" in (((i n) 1) ((t @) 0))))
	(lex.add.entry
   		'("ive" prp|vbp (((a v) 1))))
	(lex.add.entry
   		'("iz-sell" prp (((i z) 3) ((s e l) 1)))) ;; himself	
	(lex.add.entry
   		'("juck" nil (((jh uh k) 0))))
	(lex.add.entry
   		'("kah" nil (((k @) 0))))
	(lex.add.entry
   		'("kih" nil (((k @) 0))))
	(lex.add.entry
   		'("Kilburney" nnp (((k i l) 0) ((b @@r r) 1) ((n ii) 0))))
	(lex.add.entry
   		'("koh" nil (((k @) 0))))
	(lex.add.entry
   		'("lowis" nnp (((l ou) 1) ((i s) 0)))) ;; actually a mispron for Rose
	(lex.add.entry
   		'("lum" nn (((l uh m) 1))))
	(lex.add.entry
   		'("mair" jjr (((m eir r) 1))))
	(lex.add.entry
   		'("mair" rbr (((m eir r) 1))))
	(lex.add.entry
   		'("married" jj (((m eir) 1) ((t^ ii d) 0))))
        (lex.add.entry
   		'("married" vbd (((m eir) 1) ((t^ ii d) 0))))
        (lex.add.entry
   		'("married" vbn (((m eir) 1) ((t^ ii d) 0))))
	;;(lex.add.entry
   	;;	'("maw" nn (((m oo) 1) ((@) 0))))		;; maw  use m oo as in ediG lexicon 
	(lex.add.entry
   		'("McFaggan" nnp (((m @ k) 0) ((f a jh) 1) ((@ n) 0))))
	(lex.add.entry
   		'("mih" nil (((m @) 0)))) ;; disfluency
	(lex.add.entry
   		'("mihm" nil (((m @ m) 0))))	;; disfluency
	(lex.add.entry
   		'("Millerson" nnp (((m i l) 0) ((er r s n!) 0))))
	(lex.add.entry
   		'("my" prp$ (((m @) 1))))		
	(lex.add.entry
   		'("nae" rb (((n ei) 1))))
	(lex.add.entry
   		'("nah" uh (((n @) 0))))
	(lex.add.entry
   		'("naw" rb (((n oo) 1))))
	(lex.add.entry
   		'("nih" nil (((n @) 0))))
	(lex.add.entry
   		'("naw" uh (((n oo) 1))))
	(lex.add.entry
   		'("noo" jj (((n uuu) 1))))
	(lex.add.entry
   		'("noo" nnp (((n uuu) 1))))
	(lex.add.entry
   		'("noo" rb (((n uuu) 1))))
        (lex.add.entry
   		'("of" (in full) (((uh) 1))))
    	(lex.add.entry
    		'("of" (in reduced) (((@) 0))))
    	(lex.add.entry
    		'("oor" prp$ (((uu ur) 1))))
   	(lex.add.entry
    		'("oors" prp (((uu ur z) 1))))
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
   		'("photos" nns (((f ou) 1) ((? ii z) 0))))
	(lex.add.entry
   		'("pih" nil (((p i) 0))))
	(lex.add.entry
   		'("Plenderleys" nnps (((p l e n d) 1) ((er r) 0) ((l ii z) 0))))
	(lex.add.entry
   		'("puh" nil (((p @) 0))))
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
   		'("rah" nil (((t^ @) 0)))) ;; disfluency
	(lex.add.entry
   		'("rahs" nil (((t^ @ z) 0)))) ;; disfluency
	(lex.add.entry
   		'("really" rb (((t^ i l) 1) ((ii) 0))))	
	(lex.add.entry
   		'("rirra" nil (((t^ i t^) 1) ((@) 0))))  ;; variant for this speaker of wi ra (with the)	
	(lex.add.entry
   		'("rirrer" nil (((t^ i t^) 1) ((er) 0))))  ;; variant for this speaker of wi ra (with the)	
	(lex.add.entry
   		'("roond" jj (((t^ uu n d) 1))))
	(lex.add.entry
   		'("roond" nn (((t^ uu n d) 1))))
	(lex.add.entry
   		'("ruh" nil (((t^ @) 0))))
	(lex.add.entry
   		'("Rulligan" nnp (((t^ uh l) 1) ((i g) 0) ((@ n) 0))))
	(lex.add.entry
   		'("selotape" nn (((s e l) 1) ((@) 0) ((t ei p) 0))))
	(lex.add.entry
   		'("Seenan" nnp (((s ii n) 0) ((@ n) 0))))
	(lex.add.entry
   		'("Seenans" nnp (((s ii n) 0) ((@ n z) 0))))
	(lex.add.entry
   		'("sho" rb (((sh ou) 1))))
	(lex.add.entry
   		'("sh" prp (((sh) 0))))	 ;; in "she says" john says "sh says"
	(lex.add.entry
   		'("she'd"   prp|md (((sh iii d) 1)))) 
	(lex.add.entry
   		'("she'd"   prp|vbd (((sh iii d) 1)))) 
	(lex.add.entry
   		'("she'd"   prp|vbn (((sh iii d) 1)))) 			
	(lex.add.entry
   		'("sih" nil (((s i ?) 0)))) ;; disfluency
	(lex.add.entry
   		'("sohnny" jj (((s oo) 1) ((n ii) 0))))
	(lex.add.entry
   		'("somehing" nn (((s uh m) 1) ((h i n) 0)))) ;; variant of something
	(lex.add.entry
   		'("staun" vb (((s t oo n) 1)))) ;; stand
	(lex.add.entry
   		'("staun" vbp (((s t oo n) 1)))) ;; stand
	(lex.add.entry
   		'("stauning" vbg (((s t oo n) 1) ((i n) 0))))
	(lex.add.entry
   		'("stewart" nnp (((s t uuu @r r ?) 1))))	
	(lex.add.entry
   		'("stih" nil (((s t @) 0)))) ;; a disfluency
	(lex.add.entry
   		'("Strathdewe" nnp (((s t r a th) 1) ((jh uu) 2))))
	(lex.add.entry
   		'("Strathdewie" nnp (((s t r a th) 1) ((jh uu) 2) ((ii) 0))))
	(lex.add.entry
   		'("striped" jj (((s t r i) 1) ((p i ?) 0))))
	(lex.add.entry
   		'("tae" (in full) (((t e) 0))))
	(lex.add.entry
   		'("tae" (in full) (((t ei) 1))))
	(lex.add.entry
   		'("tae" (in reduced) (((t @) 0))))
	(lex.add.entry
   		'("tae" (to full) (((t e) 0))))
	(lex.add.entry
   		'("tae" (to full) (((t ei) 1))))
	(lex.add.entry
   		'("tae" (to reduced) (((t @) 0))))			
	(lex.add.entry
   		'("the" (dt full) (((dh uh) 1))))
	(lex.add.entry
   		'("the" (dt reduced) (((dh @) 0))))
	(lex.add.entry
   		'("thah" nil (((th @) 0))))
	(lex.add.entry
   		'("theh" nil (((dh @@r) 0))))
	(lex.add.entry
   		'("them" (prp full) (((dh ei m) 1)))) ;; diff from lex for full
	;; (lex.add.entry
   	;;	'("them" (prp reduced) (((dh @ m) 0)))) 
	;; (lex.add.entry
   	;;	'("theym" prp (((dh ei m) 1)))) ;; variant of them  
	(lex.add.entry
   		'("thih" nil (((th ) 0))))
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
   		'("troosers" nn (((t r uu) 1) ((z @r r z) 0))))
	(lex.add.entry
   		'("us" prp (((uh z) 1))))	
	(lex.add.entry
   		'("wa" nil (((w @) 0)))) ;; disfluency
	(lex.add.entry
   		'("wean" nn (((w ei n) 1))))	;; child
	(lex.add.entry
   		'("weans" nns (((w ei n z) 1))))	;; children			
	(lex.add.entry
   		'("wan" cd (((w a n) 1))))
	(lex.add.entry
   		'("wan" nn (((w a n) 1))))
	(lex.add.entry
   		'("wan" prp (((w a n) 1))))
	(lex.add.entry
   		'("wans" prps (((w a n z) 1))))
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
   		'("was" (vbd full) (((w i z) 1))))
	(lex.add.entry
   		'("washing" nn (((w a sh) 1) ((i n) 0))))  
      	(lex.add.entry
   		'("washing" vbg (((w a sh) 1) ((i n) 0))))
	(lex.add.entry
   		'("wasnae" vbd|rb (((w i z) 1) ((n ii) 0))))
	(lex.add.entry
   		'("wed" prp|md (((w iii d) 1)))) ;; actually just for prp|md but using nil to fix bug when build_utts insists on w e d
	(lex.add.entry
   		'("wernae" vbd|rb (((w er r) 1) ((n ii) 0))))
	(lex.add.entry
   		'("wers" (vbd full) (((w er r z) 1))))
	(lex.add.entry
   		'("wers" (vbd reduced) (((w @r r z) 0))))
	(lex.add.entry
   		'("weve" prp|vbp (((w uh v) 1))))
	(lex.add.entry
   		'("what" wdt (((hw i ?) 1))))
        (lex.add.entry
   		'("what" wp (((hw i ?) 1))))
	(lex.add.entry
   		'("whe" nil (((w @) 0))))
	(lex.add.entry
   		'("wi" in (((w i) 1)))) ;;  "with"
	(lex.add.entry
   		'("wihr" in (((w ir r) 1)))) ;; actually for one instance of we're - this is to over-ride problem when building utts and it insisted on w er r
        (lex.add.entry
   		'("William" nnp (((w uh l) 1) ((y @ m) 0))))
        (lex.add.entry
   		'("Willie" nnp (((w uh) 1) ((l ii) 0))))
	(lex.add.entry
   		'("Willies" nnp|pos (((w uh) 1) ((l ii z) 0))))
	(lex.add.entry
   		'("Williell" nnp|md (((w uh) 1) ((l ii) 0) ((@ l!) 0))))
	(lex.add.entry
   		'("wir" nil (((w irr r) 0))))
	(lex.add.entry
   		'("wirra" nil (((w i t^) 1) ((@) 0))))  ;; with the (wi ra)
	(lex.add.entry
   		'("wirrah" nil (((w i t^) 1) ((@) 0))))  ;; with a
	(lex.add.entry
   		'("wirrat" nil (((w i t^) 0) ((a ?) 1))))  ;; with that	
	(lex.add.entry
   		'("wirrem" in|pp (((w i t^) 1) ((e m) 0))))  ;; with them
	(lex.add.entry
   		'("wirrus" in|pp (((w i t^) 1) ((@ z) 0))))  ;; with us		
	(lex.add.entry
   		'("withoot" in (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("withoot" nn (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("withoot" rb (((w i dh) 3) ((uu ?) 1))))
	(lex.add.entry
   		'("wizza" in|dt (((w i z) 0) ((@) 0))))  ;; with the (this speaker)
	(lex.add.entry
   		'("woman" nn (((w uh) 1) ((m i n) 0))))
	(lex.add.entry
   		'("women" nns (((w uh) 1) ((m @ n) 0))))
	(lex.add.entry
   		'("wouldnae" md|rb (((w uu d) 1) ((n ii) 0))))
	(lex.add.entry
   		'("wuh" nil (((w @) 0))))
	(lex.add.entry
   		'("yin" nns (((y i n) 1))))
	(lex.add.entry
   		'("yins" nns (((y i n z) 1))))
	(lex.add.entry
   		'("yous" prp (((y uuu z) 1)))) 
	(lex.add.entry
   		'("youse" prp (((y uuu z) 1)))) ;; same as above, including both spellings here
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

(lex.create "unilex-ediG")
(lex.set.compile.file (path-append unilexdir "unilex-edi.out"))
(lex.set.phoneset "unilex")
(lex.set.lts.method 'unilex-ediG_lts_function)
;(lex.set.pos.map english_pos_map_wp39_to_wp20)
(lex.set.pos.map nil)
(unilex-ediG_addenda)

(provide 'unilex-ediG)





