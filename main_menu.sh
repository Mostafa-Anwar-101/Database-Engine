#!/bin/bash

source utils.sh
source create_database.sh
source list_databases.sh
source connect_to_database.sh
source drop_database.sh

function main_menu(){
    while true; do
        choice=$(zenity --list --width=500 --height=450\
        --title="Main Menu" \
        --text="Please Choose An Option:" \
        --column="Select what you want to do" \
        "Create a Database" \
        "List All DataBases" \
        "Connect TO A Database" \
        "Drop A Database" \
        )
        if [ $? -eq 1 ];then
            exit_program
        else
            case $choice in
                "Create a Database" )  
                    create_database;;
                "List All DataBases" )
                    list_databases;;
                "Connect TO A Database" )
                    connect_to_database;;
                "Drop A Database" )
                    drop_database;;
                *)
                    zenity --error --text="Invalid selection. Try again." ;;
            esac
        fi
    done
}
main_menu
