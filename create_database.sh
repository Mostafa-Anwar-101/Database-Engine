
#! /bin/bash

source utils.sh

create_database() {
    if [[ ! -d "./databases" ]]; then
        mkdir -p "./databases"
    fi

    while true; do
        database_name=$(zenity --entry --title="Create to Database" --text="Enter database name:" --width=500 --height=450)

        if [ $? -eq 1 ];then
            return
        fi

        if [[ "$database_name" =~ [[:space:]] ]]; then
            zenity --error --text="Spaces are not allowed."
            continue
        fi

        if [[ ! "$database_name" =~ ^[a-zA-Z][a-zA-Z0-9_]{0,39}$ ]]; then
            zenity --error --text="Invalid database name use only characters, underscores, starting with a letter."
            continue
        fi

        if [[ -d "./databases/$database_name" ]]; then
            zenity --error --text="Database '$database_name' already exists. Choose another name."
            continue
        else
            mkdir -p "./databases/$database_name"
            zenity --info --text="Database '$database_name' created successfully."
        fi

        break 
    done
}
