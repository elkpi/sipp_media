#!/bin/bash

CALLID="${2}"
SDP="${3}"
PID_DIR=/tmp/sipp
A_CODEC=pcm_alaw
#A_CODEC=pcm_mulaw
#A_CODEC=g722
AR=8000
ARS=160
VPT=96

case $A_CODEC in
    pcm_alaw|pcm_mulaw)
        AR=8000
    ;;
    g722)
        AR=16000
    ;;
esac

do_start () {
    A_PORT=`echo "$SDP" | sed -n '/m=audio/p' | awk '{ print $2 }'`
    A_IP=`echo "$SDP" | sed -n '/c=IN/p' | sed -n '1p' | sed 's/\(.*\) \(.*\) \(.*\)/\3/g' | tr -d '\r\n'`
    V_PORT=`echo "$SDP" | sed -n '/m=video/p' | sed -n '1p' | awk '{ print $2 }'`
    V_IP=`echo "$SDP" | sed -n '/c=IN/p' | sed -n '2p' | sed 's/\(.*\) \(.*\) \(.*\)/\3/g' | tr -d '\r\n'`
    mkdir -p $PID_DIR
    ffmpeg -f concat -re -i list.txt -vn -filter_complex "aresample=$AR,asetnsamples=n=$ARS" -c:a $A_CODEC -f rtp -seq 0 rtp://$A_IP:$A_PORT -an -c:v copy -f rtp -seq 0 -payload_type $VPT rtp://$V_IP:$V_PORT &
    echo "$!" > $PID_DIR/$CALLID.pid
}

do_stop () {
    [ -f $PID_DIR/$CALLID.pid ] && {
        kill -9 `cat $PID_DIR/$CALLID.pid`
        rm -rf $PID_DIR/$CALLID.pid
    }
}

case "$1" in
    "start")
        do_start
    ;;
    "stop")
        do_stop
    ;;
esac
