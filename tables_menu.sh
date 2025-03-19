#!/usr/bin/bash

source utils.sh
source create_table.sh
source list_tables.sh
source drop_table.sh
source insert_into_table.sh
source select_from_table.sh
source delete_from_table.sh
source update_table.sh

function tables_menu(){
    pwd
    while true; do
        choice=$(zenity --list --width=500 --height=450\
        --title="Main Menu" \
        --text="Please Choose An Option:" \
        --column="Select what you want to do" \
        "Create a Table" \
        "List All Tables" \
        "Drop A Table" \
        "Insert Into Table" \
        "Select From Table" \
        "Delete From Table" \
        "Update Table" \
        )
        if [ $? -eq 1 ];then
            exit_program
        else
            case $choice in
                "Create a Table" )  
                    create_table;;
                "List All Tables" )
                    list_tables;;
                "Drop A Table" )
                    drop_table;;
                "Insert Into Table" )
                    insert_into_table;;
                "Select From Table" )
                    select_from_table;;
                "Delete From Table" )
                   delete_from_table;;
                "Update Table" )
                    update_table;;
                *)
                    zenity --error --text="Invalid selection. Try again." ;;
            esac
        fi
    done
}
