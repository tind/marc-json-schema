import click
import json
import re

from flask.json import tojson_filter
from jinja2 import Template


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

def get_indicator(possition, field):
    indicators = field.get('indicators', {})
    possition = str(possition)
    if not possition in indicators:
        return {'re': '.'}

    indicator = indicators[possition]
    if indicator['name'] == 'Undefined' or clean_name(indicator['name']) in [
            'source_of_code', 'number_source', 'code_source', 'type_of_address',
            'source_of_term', 'same_as_associated_field', 'same_as_associated_field']:
        return {'re': '.'}

    indicator['name'] = clean_name(indicator['name'])

    def expand(key):
        if '-' in key:
            start, stop = key.split('-')
            return map(str, range(int(start), int(stop) + 1))
        return [key]

    indicator['values'] = dict(
        (k, v) for kk, v in indicator.get('values', {}).iteritems() for k in expand(kk)
    )

    if len(indicator.get('values')) > 0:
        indicator['re'] = '[{0}]'.format(''.join(
            set(indicator.get('values', {}).keys()) | set('#')
        ).replace('#', '_'))
    else:
        return {'re': '.'}
    return indicator

def reverse_indicator_dict(d):
    new_dict = {}
    for key, value in d.iteritems():
        if key == '#':
            key = '_'
        new_dict[value] = key

    return new_dict

@click.command()
@click.argument('source', type=click.File('r'))
@click.argument('template', type=click.File('r'))
@click.option('--re-fields', help='Regular expression to filter fields.')
def generate(source, template, re_fields=None):
    """Output rendered JSONAlchemy configuration."""
    re_fields = re.compile(re_fields) if re_fields else None
    data = [(code, value) for code, value in json.load(source).iteritems()
            if re_fields is None or re_fields.match(code)]
    tpl = Template(template.read())
    click.echo(tpl.render(
        data=sorted(data),
        clean_name=clean_name,
        get_indicator=get_indicator,
        reverse_indicator_dict=reverse_indicator_dict,
        tojson=tojson_filter,
        set=lambda *args, **kwargs: list(set(*args, **kwargs)),
    ))

if __name__ == '__main__':
    generate()
