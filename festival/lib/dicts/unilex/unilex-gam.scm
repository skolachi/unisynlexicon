;;; Unilex scheme definition.

;; GAM version.

(defvar unilexdir (path-append lexdir "unilex"))

(require 'pos)
(require 'unilex_phones)

(define (unilex-gam_lts_function word feats)
  "(unilex-gam_lts_function word feats)
Function called for UNILEX when word is not found in lexicon.  Uses
LTS rules trained from the original lexicon, and lexical stress
prediction rules."
  (require 'lts)
  (if (not (boundp 'unilex-gam_lts_rules))
      (load (path-append unilexdir "unilex-gam_lts_rules.scm")))
  (let ((dcword (downcase word))
        (syls) (phones))
    (if (string-matches dcword "[a-z\-]*")
        (begin
          (set! phones (lts_predict dcword unilex-gam_lts_rules))
          (set! syls (lex.syllabify.phstress phones))
          )
        (set! syls nil))
    (list word nil syls)))

;; This list is built by manually taking pronounciations for abbreviations
;; from their full entries in the compiled lexicon.
(define (unilex-gam_addenda)
  "(unilex-gam_addenda)
Add entries to the current lexicon.  These are basically
words that are not in the keyword lexicon."
(lex.add.entry
   '("Jan" nnp (((jh a) 1) ((n y uu) 0) ((e) 2) ((r ii) 0))))
  (lex.add.entry
   '("Feb" nnp (((f e) 1) ((b r uu) 0) ((e) 2) ((r ii) 0))))
  (lex.add.entry
   '("Mar" nnp (((m ar r ch) 1))))
  (lex.add.entry
   '("Apr" nnp (((ei) 1) ((p r @ lw) 0))))
  (lex.add.entry
   '("Jun" nnp (((jh uu n) 1))))
  (lex.add.entry
   '("Jul" nnp  (((jh u) 0) ((l ai) 1))))
  (lex.add.entry
   '("Aug" nnp (((oo) 1) ((g @ s t) 0))))
  (lex.add.entry
   '("Sep" nnp (((s e p) 0) ((t e m) 1) ((b @r r) 0))))
  (lex.add.entry
   '("Sept" nnp (((s e p) 0) ((t e m) 1) ((b @r r) 0))))
  (lex.add.entry
   '("Oct" nnp (((aa k) 0) ((t ou) 1) ((b @r r) 0))))
  (lex.add.entry
   '("Nov" nnp (((n ou) 0) ((v e m) 1) ((b @r r) 0))))
  (lex.add.entry
   '("Dec" nnp (((d i) 0) ((s e m) 1) ((b @r r) 0))))
  (lex.add.entry
   '("'s" pos (((@ z) 0))))
  (lex.add.entry 
   '("*" nn (((a) 1) ((s t @r) 0) ((r i s k) 0))))
  (lex.add.entry 
   '("%" nn (((p @r r) 0) ((s e n t) 1))))
  (lex.add.entry 
   '("&" nn  (((a m) 1) ((p @r r) 0) ((s a n d) 2))))
  (lex.add.entry 
   '("$" nn (((d aa) 1) ((lw @r r) 0))))
  (lex.add.entry 
   '("#" nn (((p ow n d) 1))))
  (lex.add.entry 
   '("@" n (((a t) 1))))
  (lex.add.entry 
   '("+" cc (((p l uh s) 1))))
  (lex.add.entry 
   '("^" nn (((k a) 1) ((r @ t) 0))))
  (lex.add.entry 
   '("~" nn (((t i lw) 1) ((d @) 0))))
  (lex.add.entry 
   '("=" nns (((ii) 1) ((k w @ lw z) 0))))
  (lex.add.entry 
   '("/" nn (((s l a sh) 1))))
(lex.add.entry 
   '("\\" nn (((b a k) 1) ((s l a sh) 3))))
  (lex.add.entry 
   '("_" nn (((uh n) 1) ((t^ @r r) 0) ((s k or r) 2))))
  (lex.add.entry 
   '("|" nn  (((v @@r r) 1) ((t^ i) 0) ((k l!) 0) ((b ar r) 2))))
  (lex.add.entry 
   '(">" nn (((g r ei t^) 1) ((@r r) 0) ((dh eh n) 2))))
  (lex.add.entry 
   '("<" nn (((l e s) 1) ((dh eh n) 2))))
  (lex.add.entry 
   '("[" nn  (((l e f t) 1)((b r a) 1) ((k @ t) 0))))
  (lex.add.entry 
   '("]" nn  (((r ai t) 1) ((b r a) 1) ((k @ t) 0))))
  (lex.add.entry 
   '(" " nn  (((s p ei s) 1))))
  (lex.add.entry 
   '("\t" nn  ((( t a b ) 1))))
  (lex.add.entry 
   '("\n" nn  (((n uu) 1) ((l ai n) 3))))
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
  (lex.add.entry '("etc" nn (((e t) 0) ((s e) 1) ((t^ @r) 0) ((r @) 0))))
  (lex.add.entry '("Whittemore" nnp (((hw i t) 1) ((m or r) 0))))
  (lex.add.entry '("borealis" nnp (((b or) 2) ((r ii) 0) ((oo lw) 1) ((i s) 0) )))
  (lex.add.entry '("nightglow" nn (((n ai t) 1) ((g l ou) 2))) )
  (lex.add.entry '("worshiped" vbd (((w @@r r) 1) ((sh i p t) 0))) )

  (lex.add.entry '("gallina" nnp (((g @) 0) ((l ii) 1) ((n @) 0))))
  (lex.add.entry '("patino" jj (((p a) 0) ((t ii) 1) ((n ou) 0))))
  (lex.add.entry '("shunk" nn (((sh uh ng k) 1))))
  (lex.add.entry '("oolong" nnp (((uu) 1) ((l oo ng) 0))) )
  (lex.add.entry '("Hanrahan" nil (((h ar n) 1) ((r @) 0) ((h a n) 0))))
  (lex.add.entry '("mab" nnp (((m a b) 1))))
  (lex.add.entry '("unwin" nnp (((uh n) 1) ((w i n) 0))))
  (lex.add.entry '("Perrault" nnp (((p @r) 0) ((oo lw) 1))))
  (lex.add.entry '("Wada" nnp (((w a) 1) ((t^ @) 0))) )
  (lex.add.entry '("Nakata" nil (((n a) 0) ((k aa) 0) ((t^ @) 0))))
  (lex.add.entry '("tambo" nn (((t a m) 1) ((b ou) 0))))
  (lex.add.entry '("kerfoot" nnp (((k @r r) 1) ((f u t) 0))))
  (lex.add.entry '("spink" nnp (((s p i ng k) 1))))
  (lex.add.entry '("corry" nnp (((k oo) 1) ((r ii) 0))))
  (lex.add.entry '("ee" nil (((ii) 0))))
  (lex.add.entry '("molokai" nnp (((m @) 1) ((lw aa) 0) ((k ai) 0))))
  (lex.add.entry '("niihau" nnp (((n ii) 0) ((h ow) 1))))
  (lex.add.entry '("claudine" nnp (((k l oo) 0)((d ii n) 1))))
  (lex.add.entry '("Pasquini" nnp (((p @) 0) ((s k w ii) 1) ((n ii) 0))))
  (lex.add.entry '("Waikiki" nnp (((w ai) 1) ((k ii ) 2) ((k ii) 2))))
  (lex.add.entry '("Oahu" nnp (((@) 0) ((w aa) 1) ((h uu) 0))))
  (lex.add.entry '("womble" nn (((w aa m) 1) ((b l!) 0))))
  (lex.add.entry '("dennin" nnp (((d e) 1) ((n i n) 0))) )
  (lex.add.entry '("linderman" nnp (((l i n) 1) ((t^ @r r) 0) ((m @ n) 0))))
  (lex.add.entry '("daughtry" nn (((d oo) 1) ((t r ii) 0))))
  (lex.add.entry '("fitzhugh" nnp (((f i t s) 1) ((h y uu) 1))))
  (lex.add.entry '("roscoe" nnp (((r aa s) 1) ((k ou) 0))))
  (lex.add.entry '("billinger" nnp (((b i) 1) ((lw @ n) 0) ((jh @r r) 0))) )
  (lex.add.entry '("elam" nnp (((ii) 1) ((l @ m) 0))))
  (lex.add.entry '("harnish" nnp (((h ar r) 1) ((n i sh) 0))))
  (lex.add.entry '("howison" nnp (((h ow) 1) ((i) 0) ((z n!) 0))))
  (lex.add.entry '("tse" nnp (((t s ii) 1))))
  (lex.add.entry '("sandel" nnp (((s a n) 1) ((t^ l!) 0))))
  (lex.add.entry '("chauncey" nnp (((ch oo n) 1) ((s ii) 0))))
  (lex.add.entry '("depew" nnp (((d i) 0) ((p y uu) 1))))
  (lex.add.entry '("brinker" nnp (((b r i ng k) 1) ((@r r) 0))))
  (lex.add.entry '("roadmate" nn (((r ou d) 1) ((m ei t) 3))))
  (lex.add.entry '("zilla" nnp (((z i) 1) ((lw @) 0))))
  (lex.add.entry '("oona" nnp (((uu) 1) ((n @r r) 0))))
  (lex.add.entry '("Doane" nnp (((d ou n) 1))))
)

(set! unilex-gam-backoff_rules
'(
(l! l)
(n! n)
(eir e)
(iy ii)
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
(@r @)
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


(lex.create "unilex-gam")
(lex.set.compile.file (path-append unilexdir "unilex-gam.out"))
(lex.set.phoneset "unilex")
(lex.set.lts.method 'unilex-gam_lts_function)
;(lex.set.pos.map english_pos_map_wp39_to_wp20)
(lex.set.pos.map nil)
(unilex-gam_addenda)

(provide 'unilex-gam)





