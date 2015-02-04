{% macro clean_name(name) -%}
{{ name|lower()|replace(' ', '_')|replace(',', '_')|replace('/', '_')|replace('(', '')|replace(')', '')|replace('-', '_')|replace('.', '')|replace("'", '_') }}
{%- endmacro %}

{%- for tag, field in data.iteritems() if tag|length() == 3 %}

{{ clean_name(field.name) }}:
    """TODO."""
    schema:
        {'{{ clean_name(field.name) }}': {'type': '{{ 'list' if field.repeatable else 'dict' }}'}}
{%- endfor %}
