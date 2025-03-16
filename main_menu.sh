#!/bin/bash

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
            echo " Exiting.... thanks for using our Database Engine "
            exit
        else
            case $choice in
                "Create a Database" )  
                    source create_database.sh;;
                "List All DataBases" )
                    source list_databases.sh;;
                "Connect TO A Database" )
                    source connect_to_database.sh;;
                "Drop A Database" )
                    source drop_database.sh;;
                *)
                    zenity --error --text="Invalid selection. Try again." ;;
            esac
        fi
    done
}
main_menu
