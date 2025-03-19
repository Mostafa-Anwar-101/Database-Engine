
function drop_table() {
    pwd
    if [[ -z "$db_name" ]]; then
        zenity --error --title="Error" --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    tables=($(ls *.table 2>/dev/null | sed  sed 's/.table$//'))

    if [[ ${#tables[@]} -eq 0 ]]; then
        zenity --info --title="Info" --text="No tables found in database '$db_name'."
        return
    fi

    # Select table to drop
    table_name=$(zenity --list --title="Drop Table" --column="Tables" --width=500 --height=450 "${tables[@]}")

    if [[ -z "$table_name" ]]; then
        return  # User canceled
    fi

    # Confirm deletion
    zenity --question --title="Confirm Deletion" --text="Are you sure you want to delete table '$table_name'?"
    if [[ $? -ne 0 ]]; then
        return  # User declined
    fi

    # Delete table files
    rm -f "$table_name.table" "$table_name.data"

    zenity --info --title="Success" --text="Table '$table_name' dropped successfully."
}

