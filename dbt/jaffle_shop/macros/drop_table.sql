{%- macro drop_table(table_name) -%}
    {%- set drop_query -%}
        DROP TABLE IF EXISTS {{ table_name }} CASCADE
    {%- endset -%}
    {% do run_query(drop_query) %}
{%- endmacro -%}
