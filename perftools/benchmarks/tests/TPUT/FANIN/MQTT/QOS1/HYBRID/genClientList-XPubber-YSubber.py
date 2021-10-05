#!/usr/bin/python
# Copyright (c) 2021 Contributors to the Eclipse Foundation
# 
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
# 
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
# 
# SPDX-License-Identifier: EPL-2.0
#
###################################################################################### 
#
# This script generates the mqttbench client list for running the following variant of
# the TPUT.FANIN.MQTT benchmark test.
#
# Variant:
# - QoS 1 (durable client sessions)
# - Topic tree is partitioned into non-overlapping segments (1 shared subscription per partition
#   and multiple subscribers per shared subscription)
# - X publishers  (each publishing on a unique topic)
# - Y subscribers (single shared subscription per partition)
#
# NOTE: X and Y are based on the parameters passed to this script. Both X and Y are in 
#       SI units, e.g. 1, 500, 1K, 500K, 1M, etc.
######################################################################################
CLIENTLIST_FILE_PREFIX="TPUT-FANIN-MQTT-Q1-HYBRID-"
PERFAPP="perfapp"

BASEDIR="../../../../.."
PUB_CLIENTID_PREFIX="pub-perfclient"
SUB_CLIENTID_PREFIX="sub-perfclient"

import sys
import argparse
import math
import re
sys.path.append(BASEDIR)
from mqttbenchObjs import *

def fromSI(value):
    siMap = {'K': 1e3, 'M': 1e6}
    regexPattern = "^\d+[KM]?"
    pattern = re.compile(regexPattern)
    match = pattern.match(value)
    if not match is None and match.end() == len(value):
        noUnits = int(re.sub("[^0-9]", "", value))
        if value.find('K') >= 0:
            return int(noUnits * int(siMap['K']))
        elif value.find('M') >= 0:
            return int(noUnits * int(siMap['M']))
        else:
            return int(value)
    else:
        return 0
    
