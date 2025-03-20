#!/bin/bash

list_databases() {
    local db_path="./databases"

    if [[ ! -d "$db_path" ]]; then
        zenity --info --text="No databases found. The 'databases' directory does not exist."
        return
    fi

    if [[ -z "$(ls -A "$db_path")" ]]; then
         zenity --info --text="No databases available."
         return
    fi

    local db_list="Available Databases:\n"
    for db in "$db_path"/*; do
        if [[ -d "$db" ]]; then
            db_name=$(basename "$db")
            db_list="${db_list}\n${db_name}.db"
        fi
    done

    zenity --info --title="Database List" --text="$db_list" --width=500 --height=450
}
