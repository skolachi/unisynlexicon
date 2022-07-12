Sudheer Kolachina
21/02/2022

This repo contains scripts to extract dialect dictionaries from the UNISYN lexicon system developed by CSTR, Edinburgh. 

See Documents/Documentation1_3.pdf for full details of UNISYN. 

Usage-

1. The steps to extract a dialect lexicon are all in extract_dialectlexicon.sh. 

Example:
bash extract_dialectlexicon.sh gam (General American)

This script creates two files- ipalexicon-gam and sampalexicon-gam, containing IPA and SAMPA transcriptions respectively.

2. To convert phoneset from IPA to CMUBET, pywiktionary package is used. This is part of wikt2pron package but I made a few changes to the source code.

The script extract_parallel_lexicon.py can be used to extract a parallel dictionary of two dialects in CMUBET phone set.

python3 extract_parallel_lexicon.py ipalexicon-dia1 ipalexicon-dia2

Issues- 

1. IPA to CMUBET conversion in pywiktionary runs into following issues- 
a. symbol for phone /g/ is different due to character encoding.  
b. conversion fails for glottal stops in some dialects (Aberdeen dialect, see words like zlotty)
2. IPA conversion within Unisyn can fail on corner cases.  
