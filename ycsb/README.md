# SUPER - SPOON ycsb initalize
1. change parameters
```bash
###############################################################################
# GLOBAL PARAMETERS
###############################################################################
declare -A IPS

# declare as following IPS[host_name]="host_ip"
IPS[host_name]="host_ip"
IPS[host_name2]="host_ip2"

USER="ubuntu" # machine user, Default: Ubuntu
SSH_KEY="path_to_key" # path to youre key

# ycsb repo 
GITHUB="https://github.com/seybi87/YCSB.git"
```

2. start script
```bash
./ycsb
```
