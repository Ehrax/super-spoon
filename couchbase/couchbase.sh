#!/bin/bash

###############################################################################
# GLOBAL PARAMETERS
###############################################################################
declare -A IPS

# declare as following IPS[host_name]="host_ip"
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="path_to_key" # path to youre key

# link to couchbase binary
BASE_BINARY="http://packages.couchbase.com/releases/4.1.1/couchbase-server-community_4.1.1-ubuntu14.04_amd64.deb"

# COUCHBASE PARAMETERS
BUCKET_NAME='default' # name of Bucket, Default: default
RAMSIZE=5000 # couchbase Ramsize
INDEXSIZE=1000 # couchbase Indexsize
REPLICATION_FACTOR=1 # couchabse replication factor

# decide which node should be main node of cluster
MAIN_NODE="host_name"

CH_USER='admin' # couchbase admin
CH_PW='topsecret' # couchbase admin password

###############################################################################
#  INITIALIZE COUCHBASE
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
        sudo echo 127.0.1.1 $k | sudo tee /etc/hosts;  \
        wget -O couchbase.deb $BASE_BINARY; \
        mv couchbase.deb /tmp/couchbase.deb; \
        sudo dpkg -i /tmp/couchbase.deb;"

        echo "installed couchbase on ${IPS[$k]}"
    sleep 4
    ssh -i $SSH_KEY $USER@${IPS[$k]} $CLUSTER_INIT
done

echo "finished to install couchbase."
###############################################################################
# CONFIGURE COUCHBASE
###############################################################################
echo "starting to setting up couchbase"
KEYS=(${!IPS[@]})
CREATE_BUCKET="IPADDR=(\$(hostname -I)); \
        /opt/couchbase/bin/couchbase-cli bucket-create -c \$IPADDR:8091 \
        -u $CH_USER \
        -p $CH_PW \
        --bucket=$BUCKET_NAME \
        --bucket-type=couchbase \
        --bucket-ramsize=$RAMSIZE \
        --bucket-priority=high \
        --bucket-replica=$REPLICATION_FACTOR \
        --wait;"

if [ ${#IPS[@]} -eq 1 ]; then # just one couchbase server
    sleep 2
    ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} $CREATE_BUCKET
    echo "finishd to setting up couchbase, \
        you can now connect to ${IPS[${KEYS[0]}]}"

    exit 1
else # if a cluster should be deployed
    MAIN_NODE_IP=${IPS[$MAIN_NODE]}
    unset IPS[$MAIN_NODE]

    sleep 2
    # create bucket on cluster
    ssh -i $SSH_KEY $USER@$MAIN_NODE_IP $CREATE_BUCKET

    for k in "${!IPS[@]}"; do
        LOCALIP=$(ssh -i $SSH_KEY $USER@${IPS[$k]} "hostname -I | sed s/\ //")
        ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "IPADDR=(\$(hostname -I)); \
            /opt/couchbase/bin/couchbase-cli rebalance -c \$IPADDR:8091 \
            -u $CH_USER \
            -p $CH_PW \
            --server-add=$LOCALIP:8091 \
            --server-add-username=$CH_USER \
            --server-add-password=$CH_PW \
            --services=data,index,query;"
    done

    echo "finished setting up couchbas-cluster, \
        you can now connecnt to $MAIN_NODE_IP!"
fi
