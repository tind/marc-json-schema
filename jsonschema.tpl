{%- macro render_object(field) -%}
    {%- set indicator1 = get_indicator(1, field) -%}
    {%- set indicator2 = get_indicator(2, field) -%}
    {%- if indicator1.get('name') %}
        "{{ indicator1['name'] }}": {
          {%- if indicator1.get('specified_in_subfield') %}
            "type": "string"
          {%- elif indicator1.get('name') == 'nonfiling_characters' %}
            "enum": {{ tojson(set(map(int_to_str, range(10)))) }}
          {%- else %}
            "enum": {{ tojson(set(map(int_to_str, indicator1.get('values', {}).values()))) }}
          {%- endif %}
        },
    {%- endif %}
    {%- if indicator2.get('name') %}
        "{{ indicator2['name'] }}": {
          {%- if indicator2.get('specified_in_subfield') %}
            "type": "string"
          {%- elif indicator2.get('name') == 'nonfiling_characters' %}
            "enum": {{ tojson(set(map(int_to_str, range(10)))) }}
          {%- else %}
            "enum": {{ tojson(set(map(int_to_str, indicator2.get('values', {}).values()))) }}
          {%- endif %}
        },
    {%- endif %}
    {%- for code, subfield in field.get('subfields').items() %}
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
