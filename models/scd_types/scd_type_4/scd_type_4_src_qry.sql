{%- set all_hash_key = md5_generation(['ID','NAME','ADDRESS'] ) -%}
{{ 
    config(
        materialized='ephemeral',
        tags=['scd_type_4']
    )
}}

    SELECT 
        *
        -- , {{ all_hash_key }} as ALL_HASH_KEY
    FROM 
    {{source('VSCOM_LAKE_SRC','SRC_SCD_TYPE_4')}}
    WHERE ALL_HASH_KEY NOT IN (SELECT ALL_HASH_KEY FROM {{source('VSCOM_DB_SRC','SCD_TYPE_4_HISTORY')}} M)