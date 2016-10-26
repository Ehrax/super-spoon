#!/bin/bash

###############################################################################
# GLOBAL PARAMETERS 
###############################################################################

declare -A IPS 
# add CLUSTER NODE last
# declare as following ([host_name]=host_ip
IPS=(['script-test']='134.60.64.235' ['script-test2']='134.60.64.243')

USER='ubuntu' # Openstack User, Default: Ubuntu
SSH_KEY='~/.ssh/cloud.key' # Your Key

# COUCHBASE PARAMETERS
# Couchbase Binary
BASE_BINARY='http://packages.couchbase.com/releases/4.1.0/couchbase-server-community_4.1.0-ubuntu14.04_amd64.deb'


BUCKET_NAME='default' # Name of Bucket, Default: default
RAMSIZE=5000 # Couchbase Ramsize
INDEXSIZE=1000 # Couchbase Indexsize

# Administration
CH_USER='admin'
CH_PW='topsecret'

###############################################################################
# SET UP COUCHBASE 
###############################################################################
echo "starting to install couchbase."

CLUSTER_INIT="IPADDR=(\$(hostname -I)); \
        /opt/couchbase/bin/couchbase-cli cluster-init -c \$IPADDR:8091 \
        --cluster-username=$CH_USER \
        --cluster-password=$CH_PW \
        --cluster-ramsize=$RAMSIZE \
        --cluster-index-ramsize=$INDEXSIZE \
        --services=data,index,query;"

for k in "${!IPS[@]}"; do
    ssh-keygen -R $k
    ssh-keygen -R ${IPS[$k]}
    ssh-keyscan -H ${IPS[$k]} >> ~/.ssh/known_hosts
    ssh-keyscan -H $k >> ~/.ssh/known_hosts

    ssh -i $SSH_KEY $USER@${IPS[$k]} "sudo DEBIAN_FRONTEND=nointeractive \
        apt-get update; \
        sudo DEBIAN_FRONTEND=nointeractive apt-get upgrade -y; \
        sudo echo 127.0.0.1 $k | sudo tee /etc/hosts;  \
        wget -O couchbase.deb $BASE_BINARY; \
        mv couchbase.deb /tmp/couchbase.deb; \
        sudo dpkg -i /tmp/couchbase.deb;"

        echo "installed couchbase on ${IPS[$k]}"
    sleep 4
    ssh -i $SSH_KEY $USER@${IPS[$k]} $CLUSTER_INIT
done

echo "finished to install couchbase."

KEYS=(${!IPS[@]})

CREATE_BUCKET="IPADDR=(\$(hostname -I)); \
        /opt/couchbase/bin/couchbase-cli bucket-create -c \$IPADDR:8091 \
        -u $CH_USER \
        -p $CH_PW \
        --bucket=$BUCKET_NAME \
        --bucket-type=couchbase \
        --bucket-ramsize=$RAMSIZE \
        --bucket-priority=high \
        --wait;"

if [ ${#IPS[@]} -eq 1 ]; then # just one couchbase server
    sleep 2
    ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} $CREATE_BUCKET
    echo "finishd to setting up couchbase, \
        you can now connect to ${IPS[${KEYS[0]}]}"

    exit 1
else # if a cluster should be deployed
    #MAIN_NODE_IP=${IPS[${KEYS[0]}]}
    #unset IPS[${KEYS[0]}]
    #ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} $CREATE_BUCKET

    #for k in "${!IPS[@]}"; do
        ##ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "IPADDR=(\$(hostname -I)); \
            ##/opt/couchbase/bin/couchbase-cli rebalance -c \$IPADDR:8091 \
            ##-u $CH_USER \
            ##-p $CH_PW \
            ##--server-add ${IPS[$k]}:8091 \
            ##--server-add-username=$CH_USER \
            ##--server-add-password=$CH_PW \
            ##--services=data,index,query;"
        #curl -u $CH_USER:$CH_PW $MAIN_NODE_IP:8091/controller/addNode \
            #-d "hostname=${IPS[$k]}&user=$CH_USER&password=$CH_PW";
    #done

    #echo "finished setting up couchbas-cluster!"
fi
