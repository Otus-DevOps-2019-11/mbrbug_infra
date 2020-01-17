#!/bin/bash

app_ip=`cd ../terraform/stage && terraform output | grep app_external_ip | awk '{print $3}'`
db_ip=`cd ../terraform/stage && terraform output | grep db_external_ip | awk '{print $3}'`

if [ "$1" == "--list" ] ; then
cat<<EOF
{
    "apps": {
        "hosts": [$app_ip],
    },
    "dbs": [$db_ip],
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi
