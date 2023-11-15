#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

HERE=$( cd "$(dirname "$0")" ; pwd )
source $HERE/common_script


echo_info "create monitoring os user"
cat /etc/passwd | grep "^db_mon:" || {
groupadd --system db_mon
useradd -s /usr/sbin/nologin -d /db_mon -r -g db_mon db_mon
}

chown -R db_mon:db_mon /db_mon

echo_info "install node & mysqld exporter service"
cat /db_mon/exporter/mysqld_exporter/mysqld_exporter.service > /etc/systemd/system/mysqld_exporter.service
cat /db_mon/exporter/node_exporter/node_exporter.service > /etc/systemd/system/node_exporter.service

# mysqld_exporter config setting
echo_info "mysql_exporter config file setting"
/db_mon/exporter/mysqld_exporter/create_mysql_exporter.cnf.sh


systemctl daemon-reload

echo_info "start node & mysqld exporter service"
systemctl start mysqld_exporter.service
systemctl start node_exporter.service

systemctl enable mysqld_exporter.service
systemctl enable node_exporter.service
