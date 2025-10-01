{%- set business_key = md5_generation(['ID']) %}
{%- set data_model_columns = fromjson(var('entity_columns')).DATA.SCD_TYPE_1-%}
{%- set all_hash_key = md5_generation(data_model_columns, exclude=['ID']) -%}
{%- set full_hash_key = md5_generation(['BUSINESS_KEY','ALL_HASH_KEY'] ) -%}
{%- set src_data_model_columns_mapping = ['ID', 'NAME', 'ADDRESS', 'CRETED_DATE', 'NULL AS MODIFIED_DATE', 'BATCH_ID','ALL_HASH_KEY', 'BUSINESS_KEY','FULL_HASH_KEY','LOAD_DATE'] -%}

{%- set current_batch_id = var('batch_id') -%}

{{ config(
            materialized='incremental',
            unique_key='id',
            incremental_strategy='delete+insert',
            on_schema_change='sync_all_columns',
            tags=['scd_type_1']
        )
}}
select 
{{ select_columns_builder(data_model_columns, exclude=['BUSINESS_KEY','ALL_HASH_KEY','FULL_HASH_KEY','LOAD_DATE','MODIFIED_DATE','BATCH_ID']) }}
        , {{ business_key }} as BUSINESS_KEY
        , {{ all_hash_key }} as ALL_HASH_KEY
        , MD5(CONCAT(BUSINESS_KEY, ALL_HASH_KEY )) as FULL_HASH_KEY
        , current_timestamp()::DATETIME as LOAD_DATE
        , current_timestamp()::DATETIME as MODIFIED_DATE
        , {{ current_batch_id }} as BATCH_ID
from {{ ref('scd_type1_src_qry') }} source_data

{% if is_incremental() %}
    where source_data.CRETED_DATE > (select nvl((select max(CRETED_DATE) from {{ this }}),'0000-01-31'::timestamp))
{% endif %}
