# -*- coding: utf-8 -*-
#
# This file is part of DoJSON
# Copyright (C) 2015 CERN.
#
# DoJSON is free software; you can redistribute it and/or
# modify it under the terms of the Revised BSD License; see LICENSE
# file for more details.

"""MARC 21 model definition."""

from dojson import utils

from ..model import marc21

{%- for tag, field in data if tag|length() == 3 %}
{%- if 'subfields' in field %}

{%- set indicator1 = get_indicator(1, field) %}
{%- set indicator2 = get_indicator(2, field) %}


@marc21.over('{{ clean_name(field.name) }}', '^{{ tag }}{{ indicator1['re'] }}{{ indicator2['re'] }}')
{%- if field.repeatable %}
@utils.for_each_value
{%- endif %}
@utils.filter_values
def {{ clean_name(field.name) }}(self, key, value):
    """{{ field.name }}."""
    {%- if indicator1.get('name') %}
    indicator_map1 = {{ tojson(indicator1.get('values', {})) }}
    {%- endif %}
    {%- if indicator2.get('name') %}
    indicator_map2 = {{ tojson(indicator2.get('values', {})) }}
    {%- endif %}
    return {
    {%- for code, subfield in field.get('subfields').iteritems() %}
      {%- if subfield.get('repeatable', False) %}
        '{{ clean_name(subfield['name']) }}': utils.force_list(
            value.get('{{ code }}')
        ),
      {%- else %}
        '{{ clean_name(subfield['name']) }}': value.get('{{ code }}'),
      {%- endif %}
    {%- endfor %}
    {%- if indicator1.get('name') %}
        '{{ indicator1['name'] }}': indicator_map1.get(key[3]),
    {%- endif %}
    {%- if indicator2.get('name') %}
        '{{ indicator2['name'] }}': indicator_map2.get(key[4]),
    {%- endif %}
    }
{%- else %}


@marc21.over('{{ clean_name(field.name) }}', '^{{ tag }}')
def {{ clean_name(field.name) }}(self, key, value):
    """{{ field.name }}."""
    return value[0]
{%- endif %}
{%- endfor %}
