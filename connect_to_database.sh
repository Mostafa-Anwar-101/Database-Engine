#!/usr/bin/bash

source utils.sh
source ./tables_menu.sh

connect_to_database() {
    local db_path="databases"

    if ! is_db_dir_exist "$db_path"; then
    zenity --error --text="No databases available to drop."
    return
    fi

    local db_list=()
    for db in "$db_path"/*; do
        [[ -d "$db" ]] && db_list+=("$(basename "$db")")
    done

    db_name=$(zenity --list --title="Connect to Database" --column="Databases" --width=500 --height=450 "${db_list[@]}")

    if [[ -n "$db_name" ]]; then
        zenity --info --text="Connected to database '$db_name'."
        cd "$db_path/$db_name" || exit
        tables_menu
    fi
}