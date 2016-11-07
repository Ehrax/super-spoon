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

GITHUB="https://github.com/seybi87/YCSB.git"

###############################################################################
# INITIALIZE YCSB
###############################################################################
echo "starting to initialize ycsb"

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
        sudo apt-get -y install git;
        sudo apt-get -y install maven2;
        git clone $GITHUB"
done
