# BibTags

[![Build Status](https://travis-ci.com/tthuem/BibTags.svg?branch=master)](https://travis-ci.com/tthuem/BibTags)

## Policies for Adding New Entries
- **Maintain consistent order of attributes** of entries. If you want to add a new entry, a good strategy is to copy an existing entry of the same type and adapt it.
- **Keys are formatted** using author names, publication venue, and year of publication: `<author abbreviation>:<venue><year>`. For example a paper published at `ICSE` in `2005` by `Alice Change` and `Bob Delta` would have the key `CD:ICSE05`. In the following each key element is explained:
  - `<author abbreviation>`:
    - If the entry is a thesis: `<author abbreviation>` = `<last name of author>`. In case of a key conflict use `<author abbreviation>` = `<last name of author><first letter of first name of author>`
    - If entry has <=4 authors: `<author abbreviation>` = `<first letter of last name of author 1><first letter of last name of author 2>...`
    - If the entry has >4 authors: `<author abbreviation>` = `<first letter of last name of author 1><first letter of last name of author 2><first letter of last name of author 3>+`
  - `<venue>`: Each venue has an abbreviation (e.g., `ICSE`, `SoSym`, `ESECFSE`). These abbreviations are defined in `MYabrv.bib` and `MYshort.bib`. If a venue you encounter is not contained in these files, please add it (sorted in ascending alphabetic order). Use this abbreviation as the `<venue>` value.
  - `<year>`: Short version of the year the entry was published in. It has only two digits, ommitting the first two digits of a year number (i.e., `96` for 1996 and `05` for 2005). If you get old enough to find a redundancy caused by this two-digit abbreviation: congratulations.
  - In case that the generated key is conflicting with an existing key, add a suffix, such as `b`, `c`, ...
- **If a journal does not have an official abbreviation** of letters only we still use our custom abbreviation for MYshort.bib. For example, the _Journal on Software Maintenance: Research and Practice_ should be abbreviated _J. Softw. Maint: Res. Pract._ but not by its variable name `JSMRP` we invented. Still, we abbreviate it in MYshort with `@String{JSMRP = "JSMRP"}` for consistency.
- **If you detect an ill-formed key**, please update it. Add a corresponding `renamedFrom = {...},` containing the previous key, such that authors of papers using the old key can quickly find the updated key:
    ```tex
    @inproceedings{KAK:ICSE08,
        renamedFrom = {KAK08},
    	author = {Christian K\"{a}stner and Sven Apel and Martin Kuhlemann},
    	title = {{Granularity in Software Product Lines}},
    	booktitle = ICSE,
    ...
    ```
- **Month and Year**: 
  - **Journal Articles**: The publication month and year of a journal is that when the issue (not the article) is published. DBLP seems to have solid knowledge on that (compared to Springer's own website).
  - **For theses**, we always use the month when the thesis was defended (not when it is submitted and not when it is finally published).
  - **For conferences**, the month and year is typically the first day of the conference. As SPLC was in August and September, both months were used.
  - **For theses** the month is the month of the defense (because publication of a thesis might happen much later).
- When adding **unpublished articles**, try to already add the DOI. Helps to keep track of the publication status.

## Additional Policies for Theses
- **Publication status of theses** should be indicated in exactly one of the following three ways:
  - If the thesis is already published, add DOI and URL. The URL should directly point to the PDF.
  - If the thesis is not published and should not be published, add `comments = NotToBePublished,`.
  - If the thesis is not published but should be published, add `note = {To appear}`.
- **Add `type` for bachelor, master, and project thesis**. These theses should be specified as `@mastersthesis` as it is the only bibtex entry type for thesis (apart from `@phdthesis`). Distinguish between different types of theses by using `type = Bachelor`, `type = Master`, or `type = Project` respectively.
- **For theses written in german** add `note = {In German}`.

## Policies for Updating Existing Entries
- When a paper happens to become **subsumed**, please change the key. This way, we make sure to update all references of outdated publications. In addition, you may want to use the subsumedby field.

## Tips and Tricks
- When checking whether all your papers are **complete**, it is helpful to compare all papers on your website (or in Bibtags) with those being listed in ACM, DBLP and Google Scholar. ACM and DBLP do have the best quality in their data.

## Custom Fields
Use custom fileds to add addtional information for single entries. **Do not write comments inbetween entries.**
- **comments**: Contains miscellaneous comments for this entry.
  - Common strings:
    - NotToBePublished (For Bachelor/Master theses)
  - Example: `comments = NotToBePublished,`

- **missing**: Documents which information for required fields are unavailable for this entry.
  - Common strings:
    - NoDOI
    - NoUrl
    - NoPages
    - NoMonth
    - NoPublisher
    - NoAddress
    - NoChapterNo
  - Example: `missing = NoDOI # NoURL # NoMonth # NoAddress,`

- **subsumes**: Contains all keys of entries, which are subsumed by this entry.
  - Example: `subsumes = {RBP+:TR22,RPTS:FORTE22,RPTS:TR22},`

- **subsumedby**: Contains key of the entry, which subsumes this entry.
  - Example: `subsumedBy = {RBP+:LMCS23},`

- **renamedFrom**: Contains previous keys of this entry.
  - Example: `renamedFrom = {AGK+:SPLC2020},`

## DON'Ts
- **Edit `literature-cleaned.bib`**: This is a generated file. It is generated from literature cleaned with [MibTeX](https://github.com/SoftVarE-Group/MibTeX). After you changed `literature.bib`, you can update `literature-cleaned.bib` by running `clean.sh` / `clean.bat`.

## Testing

Many problems with added (and some existing) entries can be detected automatically by running the script `test.sh`.
This script does multiple checks:
1. Creates literature-cleaned.bib using mibtex
2. Compiles bib files with latex
  1. Using biblatex and biber to compile `literature.bib` and `MYshort.bib`
  2. Using biblatex and biber to compile `literature.bib` and `MYabrv.bib`
  3. Using natbib and bibtex to compile `literature.bib` and `MYshort.bib`
 4. Using natbib and bibtex to compile `literature-cleaned.bib` and `MYshort.bib`
3. Runs python script `scripts/check_integrity.py`

The script display problems in the console output. However, the complete output of all called tools can be found in individual .log files in the directory `test_latex`. This directory also contains the compiled pdf files, for further manual inspection.

### check_integrity.py

This script performs multiple checks for all entries in the file `literature.bib`.
1. Tests that fields declared as string fields contain only string values.
2. Creates bibtex strings for fields that are declared as string fields but do not contains string values and prints them to the console.
3. Tests that for each entry *required*, *wanted* and *optional* exist or are declared as missing.
4. Tests that the title of each entry is protected (uses `{{...}}`).
5. Tests that the title of each entry is correctly capitalized (this may produce false optional results for some titles).
6. Tests that the pages of each entry are formated correctly (use `--`).
7. Tests that the names of authors of each entry follow the syntax `<last name>, <first name> and ...`.
8. Tests that the key of each entry conforms to our naming scheme (may also produce false positive results).

All detected problems are written to the console grouped by entries.

The script can be configured using the following files 
- `check_integrity_config.yaml`: Declares which specific checks are enabled/disabled.
- `field_types.yaml`: Declares for each entry type (e.g. inproceedings, article, ...) which fields are required (must be present), wanted (additional useful information), or optional (can be present, but are mostly ignored). Some fields are mutually exclusive, such as volume and number for inproceedings entries. This is defined by using sub lists in the config file.
      For example: ```
      - - volume
        - number
      ```
- `string_fields.yaml`: Declares which fields should contain bibtex strings instead of literals.
