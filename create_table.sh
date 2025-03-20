#!/usr/bin/bash

function create_table() {
    
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    zenity --info --text="Current database: '$db_name'"

    table_name=$(zenity --entry --title="Create Table" --text="Enter table name:")

    if [[ ! "$table_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        zenity --error --text="Invalid table name. Must start with a letter and contain only letters, numbers, or underscores."
        return
    fi

    if [[ -f "$table_name.table" ]]; then
        zenity --error --text="Table '$table_name' already exists."
        return
    fi

    declare -a columns
    declare -a datatypes

    while true; do
        column_name=$(zenity --entry --title="Add Column" --text="Enter column name (or type 'done' to finish):")

        if [[ "$column_name" == "done" ]]; then
            if [[ ${#columns[@]} -eq 0 ]]; then
                zenity --error --text="Table must have at least one column."
                continue
            fi
            break
        fi

        if [[ ! "$column_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            zenity --error --text="Invalid column name. Use only letters, numbers, and underscores."
            continue
        fi

        if [[ " ${columns[@]} " =~ " $column_name " ]]; then
            zenity --error --text="Column '$column_name' already exists."
            continue
        fi

        data_type=$(zenity --list --title="Select Data Type" --text="Choose a data type for '$column_name':" \
            --radiolist --column="Select" --column="Type" TRUE "int" FALSE "string")

        if [[ -z "$data_type" ]]; then
            zenity --error --text="Invalid data type. Choose 'int' or 'string'."
            continue
        fi

        columns+=("$column_name:")
        datatypes+=("$data_type:")
    done

    primary_key=$(zenity --list --title="Primary Key Selection" --text="Select a primary key from the columns:" \
        --radiolist --column="Select" --column="Column Name" $(for col in "${columns[@]}"; do echo "FALSE $col"; done))

    if [[ -z "$primary_key" ]]; then
        zenity --error --text="Invalid primary key. Choose from the listed columns."
        return
    fi

    {
        echo "Columns: ${columns[@]}"
        echo "DataTypes: ${datatypes[@]}"
        echo "PrimaryKey: $primary_key"
    } > "$table_name.table"

    # Create actual data file
    touch "$table_name.data"

    zenity --info --text="Table '$table_name' created successfully in database '$db_name'."
}


