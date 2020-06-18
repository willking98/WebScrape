#Spellings
from spellchecker import SpellChecker
import pandas
import numpy as np

df = pandas.read_csv("/Users/Will/Desktop/Work from home/ALTAR/Trial/ConMed.csv")
medname = df['MedName']
medname = list(medname)
medname = np.asarray(medname)

# Tester
medname = medname[540:550]

spell = SpellChecker()
corrections = [""] * len(medname)

med_spell = SpellChecker()
med_spell.word_frequency.load_text_file("/Users/Will/Desktop/Work from home/ALTAR/Trial/names.txt")

for i in range(0, len(medname)):
    print(str("Original: ") + medname[i] + str("    Correction: ") + med_spell.correction(medname[i]))
    correct = input()
    if correct == "y":
        corrections[i] = med_spell.correction(medname[i])

    else:
        corrections[i] = medname[i]
