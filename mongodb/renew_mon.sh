#!/bin/bash

###############################################################################
# GLOBAL PARAMETERS
###############################################################################
USER="ubunut" # machine user

SSH_KEY="~/.ssh/cloud.key"

IP="host_ip" # main mongodb instance

SHARDED="no"

###############################################################################
# RENEW COUCHBASE
###############################################################################
case $SHARDED in
    yes)
        ssh -i $SSH_KEY $USER@IP "echo -e 'use ycsb\ndb.dropDatabase()' \
        > delete.js; \
        mongo < ./delete.js;
        mongo < ./enable_sharding.js"
        ;;
    no)
        ssh -i $SSH_KEY $USER@$IP "echo -e 'use ycsb\ndb.dropDatabase()' \
        > delete.js; \
        mongo < delete.js;"
        exit
        ;;
    *)
        echo "choose sharded: yes or no"
        ;;
esac



echo "finished renewing mongodb"
