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
    name = name.replace('__', '_')
    return name


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
    click.echo(tpl.render(data=sorted(data), clean_name=clean_name))

if __name__ == '__main__':
    generate()
