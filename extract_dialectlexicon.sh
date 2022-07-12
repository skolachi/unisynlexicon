#!/bin/bash

towncode=$1

if [ $# -eq 0 ]; then
    cat .towncode_err.tmp 
    exit 1
fi

./get-exceptions.pl -a $towncode -f unilex > intermediatelexicon-$towncode
./post-lex-rules.pl -a $towncode -f intermediatelexicon-$towncode > postlex-$towncode
./map-unique.pl -a $towncode -f postlex-$towncode > mapunique-$towncode
./output-sam.pl -a $towncode -f mapunique-$towncode > sampalexicon-$towncode
./output-ipa.pl -f sampalexicon-$towncode > ipalexicon-$towncode.html

python3 extract_ipalexicon.py ipalexicon-$towncode.html

rm intermediatelexicon-$towncode postlex-$towncode mapunique-$towncode 
