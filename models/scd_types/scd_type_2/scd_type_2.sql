{%- set business_key = md5_generation(['ID']) %}
{%- set data_model_columns = fromjson(var('entity_columns')).DATA.SCD_TYPE_2-%}
{%- set all_hash_key = md5_generation(data_model_columns, exclude=['ID']) -%}
{%- set full_hash_key = md5_generation(['BUSINESS_KEY','ALL_HASH_KEY'] ) -%}
{%- set src_data_model_columns_mapping = ["'Y' AS ACTIVE_FLAG", 'ID', 'NAME', 'ADDRESS', 'CRETED_DATE', 'NULL AS MODIFIED_DATE', 'BATCH_ID','ALL_HASH_KEY', 'BUSINESS_KEY','FULL_HASH_KEY','LOAD_DATE'] -%}
{%- set current_batch_id = var('batch_id') -%}
{{ config(
            materialized='incremental',
            unique_key="MD5(CONCAT(BUSINESS_KEY,ALL_HASH_KEY))",
            incremental_strategy='delete+insert',
            tags=['scd_type_2']
        )
}}

{% if is_incremental() %}
WITH
latest_source_data AS (
    SELECT 
        {{ select_columns_builder(data_model_columns, exclude=['BUSINESS_KEY','ALL_HASH_KEY','FULL_HASH_KEY','LOAD_DATE','BATCH_ID']) }}
        , {{ business_key }} as BUSINESS_KEY
        , {{ all_hash_key }} as ALL_HASH_KEY
        , MD5(CONCAT(BUSINESS_KEY, ALL_HASH_KEY )) as FULL_HASH_KEY
        , current_timestamp() as LOAD_DATE
        , {{ current_batch_id }} as BATCH_ID
    FROM {{ ref('scd_type_2_src_qry') }} source_data_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ID ORDER BY COALESCE(MODIFIED_DATE, CRETED_DATE) DESC) = 1
),

new_records AS (
    SELECT 
    {{ select_columns_builder(data_model_columns, exclude) }}
    FROM latest_source_data src
    WHERE NOT EXISTS (
        SELECT 1 
        FROM {{ this }} tgt
        WHERE src.ID = tgt.ID
          AND COALESCE(src.MODIFIED_DATE, src.CRETED_DATE) = COALESCE(tgt.MODIFIED_DATE, tgt.CRETED_DATE)
    )
),

existing_active_data AS (
    SELECT {{ select_columns_builder(data_model_columns) }} 
    FROM {{ this }}
    WHERE active_flag = 'Y'
),

changes_qry AS (
    SELECT src.*
    FROM new_records src
    LEFT JOIN existing_active_data tgt
    ON src.ID = tgt.ID
    WHERE src.ALL_HASH_KEY != COALESCE(tgt.ALL_HASH_KEY, 'A')
),

final_result AS (
    SELECT {{ select_columns_builder(data_model_columns, exclude=['ACTIVE_FLAG']) }}
        , 'Y' AS ACTIVE_FLAG
    FROM changes_qry

    UNION ALL
    SELECT {{ select_columns_builder(data_model_columns, exclude=['ACTIVE_FLAG']) }}
    , 'N' AS ACTIVE_FLAG
    FROM(
        SELECT TGT.*
        FROM existing_active_data tgt
        JOIN changes_qry changes
        ON changes.ID = tgt.ID
    )
)

SELECT {{ select_columns_builder(data_model_columns) }}
 FROM final_result
{% else %}
with source_data_raw as (
    SELECT {{ select_columns_builder(data_model_columns) }}
     FROM {{ ref('scd_type_2_src_qry') }} 
)
    select {{ select_columns_builder(data_model_columns) }}
    from source_data_raw
{% endif %}
 