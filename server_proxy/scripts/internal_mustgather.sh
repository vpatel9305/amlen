#!/bin/bash
# Copyright (c) 2018-2021 Contributors to the Eclipse Foundation
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

PXY_INSTALL_DIR=${IMA_PROXY_INSTALL_PATH}
PXY_DATA_DIR=${IMA_PROXY_DATA_PATH}
IMACFGDIR=${PXY_DATA_DIR}/data/config

WORKING_DIR=$1
if [ -z $WORKING_DIR ]
then
	WORKING_DIR=${PXY_DATA_DIR}/diag/cores
fi
mkdir -p ${WORKING_DIR} > /dev/null 2>&1
WORKING_DIR="$(cd $WORKING_DIR; pwd)"

PREFIX=$2
if [ -z $PREFIX ]
then
	PREFIX=container
fi

IMAPROXY_SOURCE=$(dirname $(rpm -q --filesbypkg IBMWIoTPMessageGatewayProxy | grep lib64 | head -n 1  | awk '{print $2}') 2> /dev/null)
if [ -z $IMAPROXY_SOURCE ]
then
	IMAPROXY_SOURCE=${PXY_INSTALL_DIR}
fi


FILES_TO_COMPRESS=
FILES_TO_CLEANUP=

COUNT=1

if [ "$PREFIX" == "container" ]
then
echo "====================================="
echo " General info section"
echo "====================================="
echo "${COUNT}. uname -a"
uname -a 2> /dev/null
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. locale"
locale 2> /dev/null
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. date"
date 2> /dev/null
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. df -h --exclude-type=nfs4 --exclude-type=nfs3"
df -h --exclude-type=nfs4 --exclude-type=nfs3 2> /dev/null
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. hostname"
hostname 2>&1
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. free"
free 2>&1
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. du -sxm --exclude=/proc /*"
du -sxm --exclude=/proc /* 2>&1
COUNT=$(($COUNT+1))
echo "-------------------------------------"
fi

NTPSTAT=$(which ntpstat > /dev/null 2>&1)
if [ $? -eq 0 ]
then
	echo "-------------------------------------"
	echo "${COUNT}. ntpstat"
	ntpstat 2>&1
	COUNT=$(($COUNT+1))
	echo "-------------------------------------"
fi

echo "====================================="
echo " Process and file descriptor section"
echo "====================================="
echo "${COUNT}. ulimit -a"
echo "ulimit -a" | /bin/bash 2>&1
COUNT=$(($COUNT+1))
echo "-------------------------------------"
echo "${COUNT}. ps -axef"
ps -axef 2>&1
COUNT=$(($COUNT+1))
echo "-------------------------------------"

echo "${COUNT}. top"
if [ -f ~/.toprc ]
then
	mv ~/.toprc ~/.toprc.ima.bak
fi
echo "RCfile for \"top with windows\" \
Id:a, Mode_altscr=0, Mode_irixps=1, Delay_time=1.000, Curwin=0\
Def	fieldscur=AEHIOQTWKNMbcdfgJplrsuvyzX\
	winflags=97081, sortindx=10, maxtasks=0\
	summclr=6, msgsclr=2, headclr=3, taskclr=2\
Job	fieldscur=ABcefgjlrstuvyzMKNHIWOPQDX\
	winflags=62777, sortindx=0, maxtasks=0\
	summclr=6, msgsclr=6, headclr=7, taskclr=6\
Mem	fieldscur=ANOPQRSTUVbcdefgjlmyzWHIKX\
	winflags=62777, sortindx=13, maxtasks=0\
	summclr=5, msgsclr=5, headclr=4, taskclr=5\
Usr	fieldscur=ABDECGfhijlopqrstuvyzMKNWX\
	winflags=62777, sortindx=4, maxtasks=0\
	summclr=3, msgsclr=3, headclr=2, taskclr=3" > ~/.toprc
top -b -n1
if [ -f ~/.toprc.ima.bak ]
then
	mv ~/.toprc.ima.bak ~/.toprc
fi
COUNT=$(($COUNT+1)) 
echo "-------------------------------------"

IOSTAT=$(which iostat > /dev/null 2>&1)
if [ $? -eq 0 ]
then
	echo "-------------------------------------"
	echo "${COUNT}. iostat 1 5"
	iostat 1 5 2>&1
	COUNT=$(($COUNT+1))
	echo "-------------------------------------"
fi

PERF=$(which perf > /dev/null 2>&1)
if [ $? -eq 0 ]
then
	perf record -o $WORKING_DIR/perf.data -ag -- sleep 5 > /dev/null 2>&1
	perf report -i $WORKING_DIR/perf.data > ${WORKING_DIR}/${PREFIX}_perf.report 2>&1 3>&1
	rm $WORKING_DIR/perf.data 2> /dev/null
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ./${PREFIX}_perf.report"
	FILES_TO_CLEANUP="${FILES_TO_CLEANUP} ${WORKING_DIR}/${PREFIX}_perf.report"
fi

if [ "$PREFIX" == "container" ]
then
	tar -czf ${WORKING_DIR}/${PREFIX}_varlog.tar.gz /var/log --ignore-failed-read > /dev/null 2>&1
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ./${PREFIX}_varlog.tar.gz"
	FILES_TO_CLEANUP="${FILES_TO_CLEANUP} ${WORKING_DIR}/${PREFIX}_varlog.tar.gz"
 
	tar -czf ${WORKING_DIR}/${PREFIX}_etc.tar.gz /etc --ignore-failed-read > /dev/null 2>&1
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ./${PREFIX}_etc.tar.gz"
	FILES_TO_CLEANUP="${FILES_TO_CLEANUP} ${WORKING_DIR}/${PREFIX}_etc.tar.gz"
fi

env > ${WORKING_DIR}/${PREFIX}_environment_vars.txt 2>&1
FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ./${PREFIX}_environment_vars.txt"
FILES_TO_CLEANUP="${FILES_TO_CLEANUP} ${WORKING_DIR}/${PREFIX}_environment_vars.txt"


	tar -czf ${WORKING_DIR}/${PREFIX}_binaries.tar.gz ${IMAPROXY_SOURCE}/bin ${IMAPROXY_SOURCE}/lib64 --ignore-failed-read > /dev/null 2>&1
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ./${PREFIX}_binaries.tar.gz"
	FILES_TO_CLEANUP="${FILES_TO_CLEANUP} ${WORKING_DIR}/${PREFIX}_binaries.tar.gz"
	${IMAPROXY_SOURCE}/bin/extractstackfromcore.sh ${IMAPROXY_SOURCE}
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ${PXY_DATA_DIR}/diag/cores/messagesight_stack.*"
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ${PXY_DATA_DIR}/data"
	FILES_TO_COMPRESS="${FILES_TO_COMPRESS} ${PXY_DATA_DIR}/diag/logs"
	
	for f in imaproxy
	do
		OUT=$(ldd ${IMAPROXY_SOURCE}/bin/${f} 2>&1)
		if [ $? -eq 0 ]
		then
			echo "${COUNT}. ldd on $f"
			echo "$OUT"
			COUNT=$(($COUNT+1)) 
			echo "-------------------------------------"
			echo "${COUNT}. version check on $f"
			strings ${IMAPROXY_SOURCE}/bin/$f | grep version_string 2> /dev/null
			COUNT=$(($COUNT+1))
			echo "-------------------------------------"
		fi		
	done
	for f in ${IMAPROXY_SOURCE}/lib64/*
	do
		OUT=$(ldd $f 2>&1)
		if [ $? -eq 0 ]
		then
			echo "${COUNT}. ldd on $f"
			echo "$OUT"
			COUNT=$(($COUNT+1)) 
			echo "-------------------------------------"
		fi
	done
	
    PID=$(ps -ef | grep "imaproxy -d" | grep -v grep | tail -n 1 | awk '{print $2}')
    if [ ! -z $PID ]
    then
        echo "${COUNT}. pmap -p imaproxy"
        pmap -p $PID 2>&1
        COUNT=$(($COUNT+1))
        echo "-------------------------------------"

        echo "${COUNT}. gstack imaproxy"
        gstack $PID 2>&1
        COUNT=$(($COUNT+1))
        echo "-------------------------------------"

    fi


cd "${WORKING_DIR}" || { echo "Failed to change directory to ${WORKING_DIR}: $?"; exit $?; }
tar -czf ${WORKING_DIR}/${PREFIX}_mustgather.tar.gz ${FILES_TO_COMPRESS} --ignore-failed-read > /dev/null 2>&1
rm -rf -rf ${FILES_TO_CLEANUP} 2> /dev/null
