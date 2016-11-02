#!/bin/bash
###############################################################################
# GLOBAL PARAMETSR
###############################################################################
declare -A IPS

# declare as following ([host_name]=host_ip
IPS[script-test]="134.60.64.235"
# IPS[script-test2]="134.60.64.243"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="~/.ssh/cloud.key" # path to youre key

# link to cassandra binary
CASSANDRA_BINARY="http://archive.apache.org/dist/cassandra/2.2.6/apache-cassandra-2.2.6-bin.tar.gz"

# cassandra parameters
CLUSTER_NAME="benchmark cluster"

# declare which node should be seed node, is only used if you deploy a cluster
# MAIN_NODE="main_hoste_name"
MAIN_NODE="script-test"
REPLICATION_FACTOR=1

# MAX_HEAP_SIZE="12G"
# MEMORY=""

###############################################################################
# INITIALIZE CASSANDRA
###############################################################################
echo "starting to initalize cassandra"

CONFIG="./cassandra/conf/cassandra.yaml"

for k in "${!IPS[@]}"; do
    ssh-keygen -R $k
    ssh-keygen -R ${IPS[$k]}
    ssh-keyscan -H ${IPS[$k]} >> ~/.ssh/known_hosts
    ssh-keyscan -H $k >> ~/.ssh/known_hosts

    LOCALIP=$(ssh -i $SSH_KEY $USER@${IPS[$k]} "hostname -I | sed s/\ //")

    ssh -i $SSH_KEY $USER@${IPS[$k]} "sudo add-apt-repository -y ppa:webupd8team/java; \
        sudo DEBIAN_FRONTEND=nointeractive apt-get update -y; \
        sudo DEBIAN_FRONTEND=nointeractive apt-get upgrade -y; \
        echo debconf shared/accepted-oracle-license-v1-1 select true | \
            sudo debconf-set-selections; \
        echo debconf shared/accepted-oracle-license-v1-1 seen true | \
            sudo debconf-set-selections; \
        sudo apt-get -y install oracle-java8-installer; \
        sudo echo 127.0.1.1 $k | sudo tee /etc/hosts;  \
        wget -O cassandra.tar.gz $CASSANDRA_BINARY; \
        tar -xf cassandra.tar.gz; \
        rm cassandra.tar.gz; \
        mv \$(ls | grep apache-cassandra-*) ./cassandra; \
        sed -i \"s/cluster_name: 'Test Cluster'/cluster_name: '$CLUSTER_NAME'/g\" $CONFIG; \
        sed -i \"s/listen_address: localhost/listen_address: $LOCALIP/g\" $CONFIG; \
        sed -i \"s/rpc_address: localhost/rpc_address: 0.0.0.0/g\" $CONFIG; \
        sed -i \"s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: $LOCALIP/g\" $CONFIG;"
done

echo "finished to initialize cassandra"
###############################################################################
# CONFIGURE CASSANDRA
###############################################################################
echo "starting to configure cassandra"

KEYS=(${!IPS[@]})
sed -i "s/'replication_factor': ?/'replication_factor': $REPLICATION_FACTOR/g" ./res/ycsb-setup.cql
SETUP_YCSB=$(<./res/ycsb-setup.cql)

if [ ${#IPS[@]} -eq 1 ]; then # just one cassandra node
    LOCALIP=$(ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} "hostname -I | sed s/\ //")
    ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} "sed -i 's/- seeds: \"127.0.0.1\"/- seeds: \"$LOCALIP\"/g' $CONFIG; \
        nohup ./cassandra/bin/cassandra > cassandra.out 2> cassandra.err < /dev/null &"
    sleep 20
    ssh -i $SSH_KEY $USER@${IPS[${KEYS[0]}]} "echo \"$SETUP_YCSB\" > ./ycsb-setup.cql; \
        ./cassandra/bin/cqlsh --file ./ycsb-setup.cql;"
    echo "finished to configure cassandra, you can now connect on ${IPS[${KEYS[0]}]}"
else # build cassandra cluster
    SEED_NODE=${IPS[$MAIN_NODE]}
    unset IPS[$MAIN_NODE] # remove seed node from list
    SEEDS=$(ssh -i $SSH_KEY $USER@$SEED_NODE "hostname -I | sed s/\ //")

    for k in "${!IPS[@]}"; do
        LOCALIP=$(ssh -i $SSH_KEY $USER@${IPS[$k]} "hostname -I | sed s/\ //")
        SEEDS=$SEEDS","$LOCALIP
        ssh -i $SSH_KEY $USER@${IPS[$k]} "sed -i 's/- seeds: \"127.0.0.1\"/- seeds: \"$LOCALIP\"/g' $CONFIG; \
        nohup ./cassandra/bin/cassandra > cassandra.out 2> cassandra.err < /dev/null &"
    done

    ssh -i $SSH_KEY $USER@$SEED_NODE "sed -i 's/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/g' $CONFIG; \
        nohup ./cassandra/bin/cassandra > cassandra.out 2> cassandra.err < /dev/null &"
    sleep 20
    ssh -i $SSH_KEY $USER@$SEED_NODE "echo \"$SETUP_YCSB\" > ./ycsb-setup.cql; \
        ./cassandra/bin/cqlsh --file ./ycsb-setup.cql;"
    echo "finished to configure cassandra cluster, seed node is $SEED_NODE"
fi
