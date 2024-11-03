{% macro source(source_name, table_name) %}

    {% do return(builtins.source(source_name, table_name).include(database=false)) %}

{% endmacro %}