#!/bin/bash

###############################################################################
# GLOBAL PARAMETERS
###############################################################################
IP="host_ip" # machine ip
USER="ubunut" # machine user

SSH_KEY="path_to_key"

# COUCHBASE PARAMETERS
BUCKET_NAME='default' # name of Bucket, Default: default
RAMSIZE=5000 # couchbase Ramsize
REPLICATION_FACTOR=1 # couchabse replication factor

CH_USER="admin" # couchbase admin
CH_PW="topsecret" # couchbase admin password

###############################################################################
# RENEW COUCHBASE
###############################################################################
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

DELETE_BUCKET="IPADDR=(\$(hostname -I)); \
    /opt/couchbase/bin/couchbase-cli bucket-delete -c \$IPADDR:8091 \
    -u $CH_USER -p $CH_PW \
    --bucket=$BUCKET_NAME;
"

echo "starting to delete bucket: $BUCKET_NAME"
ssh -i $SSH_KEY $USER@$IP $DELETE_BUCKET
echo "finished to delete bucket: $BUCKET_NAME"

echo "starting to create bucket: $BUCKET_NAME"
ssh -i $SSH_KEY $USER@$IP $CREATE_BUCKET
echo "finished to delete bucket: $BUCKET_NAME"

echo "done, bucket was deleted and recreated on $IP"
