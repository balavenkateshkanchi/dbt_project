
{{ 
    config(
            materialized='ephemeral',
            tags=['scd_type_1']
          )
}}

with source_data as (
    SELECT * FROM TASTY_BYTES_SAMPLE_DATA.RAW_POS.SRC_scd_type_1
)
select *
from source_data
