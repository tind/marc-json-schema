{%- macro render_object(field) -%}
    {%- set indicator1 = get_indicator(1, field) -%}
    {%- set indicator2 = get_indicator(2, field) -%}
    {%- if indicator1.get('name') %}
        "{{ indicator1['name'] }}": {
            "enum": {{ tojson(set(indicator1.get('values', {}).values())) }}
        },
    {%- endif %}
    {%- if indicator2.get('name') %}
        "{{ indicator2['name'] }}": {
            "enum": {{ tojson(set(indicator2.get('values', {}).values())) }}
        },
    {%- endif %}
    {%- for code, subfield in field.get('subfields').iteritems() %}
      {%- if subfield.get('repeatable', False) %}
        "{{ clean_name(subfield['name']) }}": {
            "type": "array",
            "items": {
                "type": "string"
            }
        }{{ ',' if not loop.last }}
      {%- else %}
        "{{ clean_name(subfield['name']) }}": {
            "type": "string"
        }{{ ',' if not loop.last }}
      {%- endif %}
    {%- endfor %}
{%- endmacro -%}
{
    "type": "object",
    "properties": {
    {%- for tag, field in data if tag|length() == 3 %}
        {%- if 'subfields' in field %}
        "{{ clean_name(field.name) }}": {
            "description": "{{ field.name }}",
            {%- if field.repeatable %}
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    {{- render_object(field)|indent(12) }}
                }
            }
            {%- else %}
            "properties": {
                {{- render_object(field)|indent(8) }}
            }
            {%- endif %}
        }{{ ',' if not loop.last }}
        {%- else %}
        "{{ clean_name(field.name) }}": {
            "description": "{{ field.name }}",
            "type": "string"
        }{{ ',' if not loop.last }}
        {%- endif %}
    {%- endfor %}
    }
}
