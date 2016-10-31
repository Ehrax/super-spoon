# SUPER - SPOON Couchbase Script
```bash
# open ./couchbase.sh
vim ./couchbase.sh

# change global parameters as you need them
###############################################################################
# GLOBAL PARAMETERS
###############################################################################

declare -A IPS
# add Main cluster node as last
# declare as following ([host_name]=host_ip
IPS=([host_name]=host_ip)

USER='ubuntu' # Openstack User, Default: Ubuntu
SSH_KEY='my_key' # Your Key

# COUCHBASE PARAMETERS
BASE_BINARY='my_couchbase_binary'
BUCKET_NAME='default' # Name of Bucket, Default: default
RAMSIZE=5000 # Couchbase Ramsize
INDEXSIZE=1000 # Couchbase Indexsize

# Administration
CH_USER='admin' # couchbase admin
CH_PW='topsecret' # couchbase admin password

```
remember to add all maschine addresses as following:
```bash
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"
        .
        .
        .
    and so on..
```

Script was tested on 4 Maschines with Ubuntu 14.04 and Couchbase 4.1.0
