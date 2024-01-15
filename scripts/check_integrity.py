#! /bin/python
import bibtexparser
from bibtexparser.bparser import BibTexParser
import re
import yaml
import pandas as pd
from titlecase import titlecase
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
database_file = '../literature.bib'

title_regex = re.compile(r"^\{.*\}$", re.DOTALL)
pages_regex = re.compile(r"^[a-zA-Z0-9,.:()]+(--[a-zA-Z0-9,.:()]+)?$", re.DOTALL)
author_regex = re.compile(r"([^,]+),[^,]+(\s+and\s+([^,]+),[^,]+)*", re.DOTALL)


def get_path(file_name):
    return os.path.join(script_dir, file_name)


def is_set(key):
    if not key in settings:
        print('WARNING settings ' + key + ' is not defined!')
        return False
    return settings[key]


def add_problem(entry, problem_type, problem_message):
    entry_id = entry['ID']
    if entry_id not in problems:
        problems[entry_id] = []
    problems[entry_id].append((problem_type, problem_message))


def check_string_fields(entry):
    for field in string_fields:
        if is_set('string_' + field):
            if field in entry and isinstance(entry[field], str):
                add_problem(entry, 'non_string_' + field, entry[field])


def gen_string_fields(entry):
    for field in string_fields:
        if field in entry and isinstance(entry[field], str):
            field_value = entry[field]
            key = re.sub('[^A-Z]', '', field_value)
            new_strings[field_value] = (field, key, field_value)


def check_field_type_exists(entry, field_type):
    if is_set(field_type + '_fields'):
        entry_type=entry['ENTRYTYPE']
        if entry_type in fields:
            required_fields = (fields[entry_type])[field_type] or []
        else:
            required_fields = []
        entry_id = entry['ID']
        entry_fields = set(entry.keys())
        if 'missing' in entry:
            missing = [x for x in entry['missing'].get_value().split(',') if x]
        else:
            missing = []
        for field in required_fields:
            if isinstance(field, list):
                present = False
                for alternative_field in field:
                    if alternative_field in entry_fields or alternative_field in missing:
                        present = True
                        break
                if not present:
                    add_problem(entry, 'missing_' + field_type + '_field', field)
            else:
                if field not in missing and field not in entry_fields:
                    add_problem(entry, 'missing_' + field_type + '_field', field)


def check_field_types_exists(entry):
    check_field_type_exists(entry, 'required')
    check_field_type_exists(entry, 'wanted')
    check_field_type_exists(entry, 'optional')


def check_title(entry):
    if ('title' in entry):
        org = entry['title']
        if is_set('title_protect'):
            if (not title_regex.match(org)):
                add_problem(entry, 'incorrect_title_protect', org)
        if is_set('title_capitilization'):
            correct_title = titlecase(org)
            if (org != correct_title):
                add_problem(entry, 'incorrect_title_capitilization', org + " -> " + correct_title)


def check_pages(entry):
    if ('pages' in entry):
        org = entry['pages']
        if is_set('pages'):
            if (not pages_regex.match(org)):
                add_problem(entry, 'incorrect_pages', org)


def check_author(entry):
    if is_set('name_order'):
        if ('author' in entry):
            authors = entry['author']
            if (not author_regex.match(authors)):
                names = re.split(r'\s+and\s+', authors)
                for name in names:
                    name_parts = re.split('\s+', name)
                    if len(name_parts) != 2:
                        add_problem(entry, 'incorrect_author_order', authors)
                        return


def get_last_name(name):
    name_parts = re.split(r'\s+', name)
    return name_parts[len(name_parts) - 1]


def check_key(entry):
    if is_set('bib_keys') and 'author' in entry:
        org_key = entry['ID']
        authors = entry['author']
        entry_type = entry['ENTRYTYPE']

        if (author_regex.match(authors)):
            names = re.split(r'\s+and\s+', authors)
        else:
            names = [get_last_name(name) for name in re.split(r'\s+and\s+', authors)]

        namePart = ""
        venuePart = ""
        yearPart = ""
        if entry_type == 'mastersthesis' or entry_type == 'phdthesis':
            for name in names:
                namePart = namePart + name.split(',')[0]
        else:
            for i in range(0, min(len(names), 3)):
                namePart = namePart + names[i][0]
            if len(names) == 4:
                namePart = namePart + names[3][0]
            elif len(names) > 4:
                namePart = namePart + "+"
            namePart = namePart + ":"
        if entry_type == 'inproceedings':
            if 'booktitle' in entry:
                venue = entry['booktitle']
                if isinstance(venue, str):
                    venuePart = venue.upper()
                else:
                    venuePart = venue.expr[0].name.upper()
        if entry_type == 'article':
            if 'journal' in entry:
                venue = entry['journal']
                if isinstance(venue, str):
                    venuePart = venue.upper()
                else:
                    venuePart = venue.expr[0].name.upper()
        if 'year' in entry:
            year = entry['year']
            if isinstance(year, str):
                yearPart = year[2:4]
            else:
                yearPart = year.expr[0].name[2:4]
        key = namePart + venuePart + yearPart
        if (not org_key.casefold().startswith(key.casefold())):
            add_problem(entry, 'incorrect_bib_key', org_key + " != " + key)
       

if __name__ == '__main__':
    with open(get_path("check_settings.yml"), "r") as stream:
        try:
            settings = yaml.safe_load(stream)
            #print(settings)
        except yaml.YAMLError as exc:
            print(exc)

    with open(get_path("check_fields.yaml"), "r") as stream:
        try:
            fields = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    with open(get_path("check_string_fields.yaml"), "r") as stream:
        try:
            string_fields = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)

    # Check capitilization
    # Check double braces for title
    # Check string fields
    # Check author first name, second name order
    # Check bib keys

    # Check entry order: year, type, venue, month, key
    # Check notes up to date

    parser = BibTexParser(common_strings=False,interpolate_strings=False)
    parser.homogenise_fields=False
    parser.ignore_nonstandard_types=False

    entrytypes = fields.keys()
    entries = {}
    problems = {}

    with open(database_file) as bibtex_file:
        bib_database = bibtexparser.load(bibtex_file, parser)
        #df = pd.DataFrame(bib_database.entries)
        #df.to_csv('literature.csv', index=False)

        for entry in bib_database.entries:
            check_string_fields(entry)
            check_field_types_exists(entry)
            check_title(entry)
            check_author(entry)
            check_key(entry)
            check_pages(entry)

        new_strings = {}
        for entry in bib_database.entries:
            gen_string_fields(entry)

    count = 0
    for entry_problems in problems.items():
        count = count + 1
        print(str(count) + ": " + entry_problems[0])
        for entry_problem in entry_problems[1]:
            print('\t' + str(entry_problem))

    if is_set('print_missing_strings'):
        ns = list(new_strings.values())
        ns.sort(key=lambda a: a[0])
        field_type = None
        for new_string in ns:
            if field_type != new_string[0]:
                field_type = new_string[0]
                print(field_type)
            print("@String{" + new_string[1] + " = \""+ new_string[2] +"\"}")

