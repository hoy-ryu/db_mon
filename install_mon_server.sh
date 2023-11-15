#!/bin/bash
HERE=$( cd "$(dirname "$0")" ; pwd )
source $HERE/common_script

if [ "$EUID" -ne 0 ]
  then echo_warn "Please run as root"
  exit
fi


echo_info "create monitoring os user"

cat /etc/passwd | grep "^db_mon:" || {
groupadd --system db_mon
useradd -s /usr/sbin/nologin -d /db_mon -r -g db_mon db_mon
}

chown -R db_mon:db_mon /db_mon

echo_info "install prometheus/pushgateway/alertmanager/grafana service"
cat /db_mon/prometheus/prometheus/script/prometheus.service \
	> /etc/systemd/system/prometheus.service
cat /db_mon/prometheus/pushgateway/script/pushgateway.service \
	> /etc/systemd/system/pushgateway.service
cat /db_mon/prometheus/alertmanager/script/alertmanager.service \
	> /etc/systemd/system/alertmanager.service
cat /db_mon/grafana/scripts/grafana.service \
	> /etc/systemd/system/grafana.service


systemctl daemon-reload

echo_info "install prometheus/pushgateway/alertmanager/grafana service"
systemctl start prometheus.service
systemctl start pushgateway.service
systemctl start alertmanager.service
systemctl start grafana.service

systemctl enable prometheus.service
systemctl enable pushgateway.service
systemctl enable alertmanager.service
systemctl enable grafana.service

# add crontab sync prom target list
echo_info "add prometheus target sync schedule to contab"
/db_mon/prometheus/pushgateway/script/install_crontab_gen_prom_target.sh
