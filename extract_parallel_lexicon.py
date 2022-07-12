from pywiktionary import IPA
import re
import sys

cmu_phoneset = set([re.sub('\d','',p.strip()) for p in "AA0 ,AA1 ,AA2 ,AE0 ,AE1 ,AE2 ,AH0 ,AH1 ,AH2 ,AO0 ,AO1 ,AO2 ,AW0 ,AW1 ,AW2 ,AY0 ,AY1 ,AY2 ,B ,CH ,D ,DH ,EH0 ,EH1 ,EH2 ,ER0 ,ER1 ,ER2 ,EY0 ,EY1 ,EY2 ,F ,G ,HH ,IH0 ,IH1 ,IH2 ,IY0 ,IY1 ,IY2 ,JH ,K ,L ,M ,N ,NG ,OW0 ,OW1 ,OW2 ,OY0 ,OY1 ,OY2 ,P ,R ,S ,SH ,T ,TH ,UH0 ,UH1 ,UH2 ,UW0 ,UW1 ,UW2 ,V ,W ,Y ,Z ,ZH".split(',')])

def convert_dictionary(dictfile):
	lexicon = {}
	with open(dictfile,encoding='utf-8') as f:
		for line in f:
			fields = line.strip().split('\t')
			word = fields[0]
			lexicon[fields[0]] = lexicon.get(fields[0],[])
			try:
				transcription = IPA.IPA_to_CMUBET(fields[1])
			except:
				print('%s transcription missing for: '%(dictfile.split('-')[1].upper()),fields[0])
				continue
			phones = []
			for p in transcription.split():
				if p != 'SIL':
					if p == 'O':
						phones.append('AO')
					elif p == 'AX':
						phones.append('AH')
					elif p == 'DX':
						phones.append('D')
					elif p == 'EM':
						phones.extend(['AH','M'])
					elif p == 'EN':
						phones.extend(['AH','N'])
					#elif p not in cmu_phoneset:
					#	print(p,word,transcription)
					else:
						phones.append(p)
			lexicon[word].append(' '.join(phones))

	return lexicon

dia1 = sys.argv[1]
dia2 = sys.argv[2]

dia1_dict = convert_dictionary(dia1)
dia2_dict = convert_dictionary(dia2)

print(len(dia1_dict),len(dia2_dict))

with open('unisyn_%s_%s_parallel_cmubet'%(dia1.split('-')[1],dia2.split('-')[1]),'w') as f:
	for k in dia1_dict.keys():
		for p1 in dia1_dict[k]:
			for p2 in dia2_dict[k]:
				f.write('%s\t%s\t%s\n'%(k,p1.strip(),p2.strip()))			
