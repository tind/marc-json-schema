import click
import json
import re

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
    name = name.replace('__', '_')
    return name

def get_indicator(possition, field):
    indicators = field.get('indicators', {})
    possition = str(possition)
    if not possition in indicators:
        return {'re': '.'}

    indicator = indicators[possition]
    if indicator['name'] == 'Undefined' or clean_name(indicator['name']) in [
            'source_of_code', 'number_source', 'code_source', 'type_of_address',
            'source_of_term', 'access_method', 'same_as_associated_field', 'same_as_associated_field']:
        return {'re': '.'}

    indicator['name'] = clean_name(indicator['name'])
    indicator['values'] = dict(
        (k, v) for k, v in indicator.get('values', {}).iteritems()
        if '-' not in k
    )
    if len(indicator.get('values')) > 0:
        indicator['re'] = '[{0}]'.format(''.join(
            indicator.get('values', {}).keys()).replace('#', '.'))
    else:
        return {'re': '.'}
    return indicator



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
    ))

if __name__ == '__main__':
    generate()