#!/bin/bash
who=${1:-"ek"}
grep "$who-tags" literature.bib | cut -d= -f2- | tr -d '{}' | tr , '\n' | grep -E .+ | sort | uniq 