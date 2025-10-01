{% macro get_cols_from_table() -%}

    {% set query %}
        WITH TABLE_COLS AS (
            SELECT table_name,
                   array_agg(column_name) within group (order by ordinal_position) as column_list
              FROM {{source('INFORMATION_SRCS','COLUMNS')}}
             WHERE 
                   table_catalog = upper('{{ target.database }}')
               AND table_schema = upper('{{ target.schema }}')
             GROUP BY table_name
          )
          SELECT OBJECT_CONSTRUCT('DATA', OBJECT_AGG(TABLE_NAME, column_list)) AS columns
            FROM TABLE_COLS
    {% endset %}

    {% set res = run_query(query) %}
    {% set column_list = {} %}

    {% if execute %}
        {% set column_list = res.columns[0].values()[0] %}
        {{ return(column_list) }}
    {% endif %}
{%- endmacro %}