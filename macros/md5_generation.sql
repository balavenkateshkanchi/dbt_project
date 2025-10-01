{%- macro md5_generation(column_names_list, exclude=[]) -%}

    {%- set default_null_value = '_dbt_utilssurrogate_key_null_' -%}

    {%- set fields = [] -%}

    {%- set  filtered_columns_list = [] -%}

    {%- set exclude_column_names_list = exclude + var('md5_exclude_list') -%}

    {%- for col in column_names_list -%}

        {%- if col not in exclude_column_names_list -%}
            {%- do filtered_columns_list.append(col) -%}
        {%- endif -%}

    {%- endfor -%}

    {%- for col in filtered_columns_list -%}

        {%- do fields.append(
            "coalesce(cast(" ~ col ~ " as " ~ dbt.type_string() ~ "), '" ~ default_null_value ~ "')"
        ) -%}

        {%- if not loop.last %}
            {%- do fields.append("'-'") -%}
        {%- endif %}

    {%- endfor -%}

    {{ dbt.hash(dbt.concat(fields)) }}

{%- endmacro -%}