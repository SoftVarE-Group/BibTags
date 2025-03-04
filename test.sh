#!/usr/bin/env bash

## Colors for pretty printing in console output
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

## This function changes into the test_latex directory.
## If this is not possible (for instance, if the directory does not exist) it fails with an error message and terminates the script.
change_into_latex_dir () {
	echo -e -n "${GREEN}change into latex dir...${NOCOLOR}"
	if cd test_latex ; then
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}FAIL${NOCOLOR}"
		exit 1
	fi
}

## This function deletes all files but .tex files in the current working directory.
## Deletes only files.
delete_auxiliary_files () {
	echo -e -n "${GREEN}delete auxiliary files in latex dir...${NOCOLOR}"
	if find . -mindepth 1 -maxdepth 1 -type f ! -name "*.tex" -delete ; then
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}FAIL${NOCOLOR}"
		exit 1
	fi
}

## This function create a separate directory for output files.
create_dir () {
	echo -e -n "${GREEN}create dir $1...${NOCOLOR}"
	if mkdir -p $1 ; then
		if find $1 -mindepth 1 -maxdepth 1 -type f -delete ; then
			echo -e "${GREEN}OK${NOCOLOR}"
		else
			echo -e "${RED}FAIL${NOCOLOR}"
			exit 1
		fi
	else
		echo -e "${RED}FAIL${NOCOLOR}"
		exit 1
	fi
}

## This function moves output files (e.g., .log and .pdf) to a separate directory.
move_output_files () {
	create_dir $1
	echo -e -n "${GREEN}move $1 files to $1 dir...${NOCOLOR}"
	if find . -mindepth 1 -maxdepth 1 -type f -name "*.$1" -exec mv {} $1 \; ; then
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}FAIL${NOCOLOR}"
		exit 1
	fi
}

## This function creates the literature-cleaned.bib file by calling a dedicated java program.
create_cleaned_literature () {
	echo -e -n "${GREEN}create literature-cleaned.bib...${NOCOLOR}"
	if java -cp ../mibtex/mibtex-cleaner.jar de.mibtex.BibtexCleaner "../literature.bib" > mibtex_cleaner.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}FAIL${NOCOLOR}"
		cat mibtex_cleaner.log
		exit 1
	fi
}

## This function runs pdflatex for a given file.
## It generates a log file and in case of an error shows the problem in the console.
## parameter $1 the name of the tex file (without .tex ending)
## parameter $2 the number of the run (pdflatex requires multiple runs)
run_pdflatex () {
	echo -e -n "${GREEN}run $2 pdflatex for $1...${NOCOLOR}"
	if pdflatex $3 -halt-on-error $1 2>&1 > pdflatex_$1_$2.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat pdflatex_$1_$2.log | grep -E "^[!]"
		exit 1
	fi
}

## This function runs biber for a given file.
## It generates a log file and in case of an error shows the problem in the console.
## parameter $1 the name of the aux file (without .aux ending)
## parameter $2 the number of the run (biber requires multiple runs)
run_biber () {
	echo -e -n "${GREEN}run $2 biber for $1...${NOCOLOR}"
	if biber -u -U --nolog $1 > biber_$1_$2.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
		cat biber_$1_$2.log | grep -E "^(WARN|ERROR)"
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat biber_$1_$2.log | grep -E "^(WARN|ERROR)"
		exit 1
	fi
}

## This function runs bibtex for a given file.
## It generates a log file and shows the output in the console.
## parameter $1 the name of the aux file (without .aux ending)
## parameter $2 the number of the run (bibtex requires multiple runs)
run_bibtex () {
	echo -e -n "${GREEN}run $2 bibtex for $1...${NOCOLOR}"
	if bibtex -terse $1 > bibtex_$1_$2.log ; then
		cat bibtex_$1_$2.log | grep -v "(There were" | grep -Fxv -f ../bibtex-ignore.txt > tmp; mv tmp bibtex_$1_$2.log
		if [ -s bibtex_$1_$2.log ]; then
			echo -e "${RED}fail${NOCOLOR}" >&2
			cat bibtex_$1_$2.log >&2
			exit 1
		fi
		echo -e "${GREEN}OK${NOCOLOR}"
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat bibtex_$1_$2.log >&2
		exit 1
	fi
}

## This function calls the check_integrity python script and write its output to the console.
## The script checks for problems within bibtex entries, such as missing fields and wrong field values.
check_integrity () {
	echo -e -n "${GREEN}checking bibtex entries...${NOCOLOR}"
	local PYTHON
	if command -v python3 &> /dev/null; then
		PYTHON=python3
	else
		PYTHON=python
	fi
	if $PYTHON ../scripts/check_integrity.py > check_integrity.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
		cat check_integrity.log
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat check_integrity.log
		exit 1
	fi
}

## This function calls pdflatex with biber
## parameter $1 the name of the tex file (without .tex ending)
compile_biber () {
	run_pdflatex $1 1 "-draftmode"
	run_biber $1 1
	run_pdflatex $1 2 "-draftmode"
	run_biber $1 2
	run_pdflatex $1 3 ""
}

## This function calls pdflatex with bibtex
## parameter $1 the name of the tex file (without .tex ending)
compile_bibtex () {
	run_pdflatex $1 1 "-draftmode"
	run_bibtex $1 1
	run_pdflatex $1 2 "-draftmode"
	run_bibtex $1 2
	run_pdflatex $1 3 ""
}

compile() {
	compile_bibtex short-natbib
	compile_bibtex short-natibib-clean
	compile_biber short-biblatex
	compile_biber short-biblatex-clean
	compile_biber abrv-biblatex

	move_output_files pdf
	move_output_files log
	delete_auxiliary_files
}

## Main script
change_into_latex_dir
delete_auxiliary_files

default() {
	check_integrity
	create_cleaned_literature
	compile
}

if [[ -z "$*" ]]; then
	default
else
	"$@"
fi
