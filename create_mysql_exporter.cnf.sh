#!/bin/bash

mysql_exporter_cnf=/etc/mysql_exporter.cnf
if [[ -f "$mysql_exporter_cnf" ]]; then
    echo "$mysql_exporter_cnf exists."
    exit 1
fi

[[ "$db_mon_port" ]] || read -p "db_port: " db_mon_port
[[ "$db_mon_user" ]] || read -p "db_user: " db_mon_user
[[ "$db_mon_password" ]] || read -p "db_password: " db_mon_password

cat <<endl > $mysql_exporter_cnf
[client]
port=${db_mon_port}
user=${db_mon_user}
password=${db_mon_password}
endl