# Read command line arguments
def readArgs():
    global publicNetDestlist, privateNetDestlist, NUMPUBCLIENTS, NUMSUBCLIENTS, NUMPUBSTRING, NUMSUBSTRING, NUMPARTITIONS

    parser = argparse.ArgumentParser(description='Creates the mqttbench client list file for the Q1.HYBRID variant of the TPUT.FANIN.MQTT benchmark', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--numPubber", required=True, dest="numPubber", metavar="<count>", help="the number of publishers to create")
    parser.add_argument("--numSubber", required=True, dest="numSubber", metavar="<count>", help="the number of subscribers to create")
    parser.add_argument("--publicNetDestList", required=True, dest="publicNetDestlist", metavar="<comma separated list of IP or DNS name>", help="list of IPv4 addresses or DNS name of MessageSight server PUBLIC messaging endpoints")
    parser.add_argument("--privateNetDestList", required=True, dest="privateNetDestlist", metavar="<comma separated list of IP or DNS name>", help="list of IPv4 addresses or DNS name of MessageSight server PRIVATE messaging endpoints")
    args = parser.parse_args()
    
    NUMPUBSTRING = args.numPubber
    NUMSUBSTRING = args.numSubber
    NUMPUBCLIENTS = fromSI(NUMPUBSTRING)
    NUMSUBCLIENTS = fromSI(NUMSUBSTRING)
        
    if NUMPUBCLIENTS == 0 or NUMSUBCLIENTS == 0:
        print("Failed to parse the number of publishers {0} and/or subscribers {1} (numbers are in SI units, e.g. 1, 100, 50K, 1M, etc.)".format(NUMPUBSTRING, NUMSUBSTRING))
        exit(1)
    
    if NUMSUBCLIENTS < NUMPARTITIONS:
        NUMPARTITIONS = NUMSUBCLIENTS
    
    publicNetDestlist.extend(args.publicNetDestlist.split(","))
    privateNetDestlist.extend(args.privateNetDestlist.split(","))

# Create a Publisher client
def createPUBClient(id, version, dstip, partition, deleteState):
    client = MBClient(PUB_CLIENTID_PREFIX + str(id), version)
    client.dst = dstip
    client.dstPort = 8883
    client.useTLS = True
    client.topicAliasMaxOut = 1
    if deleteState:
        client.cleanStart = True
        client.sessionExpiryIntervalSecs = 0
    else:
        client.cleanStart = False
        client.sessionExpiryIntervalSecs = 0x7FFFFFFF
    
    topic = MBTopic("mqttfanin/q1-hybrid-" + NUMPUBSTRING + "PUB-" + NUMSUBSTRING + "SUB/part" + str(partition) + "/" + client._id)
    topic.qos = 1
    
    client.publishTopics.append(topic)
    
    return client

# Create a Subscriber client
def createSUBClient(id, version, dstip, partition, deleteState):
    client = MBClient(SUB_CLIENTID_PREFIX + str(id), version)
    client.dst = dstip
    client.dstPort = 16901
    client.useTLS = False
    client.topicAliasMaxIn = 10
    if deleteState:
        client.cleanStart = True
        client.sessionExpiryIntervalSecs = 0
    else:
        client.cleanStart = False
        client.sessionExpiryIntervalSecs = 0x7FFFFFFF
    
    appname = PERFAPP + str(partition)
    sub = MBTopic("$share/" + appname + "/mqttfanin/q1-hybrid-" + NUMPUBSTRING + "PUB-" + NUMSUBSTRING + "SUB/part" + str(partition) + "/#")
    sub.qos = 1
    
    client.subscriptions.append(sub)
    
    return client

NUMPUBSTRING = ""
NUMSUBSTRING = ""
NUMPUBCLIENTS = 0
NUMSUBCLIENTS = 0
publicNetDestlist = []
privateNetDestlist = []
clientlist = []
clientDeleteStateList = []

NUMPARTITIONS = 10                  # subdivide the topic tree into 10 non-overlapping partitions

# Process the command line arguments
readArgs()

# Process num pubber and num subber SI units strings and open client list file for writing
CLIENTLIST_FILE=CLIENTLIST_FILE_PREFIX + NUMPUBSTRING + "PUB-" + NUMSUBSTRING + "SUB.json"
CLIENTLIST_DELETESTATE_FILE=CLIENTLIST_FILE_PREFIX + NUMPUBSTRING + "PUB-" + NUMSUBSTRING + "SUB-DELETESTATE.json"

clfile = None
clFileDeleteState = None
try:
    clfile = open(CLIENTLIST_FILE, "w")        
    clFileDeleteState = open(CLIENTLIST_DELETESTATE_FILE, "w")        
except Exception as e:
    print("Failed to open {0} or {1} for writing, exception {2}".format(CLIENTLIST_FILE, CLIENTLIST_DELETESTATE_FILE, e))
    exit(1)

# Create publisher client entries in the mqttbench client list file and the "delete client state" client list file
count = 0
for i in range(0, int(NUMPUBCLIENTS)):
    idx = count % len(publicNetDestlist)
    dstip = publicNetDestlist[idx]
    partition = i % NUMPARTITIONS
    
    client = createPUBClient(i, MBCONSTANTS.MQTT_TCP5, dstip, partition, False)
    clientlist.append(client)
    
    clientDeleteState = createPUBClient(i, MBCONSTANTS.MQTT_TCP5, dstip, partition, True)
    clientDeleteStateList.append(clientDeleteState)
    
    count += 1

# Create subscriber client entries in the mqttbench client list file and the "delete client state" client list file
count = 0
for i in range(0, int(NUMSUBCLIENTS)):
    idx = count % len(privateNetDestlist)
    dstip = privateNetDestlist[idx]
    partition = i % NUMPARTITIONS
    
    client = createSUBClient(i, MBCONSTANTS.MQTT_TCP5, dstip, partition, False)
    clientlist.append(client)
    
    clientDeleteState = createSUBClient(i, MBCONSTANTS.MQTT_TCP5, dstip, partition, True)
    clientDeleteStateList.append(clientDeleteState)
    
    count += 1
    
MBCL.MBshuffleClients(clientlist)
MBCL.MBprintClients(clientlist, clfile)
MBCL.MBprintClients(clientDeleteStateList, clFileDeleteState)

