{% macro log_batch_master(batch_id) %}
  --  {% set batch_id = run_started_at.strftime("%Y%m%d%H%M%S") %}

  -- Return SQL as string
  {{ return(
    "INSERT INTO VSCOM_DB.VSCOM_SC.batch_master (batch_id, run_started_at, run_by, run_env) "
    "VALUES ('" ~ batch_id ~ "', current_timestamp, '" ~ target.user ~ "', '" ~ target.name ~ "');"
  ) }}
{% endmacro %}

{% macro log_batch_details_start(batch_id) %}
  {{ return(
    "INSERT INTO VSCOM_DB.VSCOM_SC.batch_details (batch_id, model_name, model_schema, model_table, status, started_at) "
    "VALUES ('" ~ batch_id ~ "', '" ~ this.name ~ "', '" ~ this.schema ~ "', '" ~ this.identifier ~ "', 'STARTED', current_timestamp);"
  ) }}
{% endmacro %}

{% macro log_batch_details_end(batch_id, status='SUCCESS') %}
  {{ return(
    "UPDATE VSCOM_DB.VSCOM_SC.batch_details "
    "SET status = '" ~ status ~ "', ended_at = current_timestamp "
    "WHERE batch_id = '" ~ batch_id ~ "' AND model_name = '" ~ this.name ~ "';"
  ) }}
{% endmacro %}
