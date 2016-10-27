#!/bin/bash

declare -A IPS
IPS=(['script-test']='134.60.64.243' ['script-test2']='134.60.64.235')

KEYS=(${!IPS[@]})

echo ${IPS[${KEYS[0]}]}

IPADDR=(\$(hostname -I)); \
            /opt/couchbase/bin/couchbase-cli rebalance -c 127.0.0.1:8091 \
            -u admin \
            -p topsecret \
            --server-add 192.168.0.185:8091 \
            --server-add-username=admin \
            --server-add-password=topsecret \
            --services=data,index,query;
