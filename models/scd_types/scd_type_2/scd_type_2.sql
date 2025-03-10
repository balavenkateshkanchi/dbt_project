{{ config(
            materialized='incremental',
            unique_key='all_hash_key',
            incremental_strategy='delete+insert',
            on_schema_change='sync_all_columns',
            tags=['scd_type_2']
        )
}}

{% if is_incremental() %}
WITH
latest_source_data AS (
    SELECT 
        *
    FROM {{ ref('scd_type_2_src_qry') }} source_data_raw
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ID ORDER BY COALESCE(MODIFIED_DATE, CRETED_DATE) DESC) = 1
),

new_records AS (
    SELECT *
    FROM latest_source_data src
    WHERE NOT EXISTS (
        SELECT 1 
        FROM VSCOMDB.VSCOM_SC.scd_type_2 tgt
        WHERE src.ID = tgt.ID
          AND COALESCE(src.MODIFIED_DATE, src.CRETED_DATE) = COALESCE(tgt.MODIFIED_DATE, tgt.CRETED_DATE)
    )
),

existing_active_data AS (
    SELECT * 
    FROM VSCOMDB.VSCOM_SC.scd_type_2 
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
    SELECT 
        ID, 
        NAME,
        ADDRESS,
        CRETED_DATE, 
        NULL AS MODIFIED_DATE, 
        'Y' AS ACTIVE_FLAG, 
        BATCH_ID, 
        ALL_HASH_KEY 
    FROM changes_qry

    UNION ALL

    SELECT 
        tgt.ID, 
        tgt.NAME,
        tgt.ADDRESS,
        tgt.CRETED_DATE, 
        changes.MODIFIED_DATE, 
        'N' AS ACTIVE_FLAG, 
        tgt.BATCH_ID, 
        tgt.ALL_HASH_KEY
    FROM existing_active_data tgt
    JOIN changes_qry changes
    ON changes.ID = tgt.ID
)

SELECT * FROM final_result
{% else %}
with source_data_raw as (
    SELECT * FROM {{ ref('scd_type_2_src_qry') }} 
)
    select * from source_data_raw
{% endif %}
 