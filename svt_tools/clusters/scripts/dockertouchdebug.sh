#!/bin/bash

source cluster.cfg

i=$1


command() {
#  echo ssh ${SERVER[$i]} docker start ${CLUSTER[$i]}
#  ssh ${SERVER[$i]} docker start ${CLUSTER[$i]}
  echo ssh ${SERVER[$i]} docker exec ${CLUSTER[$i]} touch /var/tmp/MessageSight.debug
  ssh ${SERVER[$i]} docker exec ${CLUSTER[$i]} touch /var/tmp/MessageSight.debug
}


if [ -z $i ]; then
  for i in $(eval echo {1..${#SERVER[@]}}); do
    command
  done
else 
    command
fi

