#!/usr/bin/bash

function delete_from_table() {
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Delete From Table" --text="Enter table name:")
    if [ $? -eq 1 ]; then
        return
    fi

    metadata_file="$table_name.table"
    data_file="$table_name.data"

    if [[ ! -f "$metadata_file" ]]; then
        zenity --error --text="Table '$table_name' does not exist."
        return
    fi

    columns=($(awk -F':' '/Columns:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file" | tr -d ' '))
    primary_key=$(awk -F':' '/PrimaryKey:/ {print $2}' "$metadata_file" | tr -d ' ')

    pk_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$primary_key" ]]; then
            pk_index=$i
            break
        fi
    done

    if [[ "$pk_index" -eq -1 ]]; then
        zenity --error --text="Primary key column '$primary_key' not found in table."
        return
    fi

    pk_value=$(zenity --entry --title="Delete Record" --text="Enter the primary key value of the record to delete:")
    if [ $? -eq 1 ]; then
        return
    fi

    if [[ -z "$pk_value" ]]; then
        zenity --error --text="Primary key value cannot be empty!"
        return
    fi

    temp_file=$(mktemp)
    found=0
    while IFS=: read -r -a record; do
        if [[ "${record[$pk_index]}" == "$pk_value" ]]; then
            found=1
            zenity --info --text="Record with primary key '$pk_value' deleted successfully."
        else
            echo "${record[*]}" | tr ' ' ':' >> "$temp_file"
        fi
    done < "$data_file"

    if [[ "$found" -eq 0 ]]; then
        zenity --error --text="Record with primary key '$pk_value' not found."
        rm -f "$temp_file"
    else
        mv "$temp_file" "$data_file"
    fi
}