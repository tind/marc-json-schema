import click
import json
import re

from flask.json import tojson_filter
from jinja2 import Template, Environment, FileSystemLoader


def clean_name(name):
    """FIXME quick hack.

    Please forgive me :).
    """
    name = name.lower()
    name = name.replace('etc.', '')
    name = name.replace(' ', '_')
    name = name.replace(',', '_')
    name = name.replace('/', '_')
    name = name.replace('(', '')
    name = name.replace(')', '')
    name = name.replace('-', '_')
    name = name.replace('.', '')
    name = name.replace("'", '_')
    name = name.replace('$', '_')
    name = re.sub('___*', '_', name)
    name = name.strip('_')
    return name


def get_indicator(position, field):
    indicators = field.get('indicators', {})
    position = str(position)
    if not indicators or position not in indicators:
        return {'re': '.'}

    indicator = indicators[position]
    if indicator['name'] == 'Undefined':
        return {'re': '.'}

    indicator['name'] = clean_name(indicator['name'])

    def expand(key, value):
        if '-' in key:
            start, stop = key.split('-')
            returndict = dict()
            return ((str(x), str(x)) for x in range(int(start), int(stop) + 1))
        return [(key, value)]

    def clean_string(s):
        s = re.sub(r'\\n|\\t', "", s)
        s = re.sub(r'\s{2,}', " ", s)
        return s.strip()

    indicator['values'] = dict(
        (k.replace('#', '_'), clean_string(v)) for key, value in
        indicator.get('values', {}).items() for k, v in expand(key, value)
    )

    for key, value in indicator['values'].items():
        if 'specified in' in value:
            subfield = value.split("$")[-1]
            indicator['specified_in_subfield'] = subfield
            indicator['specified_in_subfield_ind'] = key

    if len(indicator.get('values')) > 0:
        indicator['re'] = '[{0}]'.format(''.join(
            set(indicator.get('values', {}).keys()) | set('_')
        ).replace('#', '_'))
    else:
        return {'re': '.'}

    return indicator


def reverse_indicator_dict(d):
    new_dict = {}
    for key, value in d.items():
        if key == '#':
            key = '_'
        new_dict[value] = key

    return new_dict


def int_to_str(i):
    if isinstance(i, int):
        return str(i)
    else:
        return i


def sort_field_map(d, reverse=False):
    index = 1 if reverse else 0

    def can_be_int(d):
        try:
            int(d)
            return True
        except (ValueError, TypeError):
            return False
    return sorted([(key, value) for key, value in d.items()], key=lambda item: (can_be_int(item[index]), item[index]))


@click.command()
@click.argument('source', type=click.File('r'))
@click.argument('template')
@click.option('--re-fields', help='Regular expression to filter fields.')
def generate(source, template, re_fields=None):
    """Output rendered JSONAlchemy configuration."""
    re_fields = re.compile(re_fields) if re_fields else None
    data = [(code, value) for code, value in json.load(source).items()
            if re_fields is None or re_fields.match(code)]
    templateLoader = FileSystemLoader( searchpath="." )
    env = Environment(extensions=['jinja2.ext.do'], loader=templateLoader)
    tpl = env.get_template(template)
    click.echo(tpl.render(
        data=sorted(data),
        any=any,
        map=map,
        len=len,
        int_to_str=int_to_str,
        clean_name=clean_name,
        get_indicator=get_indicator,
        sort_field_map=sort_field_map,
        reverse_indicator_dict=reverse_indicator_dict,
        tojson=tojson_filter,
        set=lambda *args, **kwargs: list(set(*args, **kwargs)),
    ))

if __name__ == '__main__':
    generate()
