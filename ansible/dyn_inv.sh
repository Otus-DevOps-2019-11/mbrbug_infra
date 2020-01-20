#!/bin/bash

app_ip=`cd ../terraform/stage && terraform output | grep app_external_ip | awk '{print $3}'`
db_ip=`cd ../terraform/stage && terraform output | grep db_external_ip | awk '{print $3}'`
db_ip_int=`cd ../terraform/stage && terraform output | grep db_internal_ip | awk '{print $3}'`

if [ "$1" == "--list" ] ; then
cat<<EOF
{
    "app":  {
      "hosts": [
          "$app_ip"
      ],
        "vars": {
            "db_ip_int": "$db_ip_int"
        }
    },
    "db": {
        "hosts": [
            "$db_ip"
        ]
    },
    "_meta": {
        "hostvars": {
            "192.168.28.71": {
                "host_specific_var": "bar"
            },
            "192.168.28.72": {
                "host_specific_var": "foo"
            }
        }
    }
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi
