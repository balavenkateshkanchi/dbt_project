 
 
{{ 
    config(
            materialized='ephemeral',
            tags=['scd_type_2']
          )
}}
select *,
MD5(CONCAT(NVL(ID,0)::VARCHAR,NVL(NAME,'N'),NVL(ADDRESS,'N'),CRETED_DATE::VARCHAR)) ALL_HASH_KEY
from TASTY_BYTES_SAMPLE_DATA.RAW_POS.SRC_scd_type_2 SRC_QRY