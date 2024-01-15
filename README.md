# BibTags

[![Build Status](https://travis-ci.com/tthuem/BibTags.svg?branch=master)](https://travis-ci.com/tthuem/BibTags)

## Policies
- **Maintain consistent order of attributes** of entries. If you want to add a new entry, a good strategy is to copy an existing entry of the same type and adapt it.
- **Keys are formatted** using author names, publication venue, and year of publication: `<author abbreviation>:<venue><year>`. For example a paper published at `ICSE` in `2005` by `Alice Agda` and `Bob Busy` would have the key `AB:ICSE05`. In the following each key element is explained:
  - `<author abbreviation>`:
    - If the entry is a thesis: `<author abbreviation>` = `<last name of author>`. In case of a key conflict use `<author abbreviation>` = `<last name of author><first letter of first name of author>`
    - If entry has <=4 authors: `<author abbreviation>` = `<first letter of last name of author 1><first letter of last name of author 2>...`
    - If the entry has >4 authors: `<author abbreviation>` = `<first letter of last name of author 1><first letter of last name of author 2><first letter of last name of author 3>+`
  - `<venue>`: Each venue has an abbreviation (e.g., `ICSE`, `SoSym`, `ESECFSE`). These abbreviations are defined in `MYabrv.bib` and `MYshort.bib`. If a venue you encounter is not contained in these files, please add it (sorted in ascending alphabetic order). Use this abbreviation as the `<venue>` value.
  - `<year>`: Short version of the year the entry was published in. It has only two digits, ommitting the first two digits of a year number (i.e., `96` for 1996 and `05` for 2005). If you get old enough to find a redundancy caused by this two-digit abbreviation: congratulations.
  - In case that the generated key is conflicting with an existing key, add a suffix, such as `b`, `c`, ...
- **If a journal does not have an official abbreviation** of letters only we still use our custom abbreviation for MYshort.bib. For example, the _Journal on Software Maintenance: Research and Practice_ should be abbreviated _J. Softw. Maint: Res. Pract._ but not by its variable name `JSMRP` we invented. Still, we abbreviate it in MYshort with `@String{JSMRP = "JSMRP"}` for consistency.
- **If you detect an ill-formed key**, please update it. Leave a note that you did so including the previous key such that authors of papers using the old key can quickly find the updated key:
    ```tex
    % formerly known as KAK08
    @inproceedings{KAK:ICSE08,
    	author = {Christian K\"{a}stner and Sven Apel and Martin Kuhlemann},
    	title = {{Granularity in Software Product Lines}},
    	booktitle = ICSE,
    ...
    ```

### Policies for Theses

- **Keys** of theses are formatted according to the formatting rules described above.
- **The month of a thesis entry** is the month of the defense (because publication of a thesis might happen much later).
- **Publication status of theses** should be indicated in exactly one of the following three ways:
  - If the thesis is already published, add DOI and URL. The URL should directly point to the PDF.
  - If the thesis is not published and should not be published, add `% will not be published` as a comment above the entry.
  - If the thesis is not published but should be published, add `note = {To appear}`.
- **Add `type` for bachelor, master, and project thesis**. These theses should be specified as `@mastersthesis` as it is the only bibtex entry type for thesis (apart from `@phdthesis`). Distinguish between different types of thesis by using `type = {Bachelor's Thesis}`, `type = {Master's Thesis}`, or `type = {Project Thesis}` respectively.
- **For theses written in german** add `note = {In German}`.

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

