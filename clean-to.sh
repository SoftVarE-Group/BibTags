#!/usr/bin/env bash
java -cp mibtex/mibtex-cleaner.jar de.mibtex.BibtexCleaner "literature.bib" -o "$1/literature-cleaned.bib" "${@:2}"
cp MYabrv.bib $1
cp MYshort.bib $1
