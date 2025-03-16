#!/usr/bin/bash

source ./tables_menu.sh


connect_to_database() {
    db_name=$(zenity --entry --title="Connect to Database" --text="Enter database name:" --width=500 --height=450)
    if [ $? -eq 1 ];then
            pacMan "....Exiting....  " 0.05 "."
            echo "Thanks for using our Database Engine "
            exit
    fi
    if [[ -d "databases/$db_name" ]]; then
        zenity --info --text="Connected to database '$db_name'."
         cd "databases/$db_name"
         tables_menu
    else
        zenity --error --text="Database '$db_name' does not exist."
    fi
}
