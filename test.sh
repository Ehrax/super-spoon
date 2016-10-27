#!/bin/bash

declare -A IPS
IPS=(['script-test']='134.60.64.243' ['script-test2']='134.60.64.235')

KEYS=(${!IPS[@]})

echo ${IPS[${KEYS[0]}]}
