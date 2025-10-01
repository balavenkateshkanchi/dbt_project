{%- set data_model_columns = fromjson(var('entity_columns')).DATA.SCD_TYPE_4_MAIN_RECORDS-%}
{%- set current_batch_id = var('batch_id') -%}

{{ config(
    materialized='incremental',
    unique_key='FULL_HASH_KEY',
    incremental_strategy='delete+insert',
    on_schema_change='sync_all_columns'
) }}

WITH source_data AS (
    SELECT  {{ select_columns_builder(data_model_columns, exclude=['BUSINESS_KEY','ALL_HASH_KEY','FULL_HASH_KEY','LOAD_DATE','BATCH_ID','MODIFIED_DATE']) }},
           MD5(ID) AS BUSINESS_KEY,
           MD5(CONCAT(ID, '-', NAME, '-', ADDRESS)) AS ALL_HASH_KEY,
           MD5(CONCAT(MD5(ID), MD5(CONCAT(ID, '-', NAME, '-', ADDRESS)))) AS FULL_HASH_KEY,
           CURRENT_TIMESTAMP()::DATETIME AS LOAD_DATE,
           CURRENT_TIMESTAMP()::DATETIME AS MODIFIED_DATE,
           {{ current_batch_id }} as BATCH_ID
    FROM {{ source('VSCOM_LAKE_SRC','SRC_SCD_TYPE_4') }}
),

-- Incremental filter: only new or changed records
filtered_source AS (
    SELECT *
    FROM source_data
    {% if is_incremental() %}
        WHERE FULL_HASH_KEY NOT IN (
            SELECT FULL_HASH_KEY
            FROM {{ this }}
        )
    {% endif %}
),

-- Keep only latest record per business key
hash_gen AS (
    SELECT *
    FROM filtered_source
    QUALIFY ROW_NUMBER() OVER (PARTITION BY BUSINESS_KEY ORDER BY LOAD_DATE DESC) = 1
)
SELECT *
FROM hash_gen