#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="NVDIMM Tests outside of IMAServer"

typeset -i n=0


# Set up the components for the test in the order they should start
# What is configured here is different for each component and the options are used in run-scenarios.sh:
#   Tool SubController:
#		component[x]=<subControllerName>,<machineNumber_ismSetup>,<config_file>
# or	component[x]=<subControllerName>,<machineNumber_ismSetup>,"-o \"-x <param> -y <params>\" "
#	where:
#   <SubControllerName>
#		SubController controls and monitors the test case runningon the target machine.
#   <machineNumber_ismSetup>
#		m1 is the machine 1 in ismSetup.sh, m2 is the machine 2 and so on...
#		
# Optional, but either a config_file or other_opts must be specified
#   <config_file> for the subController 
#		The configuration file to drive the test case using this controller.
#	<OTHER_OPTS>	is used when configuration file may be over kill,
#			parameters are passed as is and are processed by the subController.
#			However, Notice the spaces are replaced with a delimiter - it is necessary.
#           The syntax is '-o',  <delimiter_char>, -<option_letter>, <delimiter_char>, <optionValue>, ...
#       ex: -o_-x_paramXvalue_-y_paramYvalue   or  -o|-x|paramXvalue|-y|paramYvalue
#
#   DriverSync:
#	component[x]=sync,<machineNumber_ismSetup>,
#	where:
#		<m1>			is the machine 1
#		<m2>			is the machine 2
#
#   Sleep:
#	component[x]=sleep,<seconds>
#	where:
#		<seconds>	is the number of additional seconds to wait before the next component is started.
#

#---------------------------------------------------------
# Test Case 0 - nvDIMM Fill - Check Basic Test without ISM
#---------------------------------------------------------
# The name of the test case and the prefix of the XML configuration file for the driver
#TODO!: xml should only contain characters valid in a filename, it will be part of the logfile name.
xml[${n}]="NVDIMM_01"

LOOPS=100
ONELOOP=1000
timeouts[${n}]=$(( ${ONELOOP} * ${LOOPS} ))
scenario[${n}]="${xml[${n}]} - NVDIMM- Test Case #0 Fill/Check Test"

# Set up the components for the test in the order they should start
#component[1]=runCommandNow,m1,"../scripts/nvDIMMtest-AUTOMATED.sh ${LOOPS} ${A1_HOST} |tee ${A1_HOST}.log" 
#component[1]=runCommandNow,m1,"../scripts/nvDIMMtest-AUTOMATED.sh ${LOOPS} ${A1_HOST} " 
component[1]=cAppDriverRC,m1,"-e|${M1_TESTROOT}/scripts/nvDIMMtest-AUTOMATED.sh","-o|${LOOPS}|${A1_HOST}"
component[2]=searchLogsEnd,m1,ism-NVDIMM-01.00.comparetest
components[${n}]="${component[1]} ${component[2]} "

###Uncomment the single pound-sign line ('#') if multiple test cases are in this Test Bucket, repeat this block for each test case.
((n+=1))
###----------------------------------------------------
### Test Case 1 - Clean Store clean-up
###----------------------------------------------------
### The name of the test case and the prefix of the XML configuration file for the driver
xml[${n}]="NVDIMM_02"
scenario[${n}]="${xml[${n}]} - NVDIMM:  Test Case #1 clean_store"

# Set up the components for the test in the order they should start
component[1]=cAppDriver,m1,"-e|../common/clean_store.sh",-o_clean
components[${n}]="${component[1]} "

