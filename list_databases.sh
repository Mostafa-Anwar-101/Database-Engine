list_databases() {
    local db_path="./databases"

    if [[ ! -d "$db_path" ]]; then
        echo "No databases found. The 'databases' directory does not exist."
        return
    fi

    local databases=( "$db_path"/* )

    if [[ ${#databases[@]} -eq 0 ]]; then
        echo "No databases available."
    else
        echo "Available Databases:"
        for db in "$db_path"/*; do
            if [[ -d "$db" ]]; then
                local db_name
                db_name=`basename "$db"`  
                echo " - $db_name"
            fi
        done
    fi
}
