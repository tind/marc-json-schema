# -*- coding: utf-8 -*-
#
# This file is part of DoJSON
# Copyright (C) 2015 CERN.
#
# DoJSON is free software; you can redistribute it and/or
# modify it under the terms of the Revised BSD License; see LICENSE
# file for more details.

"""To MARC 21 model definition."""

from dojson import utils

from ..model import to_marc21

{%- for tag, field in data if tag|length() == 3 %}
{%- if 'subfields' in field %}

{%- set indicator1 = get_indicator(1, field) %}
{%- set indicator2 = get_indicator(2, field) %}


@to_marc21.over('{{ tag }}', '^{{ clean_name(field.name) }}$')
{%- if field.repeatable %}
@utils.reverse_for_each_value
{%- endif %}
@utils.filter_values
def reverse_{{ clean_name(field.name) }}(self, key, value):
    """Reverse - {{ field.name }}."""
    {%- if indicator1.get('name') %}
    indicator_map1 = {{ tojson(reverse_indicator_dict(indicator1.get('values', {}))) }}
    {%- endif %}
    {%- if indicator2.get('name') %}
    indicator_map2 = {{ tojson(reverse_indicator_dict(indicator2.get('values', {}))) }}
    {%- endif %}
    return {
    {%- for code, subfield in field.get('subfields').iteritems() %}
      {%- if subfield.get('repeatable', False) %}
        '{{ code }}': utils.reverse_force_list(
            value.get('{{ clean_name(subfield['name']) }}')
        ),
      {%- else %}
        '{{ code }}': value.get('{{ clean_name(subfield['name']) }}'),
      {%- endif %}
    {%- endfor %}
    {%- if indicator1.get('name') %}
        '$ind1': indicator_map1.get(value.get('{{ indicator1['name'] }}'), '_'),
    {%- else %}
        '$ind1': '_',
    {%- endif %}
    {%- if indicator2.get('name') %}
        '$ind2': indicator_map2.get(value.get('{{ indicator2['name'] }}'), '_'),
    {%- else %}
        '$ind2': '_',
    {%- endif %}
    }
{%- else %}


@to_marc21.over('{{ tag }}', '^{{ clean_name(field.name) }}$')
def reverse_{{ clean_name(field.name) }}(self, key, value):
    """Reverse - {{ field.name }}."""
    return [value]
{%- endif %}
{%- endfor %}
