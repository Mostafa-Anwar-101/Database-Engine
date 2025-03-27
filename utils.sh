#!/usr/bin/bash

Back_to_main_menu(){
    cd ../..
    main_menu
}

function is_db_dir_exist() {
    local db_path="$1"

    if [[ ! -d "$db_path" || -z "$(ls -A "$db_path")" ]]; then
        return 1
    else
        return 0
    fi
}

function exit_program(){
            pacMan "....Exiting....  " 0.05 "."
            echo "Thanks for using our Database Engine "
            exit
}

function display_html_table() {
    local table_name="$1"
    local columns=("${@:2}")
    local data_file="$table_name.data"
    local html_file="/tmp/${table_name}_output.html"

    echo "<html><head><title>$table_name Data</title>" > "$html_file"
    echo "<style>
            body { font-family: Arial, sans-serif; margin: 20px; text-align: center; }
            table { width: 80%; margin: auto; border-collapse: collapse; }
            th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
            th { background-color: #4CAF50; color: white; }
            tr:nth-child(even) { background-color: #f2f2f2; }
            tr:hover { background-color: #ddd; }
          </style>
          </head><body>" >> "$html_file"

    echo "<h2>Records in Table: $table_name</h2>" >> "$html_file"
    echo "<table><tr>" >> "$html_file"

    for col in "${columns[@]}"; do
        echo "<th>$col</th>" >> "$html_file"
    done
    echo "</tr>" >> "$html_file"

    while IFS=: read -r -a row; do
        echo "<tr>" >> "$html_file"
        for cell in "${row[@]}"; do
            echo "<td>$cell</td>" >> "$html_file"
        done
        echo "</tr>" >> "$html_file"
    done < "$data_file"

    echo "</table></body></html>" >> "$html_file"

    xdg-open "$html_file"
}

function display_filtered_html_table() {
    local table_name="$1"
    shift
    local -a columns=("$@")

    local value="${columns[@]: -1}"
    unset 'columns[-1]'     

    local operator="${columns[@]: -1}"
    unset 'columns[-1]'     

    local column="${columns[@]: -1}"
    unset 'columns[-1]'            

    local data_file="$table_name.data"
    local html_file="/tmp/${table_name}_filtered.html"

    local col_index=-1
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$column" ]]; then
            col_index=$i
            break
        fi
    done

    if [[ "$col_index" -eq -1 ]]; then
        zenity --error --text="Column '$column' not found."
        return
    fi

    echo "<html><head><title>Filtered Records</title>" > "$html_file"
    echo "<style>
            body { font-family: Arial, sans-serif; margin: 20px; text-align: center; }
            table { width: 80%; margin: auto; border-collapse: collapse; }
            th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
            th { background-color: #007BFF; color: white; }
            tr:nth-child(even) { background-color: #f9f9f9; }
            tr:hover { background-color: #f1f1f1; }
          </style>
          </head><body>" >> "$html_file"

    echo "<h2>Records where $column $operator $value</h2>" >> "$html_file"
    echo "<table><tr>" >> "$html_file"

    for col in "${columns[@]}"; do
        echo "<th>$col</th>" >> "$html_file"
    done
    echo "</tr>" >> "$html_file"

    local found_records=0
    while IFS=: read -r -a row; do
        match=false
        case "$operator" in
            "=") [[ "${row[$col_index]}" == "$value" ]] && match=true ;;
            "!=") [[ "${row[$col_index]}" != "$value" ]] && match=true ;;
            "<") (( row[$col_index] < value )) && match=true ;;
            ">") (( row[$col_index] > value )) && match=true ;;
            "<=") (( row[$col_index] <= value )) && match=true ;;
            ">=") (( row[$col_index] >= value )) && match=true ;;
        esac

        if $match; then
            echo "<tr>" >> "$html_file"
            for cell in "${row[@]}"; do
                echo "<td>$cell</td>" >> "$html_file"
            done
            echo "</tr>" >> "$html_file"
            found_records=1
        fi
    done < "$data_file"

    echo "</table></body></html>" >> "$html_file"

    if [[ "$found_records" -eq 0 ]]; then
        zenity --info --title="No Matching Records" --text="No records found where '$column' $operator '$value'."
    else
        xdg-open "$html_file"
    fi
}

function pacMan() {
    local string="${1}"
    local interval="${2}"
    : "${interval:=0.2}"
    local pad="${3}"
    : "${pad:=.}"
    local length=${#string}
    local padding=""

    # Hide the cursor
    tput civis

    # Save the current cursor position (row and column)
    cursor_row=$(tput lines)
    cursor_col=0

    for ((i = 0; i <= length; i++)); do
        # Move the cursor to the saved position
        tput cup $cursor_row $cursor_col

        # Print the current frame with padding
        echo -n "${padding}c${string:i:length}"
        sleep "$interval"

        # Move the cursor back to the saved position
        tput cup $cursor_row $cursor_col

        # Print the next frame with padding
        echo -n "${padding}C${string:i:length}"
        sleep "$interval"

        # Increase the padding for the next iteration
        padding+="${pad}"
    done

    # Restore the cursor visibility
    tput cnorm

    # Move to the next line after the animation completes
    echo
}