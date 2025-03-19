
function list_tables() {
    pwd
    if [[ -z "$db_name" ]]; then
        zenity --error --title="Error" --text="No database selected. Use 'connectDatabase' first."
        return
    fi

    tables=($(ls *.table  | sed 's/.table$//'))


    if [[ ${#tables[@]} -eq 0 ]]; then
        zenity --info --title="List Tables" --text="No tables found in database '$db_name'."
        return
    fi

    zenity --list --title="Tables in $db_name" --column="Table Name" --width=500 --height=450 "${tables[@]}"
}
