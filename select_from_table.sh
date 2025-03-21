#!/usr/bin/bash

function select_from_table() {
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Select From Table" --text="Enter table name:")
    if [[ $? -ne 0 || -z "$table_name" ]]; then
        return
    fi

    metadata_file="$table_name.table"
    data_file="$table_name.data"

    if [[ ! -f "$metadata_file" ]]; then
        zenity --error --text="Table '$table_name' does not exist."
        return
    fi

    columns=($(awk -F':' '/Columns:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file" | tr -d ' '))

    choice=$(zenity --list --title="Select Option" --text="Choose a select option:" \
        --radiolist --column="Select" --column="Option" TRUE "Select All" FALSE "Select With Condition")

    if [[ -z "$choice" ]]; then
        return
    fi

    if [[ "$choice" == "Select All" ]]; then
        display_html_table "$table_name" "${columns[@]}"
   
   elif [[ "$choice" == "Select With Condition" ]]; then

        column=$(zenity --list --title="Select Column" --text="Choose a column to filter by:" \
            --radiolist --column="Select" --column="Column" $(for col in "${columns[@]}"; do echo "FALSE $col"; done))

        if [[ -z "$column" ]]; then
            zenity --error --text="No column selected."
            return
        fi

        col_index=-1
        for i in "${!columns[@]}"; do
            if [[ "${columns[$i]}" == "$column" ]]; then
                col_index=$i
                break
            fi
        done

        if [[ "$col_index" -eq -1 ]]; then
            zenity --error --text="Column '$column' not found in table."
            return
        fi

        
        value=$(zenity --entry --title="Select Condition" --text="Enter value for '$column':")

        if [[ -z "$value" ]]; then
            zenity --error --text="Value cannot be empty."
            return
        fi

        display_filtered_html_table "$table_name" "${columns[@]}" "$column" "$value"

    else
        zenity --error --text="Invalid selection."
        return
    fi
}

