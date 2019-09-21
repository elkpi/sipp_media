#!/bin/bash

LOCAL=192.168.78.6
SRV=192.168.78.8:5060
CSV=account.csv
M=20000

usage() {
  echo "usage: $0 [OPTION]"
  echo "        -l <LOCAL IP ADDR>"
  echo "        -s <SIP SRV IP:PORT, e.g. $SRV>"
  echo "        -c <ACCOUNT LIST CSV FILE>"
  echo "        -m <test Calls>"
  echo "        -h show usage"
  exit 0
}

while getopts "l:s:c:hm:" opt; do
    case $opt in
        l)
            LOCAL=$OPTARG
        ;;
        s)
            SRV=$OPTARG
        ;;
        c)
            CSV=$OPTARG
        ;;
        m)
            M=$OPTARG
        ;;
        h)
            usage
        ;;
    esac
done

let REG_CNT=$(cat $CSV | wc -l)-1

sipp -sf reg.xml -inf $CSV -p 6666 -i $LOCAL -m $REG_CNT $SRV -deadcall_wait 0
sipp -sf media.xml -inf $CSV -p 6666 -i $LOCAL -m $M $SRV -deadcall_wait 0
