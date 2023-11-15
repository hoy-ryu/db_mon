#!/bin/bash

dbe="/usr/local/mysqlsh/bin/mysqlsh --login-path=dbe --socket=/tmp/mysql.sock --sql -A "

service_group=$service_group
db_cluster_name=$db_cluster_name
hostname=$hostname
primary_endpoint=$primary_endpoint
pushgateway_host=$pushgateway_host
job_name=$job_name

pushgateway_endpoint=http://${pushgateway_host}:9091/metrics/job/${job_name}/service_group/${service_group}/db_cluster_name/${db_cluster_name}/hostname/${hostname}


# ----------------------------------------------------------------------------------------------------------------------------
# db instance role check
# ----------------------------------------------------------------------------------------------------------------------------
PRIMARY_ROLE_FLAG=0
$dbe --connect-timeout=1500 <<endl | grep -iq server_id && { ROLE=primary ; PRIMARY_ROLE_FLAG=1; }
show replicas
endl

[[ "$ROLE" ]] || {
$dbe --connect-timeout=1500 <<endl | grep -iq server_id && { ROLE=secondary ; }
show replica status
endl
}

[[ "$ROLE" ]] || { ROLE=single ; }



# ----------------------------------------------------------------------------------------------------------------------------
# vip check
# ----------------------------------------------------------------------------------------------------------------------------
#PRIMARY_VIP_FLAG=0
#/usr/sbin/ip -4 addr | grep -q -i "$primary_endpoint_vip" && { PRIMARY_VIP_FLAG=1 ; }



cat <<EOF | curl --data-binary @- "${pushgateway_endpoint}"
# TYPE db_role_check gauge
pgw_db_role_check{ db_role="$ROLE" } $PRIMARY_ROLE_FLAG
EOF
