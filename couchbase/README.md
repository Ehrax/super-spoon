# SUPER - SPOON Couchbase Script
- change parameters as you need them
- script will set up a cluster or a single couchbase server. This depends on 
how many machines you have added.
    - 1 server = 1 singel couchbase server
    - 1..n servers = couchbase cluster
```bash
# open ./couchbase.sh
vim ./couchbase.sh

# change global parameters as you need them
###############################################################################
# GLOBAL PARAMETERS
###############################################################################
declare -A IPS

# declare as following IPS[host_name]="host_ip"
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"

USER='ubuntu' # machine user, Default: Ubuntu
SSH_KEY='path/to/key' # path to youre key

# COUCHBASE PARAMETERS
BASE_BINARY='url to binary' # link to couchbase binary
BUCKET_NAME='default' # name of Bucket, Default: default
RAMSIZE=5000 # couchbase Ramsize
INDEXSIZE=1000 # couchbase Indexsize

# decide which node should be main node of cluster
MAIN_NODE="host_name"

# Administration
CH_USER='admin' # couchbase admin
CH_PW='topsecret' # couchbase admin password

```
remember to add all machine addresses as following:
```bash
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"
        .
        .
        .
    and so on..
```
start script
```bash
./couchbase.sh
```
# renew couchbase
1. change parameters in ./renew_ch.sh
```bash
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

```
2. save
3. start './nenew_ch.sh'
