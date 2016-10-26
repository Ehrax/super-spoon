#!/bin/bash

IPS=(['script-test2']='134.60.64.243' ['script-test']='134.60.64.235')

for k in "${!IPS[@]}"; do
    ssh -i ~/.ssh/cloud.key ubuntu@${IPS[$k]} "sudo dpkg -r couchbase-server-community; \
        sudo rm -r /opt/couchbase;"
done
