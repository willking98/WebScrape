#Spellings
from spellchecker import SpellChecker
spell = SpellChecker()
drugs = ["anastzole", "amoxicillin", "ibuprofen", "flucloxacillin", "hiprex", "penicilin", "diamox", "codiene", "cefalexin"]
corrections = [""] * len(drugs)

med_spell = SpellChecker()
med_spell.word_frequency.load_text_file("/Users/Will/Desktop/Work from home/ALTAR/Trial/names.txt")

for i in range(0, len(drugs)):
    print(med_spell.correction(drugs[i]))
    correct = input()
    if correct == "y":
        corrections[i] = med_spell.correction(drugs[i])

    if correct == "n":
        corrections[i] = drugs[i]

    
