{% macro truncate_if_exists(model) %}
  {% set relation = model %}
  {% do log("Truncating table: " ~ relation, info=True) %}
  {{ return("truncate table " ~ relation) }}
{% endmacro %}
