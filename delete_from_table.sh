#!/usr/bin/bash

function delete_from_table() {
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Delete From Table" --text="Enter table name:")
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
    datatypes=($(awk -F':' '/DataTypes:/ {for (i=2; i<=NF; i++) print $i}' "$metadata_file" | tr -d ' '))
    primary_key=$(awk -F':' '/PrimaryKey:/ {print $2}' "$metadata_file" | tr -d ' ')

    delete_option=$(zenity --list --width=500 --height=450 --title="Delete Option" --text="Choose how to select records to delete:" \
        --radiolist --column="Select" --column="Option" \
        TRUE "Delete by Primary Key" \
        FALSE "Delete with Condition")

    if [[ -z "$delete_option" ]]; then
        return
    fi

    if [[ "$delete_option" == "Delete by Primary Key" ]]; then
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
        if [[ $? -ne 0 || -z "$pk_value" ]]; then
            return
        fi

        pk_type="${datatypes[$pk_index]}"
        case "$pk_type" in
            "int")
                if [[ ! "$pk_value" =~ ^[0-9]+$ ]]; then
                    zenity --error --text="Invalid input. Primary key must be an integer."
                    return
                fi
                pk_value=$((pk_value))
                ;;
            "string")
                if [[ ! "$pk_value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                    zenity --error --text="Invalid input. Primary key must be a valid string."
                    return
                fi
                ;;
        esac

        temp_file=$(mktemp)
        found=0
        while IFS=: read -r -a record; do
            if [[ "${record[$pk_index]}" == "$pk_value" ]]; then
                found=1
            else
                echo "${record[*]}" | tr ' ' ':' >> "$temp_file"
            fi
        done < "$data_file"

        if [[ "$found" -eq 0 ]]; then
            zenity --error --text="Record with primary key '$pk_value' not found."
            rm -f "$temp_file"
        else
            mv "$temp_file" "$data_file"
            zenity --info --text="Record with primary key '$pk_value' deleted successfully."
        fi

    else
        column=$(zenity --list --width=500 --height=450 --title="Select Column" --text="Choose a column to filter by:" \
            --radiolist --column="Select" --column="Column" $(for col in "${columns[@]}"; do echo "FALSE $col"; done))

        if [[ -z "$column" ]]; then
            zenity --error --text="No column selected."
            return
        fi

        col_index=-1
        col_type=""
        for i in "${!columns[@]}"; do
            if [[ "${columns[$i]}" == "$column" ]]; then
                col_index=$i
                col_type="${datatypes[$i]}"
                break
            fi
        done

        if [[ "$col_index" -eq -1 ]]; then
            zenity --error --text="Column '$column' not found in table."
            return
        fi

        if [[ "$col_type" == "int" ]]; then
            operator=$(zenity --list --width=500 --height=450 --title="Select Operator" \
                --text="Choose comparison operator for '$column':" \
                --radiolist --column="Select" --column="Operator" \
                TRUE "=" FALSE "!=" FALSE "<" FALSE ">" FALSE "<=" FALSE ">=")
        else
            operator=$(zenity --list --width=500 --height=450 --title="Select Operator" \
                --text="Choose comparison operator for '$column':" \
                --radiolist --column="Select" --column="Operator" \
                TRUE "=" FALSE "!=")
        fi

        if [[ -z "$operator" ]]; then
            return
        fi

        value=$(zenity --entry --title="Delete Condition" --text="Enter value for '$column' $operator:")
        if [[ -z "$value" ]]; then
            zenity --error --text="Value cannot be empty."
            return
        fi

        case "$col_type" in
            "int")
                if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
                    zenity --error --text="Invalid input. '$column' must be an integer."
                    return
                fi
                value=$((value))
                ;;
            "string")
                if [[ ! "$value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                    zenity --error --text="Invalid input. '$column' must be a valid string."
                    return
                fi
                ;;
        esac

        temp_file=$(mktemp)
        deleted_count=0
        while IFS=: read -r -a record; do
            match=false
            case "$operator" in
                "=") [[ "${record[$col_index]}" == "$value" ]] && match=true ;;
                "!=") [[ "${record[$col_index]}" != "$value" ]] && match=true ;;
                "<") (( record[$col_index] < value )) && match=true ;;
                ">") (( record[$col_index] > value )) && match=true ;;
                "<=") (( record[$col_index] <= value )) && match=true ;;
                ">=") (( record[$col_index] >= value )) && match=true ;;
            esac

            if $match; then
                deleted_count=$((deleted_count + 1))
            else
                echo "${record[*]}" | tr ' ' ':' >> "$temp_file"
            fi
        done < "$data_file"

        if [[ "$deleted_count" -eq 0 ]]; then
            zenity --info --title="No Matching Records" --text="No records found where '$column' $operator '$value'."
            rm -f "$temp_file"
        else
            mv "$temp_file" "$data_file"
            message="Deleted $deleted_count records where '$column' $operator '$value'."
            zenity --info --title="Deletion Complete" --text="$message" --no-markup
        fi
    fi
}