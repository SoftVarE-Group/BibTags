#! /bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

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

run_biber () {
	echo -e -n "${GREEN}run $2 biber for $1...${NOCOLOR}"
	if biber $1 > biber_$1_$2.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
		cat biber_$1_$2.log | grep -E "^(WARN|ERROR)"
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat biber_$1_$2.log | grep -E "^(WARN|ERROR)"
		exit 1
	fi
}

run_bibtex () {
	echo -e -n "${GREEN}run $2 bibtex for $1...${NOCOLOR}"
	if bibtex -terse $1 > bibtex_$1_$2.log ; then
		echo -e "${GREEN}OK${NOCOLOR}"
		cat bibtex_$1_$2.log
	else
		echo -e "${RED}fail${NOCOLOR}" >&2
		cat bibtex_$1_$2.log
		exit 1
	fi
}

compile_biber () {
	run_pdflatex $1 1 "-draftmode"
	run_biber $1 1
	run_pdflatex $1 2 "-draftmode"
	run_biber $1 2
	run_pdflatex $1 3 ""
}

compile_bibtex () {
	run_pdflatex $1 1 "-draftmode"
	run_bibtex $1 1
	run_pdflatex $1 2 "-draftmode"
	run_bibtex $1 2
	run_pdflatex $1 3 ""
}

echo -e -n "${GREEN}change into latex dir...${NOCOLOR}"
if cd test_latex ; then
	echo -e "${GREEN}OK${NOCOLOR}"
else
	echo -e "${RED}FAIL${NOCOLOR}"
	exit 1
fi

echo -e -n "${GREEN}delete aux files in latex dir...${NOCOLOR}"
if find . -mindepth 1 -maxdepth 1 ! -name "*.tex" -delete ; then
	echo -e "${GREEN}OK${NOCOLOR}"
else
	echo -e "${RED}FAIL${NOCOLOR}"
	exit 1
fi

compile_biber short
compile_biber abrv
compile_bibtex natbib
