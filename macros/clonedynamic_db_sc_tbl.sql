{% macro clonedynamic_db_sc_tbl(src_db, src_sc, tgt_db, tgt_sc, tbl_list) %}
    {% set create_db %}
        create or replace database {{tgt_db}};
    {% endset %}
    {% do run_query(create_db) %}

    {% set create_schema %}
        create or replace schema {{tgt_db}}.{{tgt_sc}};
    {% endset %}
    {% do run_query(create_schema) %}
	
	{% for tbl in tbl_list %}
		{% set source_tbl= src_db~'.'~src_sc~'.'~tbl %}
		{% set target_tbl= tgt_db~'.'~tgt_sc~'.'~tbl %}

		{% set create_table %}
			create or replace table {{target_tbl}} clone {{source_tbl}};
		{% endset %}
		{% do run_query(create_table) %}
	
	{% endfor %}	
{% endmacro %}

-- dbt run-operation clonedynamic_db_sc_tbl --args "{'src_db':'TASTY_BYTES_SAMPLE_DATA', 'src_sc':'RAW_POS', 'tgt_db':'TATGET_DB', 'tgt_sc':'TATGET_SCHEMA', 'tbl_list':['T1','T2','T3']}" 