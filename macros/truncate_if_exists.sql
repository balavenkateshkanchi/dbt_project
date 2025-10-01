{% macro truncate_if_exists(model) %}
  {% set relation = model %}
  {% if execute %}
    {% do log("Truncating table: " ~ relation, info=True) %}
    {% set sql %}
      truncate table {{ relation }}
    {% endset %}
    {{ run_query(sql) }}
  {% endif %}
{% endmacro %}
