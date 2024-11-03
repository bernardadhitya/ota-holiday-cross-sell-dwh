{% macro cleanup_backup_table() %}
    {# 
        This macro drops backup and temporary tables for the current model if they exist.
        Backup tables have the suffix '__dbt_backup'.
        Temporary tables have the suffix '__dbt_tmp'.
    #}

    {% set suffixes = ['__dbt_backup', '__dbt_tmp'] %}
    {% set drop_statements = [] %}

    {% for suffix in suffixes %}
        {% set table_name = this.identifier ~ suffix %}

        {% set drop_sql = "DROP TABLE IF EXISTS " ~ this.schema ~ "." ~ table_name ~ " CASCADE;" %}
        {% do log("Dropping existing table: " ~ this.schema ~ "." ~ table_name, info=True) %}
        {% do drop_statements.append(drop_sql) %}
    {% endfor %}

    {{ drop_statements | join('\n') }}
{% endmacro %}
