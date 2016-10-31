# SUPER - SPOON Cassandra set up script
1. change parametesr
    - 1x machine added = 1 cassandra server
    - 1..n machines added = 1..n cassandra cluster with one seed node
```bash
###############################################################################
# GLOBAL PARAMETSR
###############################################################################
declare -A IPS

# declare as following ([host_name]=host_ip
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="~/.ssh/cloud.key" # path to youre key

# link to cassandra binary
CASSANDRA_BINARY="http://archive.apache.org/dist/cassandra/2.2.6/apache-cassandra-2.2.6-bin.tar.gz"

# cassandra parameters
CLUSTER_NAME="benchmark cluster"
# declare which node should be seed node, is only used if you deploy a cluster
# MAIN_NODE="main_hoste_name"
MAIN_NODE="host_name"

```

remember to add machines as following:

```bash
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"
        .
        .
        .
    and so on
```

start script

```bash
./cassandra.sh

```
