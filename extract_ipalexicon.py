import sys
import re

lexicon = {}

def convert_char(char_string):
	return chr(int(char_string[2:-1]))

with open(sys.argv[1]) as f:
	for line in f:
		fields = line.strip().split(':')
		if len(fields) > 1: #rough way to parse html
			word = fields[0].split('>')[1] if fields[0].startswith('<p>') else fields[0]
			lexicon[word] = lexicon.get(word,[])
			transcription = fields[3].split('> ')[1].split(' <')[0].strip()
			ipa_trans = []
			transcription = transcription.replace('<b>','').replace('</b>','') # transcriptions containing glottal stop 
			for i in range(len(transcription)):
				if transcription[i].isalpha() or transcription[i] in ['.','?']:
					ipa_trans.append(transcription[i])
				if transcription[i] == '&':
					ipa_trans.append(convert_char(transcription[i:i+6]))
			lexicon[word].append(ipa_trans)
				

with open(sys.argv[1].split('.')[0],'w',encoding='utf-8') as f:
	for k in lexicon.keys():
		for t in lexicon[k]:
			f.write('%s\t%s\n'%(k,''.join(t).rstrip('P').rstrip('FONTFACE')))
