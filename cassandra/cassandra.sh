#!/bin/bash
###############################################################################
# GLOBAL PARAMETSR
###############################################################################
declare -A IPS
# add Main cluster node as last
# declare as following ([host_name]=host_ip
IPS=(["script-test"]="134.60.64.235")

USER="ubuntu" # maschine user, Default: Ubuntu
SSH_KEY="~/.ssh/cloud.key" # path to youre key

# link to cassandra binary
CASSANDRA_BINARY="http://archive.apache.org/dist/cassandra/2.2.6/apache-cassandra-2.2.6-bin.tar.gz"

# cassandra parameters
CLUSTER_NAME="benchmark cluster"
RPC_ADDRESS="0.0.0.0"

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
        sed -i \"s/listen_address: localhost/listen_addres: $LOCALIP/g\" $CONFIG; \
        sed -i \"s/rpc_address: localhost/rpc_address: 0.0.0.0/g\" $CONFIG; \
        sed -i \"s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: $LOCALIP/g\" $CONFIG;"
done

echo "finished to initialize cassandra"
###############################################################################
# CONFIGURE CASSANDRA
###############################################################################
echo "starting to configure cassandra"

