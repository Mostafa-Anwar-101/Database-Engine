#!/usr/bin/bash

function select_from_table() {
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Select From Table" --text="Enter table name:")
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
    datatypes=($(awk -F':' '/DataTypes:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file" | tr -d ' '))

    choice=$(zenity --list --title="Select Option" --text="Choose a select option:" \
        --radiolist --column="Select" --column="Option" TRUE "Select All" FALSE "Select With Condition")

    if [[ "$choice" == "Select All" ]]; then
        display_html_table "$table_name" "${columns[@]}"
   
    fi
}