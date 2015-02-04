import click
import json
import re

from jinja2 import Template


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
    click.echo(tpl.render(data=sorted(data)))

if __name__ == '__main__':
    generate()
