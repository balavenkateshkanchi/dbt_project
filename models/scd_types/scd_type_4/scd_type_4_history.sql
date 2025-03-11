{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='append',
    on_schema_change='sync_all_columns',
    tags=['scd_type_4']
) }}

WITH source_data AS (
    SELECT * FROM {{ ref('scd_type_4_src_qry') }}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY ID ORDER BY COALESCE(MODIFIED_DATE, CRETED_DATE) DESC) = 1
),

existing_data AS (
    SELECT * FROM vscomdb.vscom_sc.scd_type_4_main_records
    WHERE ACTIVE_FLAG = 'Y'
),

historical_changes AS (
    SELECT hist.*
    FROM existing_data hist
    JOIN source_data src
    ON src.ID = hist.ID
    WHERE src.ALL_HASH_KEY != COALESCE(hist.ALL_HASH_KEY, 'A')
)

-- Append old records to the history table
SELECT 
    ID, 
    NAME, 
    ADDRESS, 
    CRETED_DATE, 
    CURRENT_TIMESTAMP()::timestamp AS MODIFIED_DATE, 
    'N' AS ACTIVE_FLAG, 
    BATCH_ID, 
    ALL_HASH_KEY
FROM historical_changes
