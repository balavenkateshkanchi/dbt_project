{{ 
    config(
            materialized='ephemeral',
            tags=['scd_type_1']
          )
}}

with source_data as (
    SELECT * FROM VSCOM_LAKE.VSCOM_LAKE_SRC.SRC_scd_type_1
)
select *
from source_data
