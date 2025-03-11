{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='delete+insert',
    on_schema_change='sync_all_columns',
    tags=['scd_type_4']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('scd_type_4_src_qry') }}
),

existing_data AS (
    SELECT * FROM {{ this }}
    WHERE active_flag = 'Y'
),

changes_qry AS (
    SELECT src.*
    FROM source_data src
    LEFT JOIN existing_data hist
    ON src.ID = hist.ID
    WHERE src.ALL_HASH_KEY != COALESCE(hist.ALL_HASH_KEY, 'A')
)

-- Keep only the latest record in the main table
SELECT 
    ID, 
    NAME, 
    ADDRESS, 
    CRETED_DATE, 
    CRETED_DATE AS MODIFIED_DATE, 
    'Y' AS ACTIVE_FLAG, 
    BATCH_ID, 
    ALL_HASH_KEY 
FROM changes_qry
 QUALIFY ROW_NUMBER() OVER (PARTITION BY ID ORDER BY COALESCE(MODIFIED_DATE, CRETED_DATE) DESC) = 1
