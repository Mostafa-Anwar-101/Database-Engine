#!/usr/bin/bash

function update_table() {
    if [[ -z "$db_name" ]]; then
        zenity --error --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    table_name=$(zenity --entry --title="Update Table" --text="Enter table name:")
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

    pk_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$primary_key" ]]; then
            pk_index=$i
            break
        fi
    done

    condition_column=$(zenity --list --width=500 --height=450 --title="Select Condition Column" --text="Choose a column to filter by:" \
        --radiolist --column="Select" --column="Column" $(for col in "${columns[@]}"; do echo "FALSE $col"; done))

    if [[ -z "$condition_column" ]]; then
        zenity --error --text="No condition column selected."
        return
    fi

    condition_col_index=-1
    condition_col_type=""
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$condition_column" ]]; then
            condition_col_index=$i
            condition_col_type="${datatypes[$i]}"
            break
        fi
    done

    if [[ "$condition_col_index" -eq -1 ]]; then
        zenity --error --text="Column '$condition_column' not found in table."
        return
    fi

    if [[ "$condition_col_type" == "int" ]]; then
        operator=$(zenity --list --width=500 --height=450 --title="Select Operator" \
            --text="Choose comparison operator for '$condition_column':" \
            --radiolist --column="Select" --column="Operator" \
            TRUE "=" FALSE "!=" FALSE "<" FALSE ">" FALSE "<=" FALSE ">=")
    else
        operator="=" 
    fi

    if [[ -z "$operator" ]]; then
        return
    fi

    condition_value=$(zenity --entry --title="Select Condition Value" --text="Enter value for '$condition_column' $operator:")

    if [[ -z "$condition_value" ]]; then
        zenity --error --text="Condition value cannot be empty."
        return
    fi

    case "$condition_col_type" in
        "int")
            if [[ ! "$condition_value" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid input. '$condition_column' must be an integer."
                return
            fi
            condition_value=$((condition_value))
            ;;
        "string")
            if [[ ! "$condition_value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Invalid input. '$condition_column' must be a valid string (letters, numbers, underscores only)."
                return
            fi
            ;;
        *)
            zenity --error --text="Unsupported data type '$condition_col_type' for column '$condition_column'."
            return
            ;;
    esac

    update_column=$(zenity --list --width=500 --height=450 --title="Select Update Column" --text="Choose a column to update:" \
        --radiolist --column="Select" --column="Column" $(for col in "${columns[@]}"; do echo "FALSE $col"; done))

    if [[ -z "$update_column" ]]; then
        zenity --error --text="No update column selected."
        return
    fi

    update_col_index=-1
    update_col_type=""
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$update_column" ]]; then
            update_col_index=$i
            update_col_type="${datatypes[$i]}"
            break
        fi
    done

    if [[ "$update_col_index" -eq -1 ]]; then
        zenity --error --text="Column '$update_column' not found in table."
        return
    fi

    new_value=$(zenity --entry --title="Enter New Value" --text="Enter new value for '$update_column':")

    if [[ -z "$new_value" ]]; then
        zenity --error --text="New value cannot be empty."
        return
    fi

    case "$update_col_type" in
        "int")
            if [[ ! "$new_value" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid input. '$update_column' must be an integer."
                return
            fi
            new_value=$((new_value))
            ;;
        "string")
            if [[ ! "$new_value" =~ ^[a-zA-Z0-9_]+$ ]]; then
                zenity --error --text="Invalid input. '$update_column' must be a valid string (letters, numbers, underscores only)."
                return
            fi
            ;;
        *)
            zenity --error --text="Unsupported data type '$update_col_type' for column '$update_column'."
            return
            ;;
    esac

    if [[ "$update_col_index" -eq "$pk_index" ]]; then
        existing_pks=($(awk -F: -v pk_col=$((pk_index+1)) '{print $pk_col}' "$data_file"))
        for pk in "${existing_pks[@]}"; do
            if [[ "$pk" == "$new_value" ]]; then
                current_pk=$(awk -F: -v cond_col=$((condition_col_index+1)) -v cond_val="$condition_value" \
                    '$cond_col == cond_val {print $'$((pk_index+1))'}' "$data_file")
                if [[ "$pk" != "$current_pk" ]]; then
                    zenity --error --text="Primary key value '$new_value' already exists in the table."
                    return
                fi
            fi
        done
    fi

    temp_file=$(mktemp)
    updated=0
    while IFS=: read -r -a record; do
        match=false
        case "$operator" in
            "=") [[ "${record[$condition_col_index]}" == "$condition_value" ]] && match=true ;;
            "!=") [[ "${record[$condition_col_index]}" != "$condition_value" ]] && match=true ;;
            "<") (( record[$condition_col_index] < condition_value )) && match=true ;;
            ">") (( record[$condition_col_index] > condition_value )) && match=true ;;
            "<=") (( record[$condition_col_index] <= condition_value )) && match=true ;;
            ">=") (( record[$condition_col_index] >= condition_value )) && match=true ;;
        esac

        if $match; then
            record[$update_col_index]="$new_value"
            updated=$((updated + 1))
        fi
        echo "${record[*]}" | tr ' ' ':' >> "$temp_file"
    done < "$data_file"

    if [[ "$updated" -eq 0 ]]; then
        zenity --info --title="No Matching Records" --text="No records found where '$condition_column' $operator '$condition_value'."
        rm "$temp_file"
    else
        mv "$temp_file" "$data_file"
        zenity --info --title="Update Successful" --text="Updated $updated record(s) where '$condition_column' $operator '$condition_value'." --no-markup
    fi
}