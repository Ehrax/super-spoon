#!/bin/bash
###############################################################################
# GLOBAL PARAMETERS
###############################################################################
IP="host_ip"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="path_to_key" # path to youre key

###############################################################################
# RENEW CASSANDRA
###############################################################################
sed -i "s/'replication_factor': ?/'replication_factor': $REPLICATION_FACTOR/g" ./res/ycsb-setup.cql
SETUP_YCSB=$(<./res/ycsb-setup.cql)

echo "starting to renew cassandra"
ssh -i $SSH_KEY $USER@$IP "echo \"DROP KEYSPACE ycsb;\" > ./ycsb-delete.cql; \
    ./cassandra/bin/cqlsh --file ./ycsb-delete.cql; \
    echo \"$SETUP_YCSB\" > ./ycsb-setup.cql; \
    sleep 10; \
    ./cassandra/bin/cqlsh --file ./ycsb-setup.cql;"
echo "you can now use cassandra again"
