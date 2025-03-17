#! /bin/bash

create_database() {
    if [[ ! -d "./databases" ]]; then
        mkdir -p "./databases"
    fi

    while true; do
        read -p "Enter the name of the database or type exit to return to the main menu: " database_name

        if [[ "$database_name" == "exit" ]]; then
            echo "Returning to the main menu."
            return
        fi

        if [[ "$database_name" =~ [[:space:]] ]]; then
            echo "Spaces are not allowed."
            continue
        fi

        if [[ ! "$database_name" =~ ^[a-zA-Z][a-zA-Z0-9_]{0,39}$ ]]; then
            echo "Invalid database name use only characters, underscores, starting with a letter"
            continue
        fi

        if [[ -d "./databases/$database_name" ]]; then
            echo "Database '$database_name' already exists. Choose another name"
            continue
        else
            mkdir -p "./databases/$database_name"
            echo "Database '$database_name' created successfully."
        fi

        break 
    done
}
