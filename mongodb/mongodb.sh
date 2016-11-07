#!/bin/bash

###############################################################################
# GLOBAL PARAMETERS
###############################################################################
declare -A IPS

# declare as following IPS[host_name]="host_ip"
IPS[script-test]="134.60.64.235"
IPS[script-test2]="134.60.64.243"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="~/.ssh/cloud.key" # path to youre key

OPTION="single_cluster" # OPTIONS: single_mongo, single_cluster, cluster

# mongodb parameters
VERSION="3.2.10"
STORAGE_ENGINE="wiredTiger"

# single_mongo parameters
SINGLE="script-test"

# cluster parameters
# CONFIG_SERVER="script-test"
# MONGOS_SERVEr="script-test"
# MONGOD_SERVER="script-test"

###############################################################################
# INITIALIZE MONGODB
###############################################################################

#for k in "${!IPS[@]}"; do
    #ssh-keygen -R $k
    #ssh-keygen -R ${IPS[$k]}
    #ssh-keyscan -H ${IPS[$k]} >> ~/.ssh/known_hosts
    #ssh-keyscan -H $k >> ~/.ssh/known_hosts

    #ssh -i $SSH_KEY $USER@${IPS[$k]} "sudo apt-key adv --keyserver \
        #hkp://keyserver.ubuntu.com:80 --recv EA312927; \
        #echo \"deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse\" \
        #| sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list; \
        #sudo DEBIAN_FRONTEND=nointeractive apt-get update; \
        #sudo DEBIAN_FRONTEND=nointeractive apt-get upgrade -y; \
        #sudo echo 127.0.1.1 $k | sudo tee /etc/hosts; \
        #sudo apt-get install -y \
        #mongodb-org=$VERSION \
        #mongodb-org-server=$VERSION \
        #mongodb-org-shell=$VERSION \
        #mongodb-org-mongos=$VERSION \
        #mongodb-org-tools=$VERSION;
        #sudo service mongod stop;"
#done

###############################################################################
# SET UP MONGODB
###############################################################################
MONGOD="mkdir -p mongod; \
    screen -dm bash -c 'mongod --port 27017 --dbpath ./mongod --bind_ip 0.0.0.0 \
    --storageEngine $STORAGE_ENGINE';"

function single_mongo {
    if [ ${#IPS[@]} -eq 1 ]; then
        KEYS=(${!IPS[@]})
        ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} $MONGOD
        echo "finished setting up mongod on ${IPS[${KEYS[0]}]}"
    else
        echo "ERROR: you can only set this up on one machine!"
        exit
    fi
}

function single_cluster {
    MAIN_NODE_IP=${IPS[$SINGLE]}

    LOCALIP=$(ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "hostname -I | sed s/\ //")

    ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "mkdir -p output configsvr mongod; \
    screen -dm bash -c 'mongod --configsvr --dbpath ./configsvr --bind_ip 0.0.0.0 \
    --port 27019 > ./output/config_stdout.txt 2> ./output/config_stderr.txt'; \
    screen -dm bash -c 'mongos --configdb $LOCALIP:27019 --bind_ip 0.0.0.0 \
    --port 27017 > ./output/mongos_stdout.txt 2> ./output/mongos_stderr.txt';"

    sleep 2

    echo "starting to add shards to cluster"

    for k in "${!IPS[@]}"; do
        NETWORKIP=$(ssh -i $SSH_KEY $USER@${IPS[$k]} "hostname -I | sed s/\ //")

        ssh -i $SSH_KEY $USER@${IPS[$k]} "mkdir -p mongod output; \
        screen -dm bash -c 'mongod --shardsvr --dbpath ./mongod --bind_ip 0.0.0.0 \
        --port 27018 > ./output/mongod_stdout.txt 2> ./output/mongod_stderr.txt';"

        sleep 2

        ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "echo 'sh.addShard(\"$NETWORKIP:27018\")' \
        > add_shard.js; \
        mongo < ./add_shard.js;"
    done

    sleep 2

    ssh -i $SSH_KEY $USER@$MAIN_NODE_IP "echo -e 'use ycsb\ndb.createCollection(\"usertable\")\nsh.enableSharding(\"ycsb\")\nsh.shardCollection(\"ycsb.usertable\", {_id:1})' \
       > enable_sharding.js; \
       mongo < ./enable_sharding.js"

    echo "finished setting up sinle cluster on $MAIN_NODE_IP"
}

case $OPTION in
    single_mongo)
        echo "starting setting up mongod instance!"
        single_mongo
        exit
        ;;
    single_cluster)
        echo "starting to setting up mongodb cluster on ${IPS[$SINGLE]}"
        single_cluster
        exit
        ;;
    cluster)
        echo "default was choosen"
        exit
        ;;
    *)
        echo "you have to choose the right options"
        ;;
esac
