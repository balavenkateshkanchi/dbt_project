/*
{%- set business_key = md5_generation(['ID']) %}
{%- set data_model_columns = fromjson(var('entity_columns')).DATA.SCD_TYPE_4_HISTORY-%}
{%- set all_hash_key = md5_generation(data_model_columns, exclude=['ID']) -%}
{%- set full_hash_key = md5_generation(['BUSINESS_KEY','ALL_HASH_KEY'] ) -%}
{%- set src_data_model_columns_mapping = ["'Y' AS ACTIVE_FLAG", 'ID', 'NAME', 'ADDRESS', 'CRETED_DATE', 'NULL AS MODIFIED_DATE', 'BATCH_ID','ALL_HASH_KEY', 'BUSINESS_KEY','FULL_HASH_KEY','LOAD_DATE'] -%}
{%- set current_batch_id = var('batch_id') -%}
*/
{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='append',
    on_schema_change='sync_all_columns',
    tags=['scd_type_4']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('scd_type_4_main_records') }}
)
-- Append old records to the history table
SELECT 
        ID,
       NAME,
       ADDRESS,
       CRETED_DATE,
       MODIFIED_DATE,
       ACTIVE_FLAG,
       BATCH_ID,
       ALL_HASH_KEY,
       BUSINESS_KEY,
       FULL_HASH_KEY,
       LOAD_DATE
FROM source_data
