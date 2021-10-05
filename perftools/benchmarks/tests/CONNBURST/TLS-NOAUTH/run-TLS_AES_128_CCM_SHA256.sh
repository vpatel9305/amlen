#!/bin/bash

# -----------------------------------------------------------------------------------------------------
#
# This script executes the CONNBURST.TLS.NOAUTH (AES128-SHA256 cipher) benchmark test, 
# see README.md for test details
#
# -----------------------------------------------------------------------------------------------------

export GraphiteIP=<hostname of Graphite relay>
export TESTNAME=CONNBURST-TLS-NOAUTH
export TESTVARIANT=${TESTNAME}-TLS_AES_128_CCM_SHA256
export GraphiteMetricRoot=$TESTVARIANT

# delay between new connections (units in microseconds)
export DelayTime=100
export DelayCount=1

# TLS settings
export SSLCipher=TLS_AES_128_CCM_SHA256
export SSLClientMeth=TLSv12

# Setup trust store
CERTSDIR=../../../certs
ROOTCA_HASH=`openssl x509 -hash -in $CERTSDIR/cert-rootCA.pem -noout`
mkdir -p certs
ln -sf ../$CERTSDIR/cert-rootCA.pem certs/${ROOTCA_HASH}.0

# Reset connection latency statistics every 140 seconds (-rl 140) and latency histogram units are in milliseconds (-cu 1e-3).  
# Clients remain connected for 140 seconds (-l 140)
mqttbench -cl $TESTNAME.json -T 0x20 -snap connects,connlatency 4 -cu 1e-3 -csv $TESTVARIANT.stats.csv -lcsv $TESTVARIANT.latency.csv -rl 160 -l 160 

