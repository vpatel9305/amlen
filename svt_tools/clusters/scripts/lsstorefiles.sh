#!/bin/bash

source cluster.cfg

i=$1


command() {
  echo ssh ${SERVER[$i]} ls /var/messagesight/store/${CLUSTER[$i]}/
  ssh ${SERVER[$i]} ls /var/messagesight/store/${CLUSTER[$i]}/
}


if [ -z $i ]; then
  for i in $(eval echo {1..${#SERVER[@]}}); do
    command
  done
else 
    command
fi


