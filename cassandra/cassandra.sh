#!/bin/bash
###############################################################################
# GLOBAL PARAMETSR
###############################################################################
declare -A IPS
# add Main cluster node as last
# declare as following ([host_name]=host_ip
IPS=(["script-test"]="134.60.64.235")

USER='ubuntu' # maschine user, Default: Ubuntu
SSH_KEY='my_key' # path to youre key

# link to cassandra binary
CASSANDRA_BINARY='http://archive.apache.org/dist/cassandra/2.2.6 \
    /apache-cassandra-2.2.6-bin.tar.gz'


