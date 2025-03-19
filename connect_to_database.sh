#!/usr/bin/bash

source utils.sh
source ./tables_menu.sh

connect_to_database() {
    db_name=$(zenity --entry --title="Connect to Database" --text="Enter database name:" --width=500 --height=450)
    
    #export db_name="$db_name"

    if [ $? -eq 1 ];then
            pacMan "....Exiting....  " 0.05 "."
            echo "Thanks for using our Database Engine "
            exit
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