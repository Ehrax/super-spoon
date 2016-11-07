# SUPER - SPOON Mongodb Script
1. determine which mongdb server you are deploying  
    - **single_mongo:** 1x mongodb instance one one machine
    - **single_cluster:** use this option if you want all main cluster instances on   
    same machine. You need atleast 1 machine
    ```
    mongos(SM)----- config(SM)
      |
      |
      |
    Shard1(SM)
      .
      .
    Shard2(DM)
      .
      .
      .
    ShardN(DM)

    
    SM = same machine
    DM = diffrent machine
    ```
    - **cluster:** all mongodb instances are on diffrent machines
2. change parameters
```bash
declare -A IPS

OPTION="single_mongo" # OPTIONS: single_mongo, single_cluster, cluster

# declare as following IPS[host_name]="host_ip"
IPS[host_name]="host_ip"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="path/to/key" # path to youre key

# mongodb parameters
VERSION="3.2.10"
STORAGE_ENGINE="wiredTiger"

# single_mongo parameters
# SINGLE="" # uncomment this if you use single_cluster

# cluster parameters
# MONGOS_SERVER="" # uncomment this if you use cluster
# CONFIG_SERVER="" # uncomment this if you use cluster
```

3. start script
```bash
./mongodb
```

# Examples Parametesr
1. single_cluster

```bash
declare -A IPS

OPTION="single_cluster" # OPTIONS: single_mongo, single_cluster, cluster

# declare as following IPS[host_name]="host_ip"
IPS[example]="1.2.3.4"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="~/.ssh/my_key" # path to youre key

# mongodb parameters
VERSION="3.2.10"
STORAGE_ENGINE="wiredTiger"

# single_mongo parameters
SINGLE="example" # uncomment this if you use single_cluster

# cluster parameters
# MONGOS_SERVER="" # uncomment this if you use cluster
# CONFIG_SERVER="" # uncomment this if you use cluster
```

2. cluster
```bash
declare -A IPS

OPTION="single_cluster" # OPTIONS: single_mongo, single_cluster, cluster

# declare as following IPS[host_name]="host_ip"
IPS[example]="1.2.3.4"
IPS[example2]="100.200.300.400"
IPS[example3]="200.300.400.500"
IPS[example4]="11.22.33.44"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="~/.ssh/my_key" # path to youre key

# mongodb parameters
VERSION="3.2.10"
STORAGE_ENGINE="wiredTiger"

# single_mongo parameters
# SINGLE="" # uncomment this if you use single_cluster

# cluster parameters
MONGOS_SERVER="example" # uncomment this if you use cluster
CONFIG_SERVER="example2" # uncomment this if you use cluster
```
