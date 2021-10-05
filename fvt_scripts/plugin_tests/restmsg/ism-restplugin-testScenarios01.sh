#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the MQTT test driver
#    driven automated tests.
#		03/05/2012 - LAW - Initial Creation
#       04/25/2012 - MLC - Updated to MQTT test driver
#
#----------------------------------------------------

# Set the name of this set of scenarios

scenario_set_name="MessageSight REST Message Plugin Tests"

typeset -i n=0

# Set up the components for the test in the order they should start
# What is configured here is different for each component and the options are used in run-scenarios:
#   Tool SubController:
#		component[x]=<subControllerName>,<machineNumber_ismSetup>,<config_file>
# or	component[x]=<subControllerName>,<machineNumber_ismSetup>,"-o \"-x <param> -y <params>\" "
#	where:
#   <SubControllerName>
#		SubController controls and monitors the test case runningon the target machine.
#   <machineNumber_ismSetup>
#		m1 is the machine 1 in ismSetup, m2 is the machine 2 and so on...
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

#----------------------------------------------------
# Test Case 0 - Run Mocha tests
#----------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="run_mocha_tests"
scenario[${n}]="${xml[${n}]} - Run Mocha test cases for restmsg plugin"
timeouts[${n}]=60
component[1]=cAppDriverLog,m1,"-e|./restmsg/runTests.sh"
components[${n}]="${component[1]}"

((n+=1))
