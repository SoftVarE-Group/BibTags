java -jar mibtex/mibtex-cleaner.jar "literature.bib"
if [ "$1" ]; then
  cp literature-cleaned.bib $1
  cp MYabrv.bib $1
  cp MYshort.bib $1
  cp MYfull.bib $1
fi
read -n1 -r -p "Press any key to continue..." key