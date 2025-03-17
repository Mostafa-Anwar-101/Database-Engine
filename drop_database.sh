#!/usr/bin/bash
source ./list_DB.sh

function drop_database() {
    listDatabases 
    if [ $? -eq 1 ]; then
        echo "Returning to main menu..."
        return
    fi

    while true; do
        read -p "Enter the DB name you want to drop or (exit) to return: " db_name

        if [[ "$db_name" == "exit" ]]; then
            echo "Returning to the main menu."
            return
        fi

        if [[ ! "$db_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Invalid database name. Must start with a letter and contain only letters, numbers, or underscores."
            continue
        fi

        if [ -d "./databases/$db_name" ]; then
            rm -r "./databases/$db_name"
            echo "Database '$db_name' successfully deleted."
            break
        else
            echo "Database '$db_name' does not exist."
        fi
    done
}
