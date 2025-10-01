{% macro select_columns_builder(columns, alias, exclude=[], include=[]) %}
    {% if execute %}
        {% set column_lst = columns + include %}
        {%- set final_cols  -%}
        {%- for col in column_lst -%}
            {%- if column_lst.index(col) == 0 and col not in exclude-%}
                {%- if alias -%}
                    {{ alias }}.{{ col }}
                {% else %}
                    {{ col }}
                {%- endif -%}
            {%- elif col not in exclude -%}
                {%- if alias -%}
                    , {{ alias }}.{{ col }}
                {% else %}
                    , {{ col }}
                {%- endif -%}
            {%- endif -%}
        {%- endfor -%}
        {%- endset -%}
    {% endif %}
    {{ return(final_cols) }} 
{% endmacro %}