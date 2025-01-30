{% macro clonestaticdb() %}
    {% set create_db %}
        create or replace database TATGET_DB;
    {% endset %}
    {% do run_query(create_db) %}

    {% set create_schema %}
        create or replace schema TATGET_DB.TATGET_SCHEMA;
    {% endset %}
    {% do run_query(create_schema) %}
{% endmacro %}
-- dbt run-operation clonestaticdb 