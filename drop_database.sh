#!/usr/bin/bash
source utils.sh

drop_database() {
    local db_path="databases"

   if ! is_db_dir_exist "$db_path"; then
    zenity --error --text="No databases available to drop."
    return
    fi

    local db_list=()
    for db in "$db_path"/*; do
        [[ -d "$db" ]] && db_list+=("$(basename "$db")")
    done

    db_name=$(zenity --list --title="Drop Database" --column="Databases" --width=500 --height=450 "${db_list[@]}")

    if [[ -n "$db_name" ]]; then
        if zenity --question --text="Are you sure you want to drop database '$db_name'?"; then
            rm -r "$db_path/$db_name"
            zenity --info --text="Database '$db_name' dropped successfully." 
        fi
    fi
}
