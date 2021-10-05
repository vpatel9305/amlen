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
########################################################################################### 
#
# This script generates the mqttbench client list for running the CONNBURST-TLS-CLIENTCERT
# benchmark test.
#
###########################################################################################
CLIENTLIST_FILE="CONNBURST-TLS-CLIENTCERT.json"
NUMCLIENTS = 1e6

BASEDIR="../.."
CERTSDIR="../../../certs"
CLIENTCERTPATH="{0}{1}{2}".format(CERTSDIR, "/", "cert-client.pem")
CLIENTKEYPATH="{0}{1}{2}".format(CERTSDIR, "/", "key-client.pem")
CLIENTID_PREFIX="perfclient"

import sys
import argparse
sys.path.append(BASEDIR)
from mqttbenchObjs import *

# Read command line arguments
def readArgs():
    global destlist

    parser = argparse.ArgumentParser(description='Creates the mqttbench client list file for the CONNBURST.TLS.CLIENTCERT benchmark', formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--destlist", required=True, dest="destlist", metavar="<comma separated list of IP or DNS name>", help="list of IPv4 addresses or DNS name of MessageSight server messaging endpoints")
    args = parser.parse_args()
    
    destlist.extend(args.destlist.split(","))

# Create a client
def createClient(id, version, dstip):
    client = MBClient(CLIENTID_PREFIX + str(id), version)
    client.dst = dstip
    client.dstPort = 8884
    client.cleanStart = True
    client.useTLS = True
    client.clientCertPath = CLIENTCERTPATH
    client.clientKeyPath = CLIENTKEYPATH
    return client

destlist = []
clientlist = []
clfile = None
try:
    clfile = open(CLIENTLIST_FILE, "w")        
except Exception as e:
    print("Failed to open {0} for writing, exception {1}".format(CLIENTLIST_FILE, e))
    exit(1)

# Process the command line arguments
readArgs()

# Create client entries in the mqttbench client list file
count = 0
for i in range(0, int(NUMCLIENTS)):
    idx = count % len(destlist)
    dstip = destlist[idx]
    client = createClient(i, MBCONSTANTS.MQTT_TCP5, dstip)
    clientlist.append(client)
    count += 1
    
MBCL.MBshuffleClients(clientlist)
MBCL.MBprintClients(clientlist, clfile)

