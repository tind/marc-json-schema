{% macro clean_name(name) -%}
{{ name|lower()|replace(' ', '_')|replace(',', '_')|replace('/', '_')|replace('(', '')|replace(')', '')|replace('-', '_')|replace('.', '')|replace("'", '_') }}
{%- endmacro %}

{%- for tag, field in data.iteritems() if tag|length() == 3 %}

{%- if 'subfields' in field %}
@extend
{{ clean_name(field.name) }}:
    creator:
        @legacy((('{{ tag }}', '{{ tag }}__', '{{ tag}}__%'), ''),
        {%- for code, subfield in field.get('subfields').iteritems() %}
                ('{{ tag }}__{{ code }}', '{{ clean_name(subfield['name']) }}'){{ ')' if loop.last else ',' }}
        {%- endfor %}
        marc, '{{ tag }}..', {
        {%- for code, subfield in field.get('subfields').iteritems() -%}
            '{{ clean_name(subfield['name']) }}': value['{{ code }}']{{ '' if loop.last else ', ' }}
        {%- endfor -%}}
    producer:
        json_for_marc(), {
        {%- for code, subfield in field.get('subfields').iteritems() -%}
            '{{ tag }}__{{ code }}': '{{ clean_name(subfield['name']) }}'{{ '' if loop.last else ', ' }}
        {%- endfor -%}}
{%- endif %}
{%- endfor %}
