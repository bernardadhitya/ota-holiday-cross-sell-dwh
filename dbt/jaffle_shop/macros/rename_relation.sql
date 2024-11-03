{% macro rename_relation(from_relation, to_relation) %}

    {# 
        Custom rename_relation macro to ensure the backup table is dropped before renaming.
        This prevents conflicts when the backup table already exists.
    #}

    -- Drop the target backup table if it exists
    {% if to_relation.exists %}
        {% if adapter.get_relation(to_relation.database, to_relation.schema, to_relation.identifier) %}
            DROP TABLE IF EXISTS {{ adapter.quote(to_relation) }} CASCADE;
        {% endif %}
    {% endif %}

    -- Proceed to rename the original table to the backup name
    ALTER TABLE {{ adapter.quote(from_relation) }} RENAME TO {{ adapter.quote(to_relation.identifier) }};

{% endmacro %}
