{% macro drop_relation(relation, relation_type, if_exists=True, cascade=True) %}

    {# 
        Custom drop_relation macro to fix improper relation name construction.
        This example assumes that the relation object has correct schema and name attributes.
    #}

    {% set relation_schema = relation.schema %}
    {% set relation_name = relation.name %}

    DROP TABLE IF EXISTS {{ adapter.quote(relation_schema) }}.{{ adapter.quote(relation_name) }}{{ ' CASCADE' if cascade else '' }}

{% endmacro %}