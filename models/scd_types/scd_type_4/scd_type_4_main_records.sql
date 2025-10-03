{%- set data_model_columns = fromjson(var('entity_columns')).DATA.SCD_TYPE_4_MAIN_RECORDS-%}
{%- set current_batch_id = var('batch_id') -%}
{%- set all_hash_key = md5_generation(['ID','NAME','ADDRESS'] ) -%}

{{ 
    config(
        materialized='incremental',
        unique_key='all_hash_key',
        incremental_strategy='delete+insert',
        pre_hook="{{ truncate_if_exists(this) }}",
        tags=['scd_type_4']
    )
}}



 
WITH source_data AS (
    SELECT  {{ select_columns_builder(data_model_columns, exclude=['BUSINESS_KEY','ALL_HASH_KEY','FULL_HASH_KEY','LOAD_DATE','BATCH_ID','MODIFIED_DATE']) }},
           MD5(ID) AS BUSINESS_KEY,
           {{ all_hash_key }} AS ALL_HASH_KEY,
           MD5(CONCAT(MD5(ID), MD5(CONCAT(ID, '-', NAME, '-', ADDRESS)))) AS FULL_HASH_KEY,
           CURRENT_TIMESTAMP()::DATETIME AS LOAD_DATE,
           CURRENT_TIMESTAMP()::DATETIME AS MODIFIED_DATE,
           {{ current_batch_id }} as BATCH_ID
    FROM {{ref('scd_type_4_src_qry')}}
        -- {{ source('VSCOM_LAKE_SRC','SRC_SCD_TYPE_4') }}
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
SELECT ID,
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
FROM hash_gen
{% if is_incremental() %}
    WHERE ALL_HASH_KEY NOT IN (SELECT ALL_HASH_KEY FROM {{source('VSCOM_DB_SRC','SCD_TYPE_4_HISTORY')}})
{% endif %}