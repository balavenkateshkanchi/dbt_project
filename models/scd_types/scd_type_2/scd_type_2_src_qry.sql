 
 
{{ 
    config(
            materialized='ephemeral',
            tags=['scd_type_2']
          )
}}
select *
-- MD5(CONCAT(NVL(ID,0)::VARCHAR,NVL(NAME,'N'),NVL(ADDRESS,'N'),CRETED_DATE::VARCHAR)) ALL_HASH_KEY
from {{source('VSCOM_LAKE_SRC','SRC_SCD_TYPE_2')}} SRC_QRY