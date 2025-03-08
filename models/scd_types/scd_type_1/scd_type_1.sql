{{ config(
            materialized='incremental',
            unique_key='id',
            incremental_strategy='delete+insert',
            on_schema_change='sync_all_columns',
            tags=['scd_type_1']
        )
}}
select *
from {{ ref('scd_type1_src_qry') }} source_data

{% if is_incremental() %}
    where source_data.CRETED_DATE > (select nvl((select max(CRETED_DATE) from {{ this }}),'0000-01-31'::timestamp))
{% endif %}
