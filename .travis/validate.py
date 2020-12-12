#!/usr/bin/env python

import bibtexparser
from bibtexparser.bparser import BibTexParser

def validate(abrv, literature):

	print(f"> {abrv}")

	parser = BibTexParser(common_strings=True)

	#Required as Thomas uses @masterthesis
	parser.ignore_nonstandard_types = False 

	bibtex_str = ""
	with open("MYabrv.bib") as bibtex_file:
	   bibtex_str = bibtex_file.read()

	with open("literature.bib") as bibtex_file:
	   bibtex_str += bibtex_file.read()

	try:
		bibtex_database = bibtexparser.loads(bibtex_str, parser)
	except bibtexparser.bibdatabase.UndefinedString as use:
		print("[ERROR] MYabrv.bib")
		print(f"Variable not found: {use}")
		exit(1)

	print("\nSUCCESS\n")


validate(abrv="MYabrv.bib", literature="literature.bib")
validate(abrv="MYshort.bib", literature="literature.bib")

