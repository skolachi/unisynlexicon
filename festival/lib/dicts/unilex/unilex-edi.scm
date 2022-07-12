;;; Unilex scheme definition.

;; EDI version.

(defvar unilexdir (path-append lexdir "unilex"))

(require 'pos)
(require 'unilex_phones)

(define (unilex-edi_lts_function word feats)
  "(unilex_lts_function word feats)
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
(define (unilex-edi_addenda)
  "(unilex-edi_addenda)
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
(hw w )
(s z)
(_ #)
                                                                               
))

(lex.create "unilex-edi")
(lex.set.compile.file (path-append unilexdir "unilex-edi.out"))
(lex.set.phoneset "unilex")
(lex.set.lts.method 'unilex-edi_lts_function)
;(lex.set.pos.map english_pos_map_wp39_to_wp20)
(lex.set.pos.map nil)
(unilex-edi_addenda)

(provide 'unilex-edi)





