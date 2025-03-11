{{ 
    config(
        materialized='ephemeral',
        tags=['scd_type_4']
    )
}}

    SELECT 
        *, 
        MD5(CONCAT(COALESCE(ID, 0)::VARCHAR, COALESCE(NAME, 'N'), COALESCE(ADDRESS, 'N'), CRETED_DATE::VARCHAR)) AS ALL_HASH_KEY
    FROM TASTY_BYTES_SAMPLE_DATA.RAW_POS.SRC_scd_type_4
