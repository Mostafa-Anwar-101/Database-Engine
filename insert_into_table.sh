#!/usr/bin/bash

function insert_into_table() {
    pwd
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Insert Into Table" --text="Enter table name:")

    if [[ ! -f "$table_name.table" ]]; then
        zenity --error --text="Table '$table_name' does not exist."
        return
    fi

    metadata_file="$table_name.table"
    data_file="$table_name.data"

    # Extract metadata using AWK
    columns=($(awk -F': ' '/Columns:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file"))
    datatypes=($(awk -F': ' '/DataTypes:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file"))
    primary_key=$(awk -F': ' '/PrimaryKey:/ {print $2}' "$metadata_file" | tr -d ' ')

    # Read existing primary key values
    pk_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$primary_key" ]]; then
            pk_index=$i
            break
        fi
    done

    existing_pks=($(cut -d: -f$((pk_index + 1)) "$data_file"))

    # Insert new row
    row_values=()
    for i in "${!columns[@]}"; do
        while true; do
            value=$(zenity --entry --title="Insert Record" --text="Enter value for ${columns[$i]} (${datatypes[$i]}):")

            if [[ -z "$value" ]]; then
                zenity --error --text="Value cannot be empty!"
                continue
            fi

            # Validate Data Type
            if [[ "${datatypes[$i]}" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid input. ${columns[$i]} must be an integer."
                continue
            elif [[ "${datatypes[$i]}" == "string" && ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Invalid input. ${columns[$i]} must be a valid string (letters, numbers, underscores only)."
                continue
            fi

            # Check primary key uniqueness
            if [[ "$i" -eq "$pk_index" && " ${existing_pks[@]} " =~ " $value " ]]; then
                zenity --error --text="Error: Primary key '$value' already exists!"
                continue
            fi

            row_values+=("$value")
            break
        done
    done

    # Write data to file
    echo "${row_values[*]}" | tr ' ' ':' >> "$data_file"
    zenity --info --text="Record inserted successfully into '$table_name'."
}
