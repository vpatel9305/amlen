#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="JMS High Availability Cleanup - 04"

typeset -i n=0

# Set up the components for the test in the order they should start
# What is configured here is different for each component and the options are used in run-scenarios.sh:
#
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

if [[ "${FULLRUN}" == "TRUE" ]] ; then
	#----------------------------------------------------
	# Scenario 9 - admin cli cleanup
	#----------------------------------------------------
	# A1 = Primary
	# A2 = Standby
	xml[${n}]="jms_HA_resync_configcleanup"
	timeouts[${n}]=400
	scenario[${n}]="${xml[${n}]} - Delete admin objects from HA Resync tests"
	component[1]=cAppDriverLogWait,m1,"-e|HA/run-cli-primary.sh","-o|HA/resync_config.cli|cleanup"
	components[${n}]="${component[1]}"
	((n+=1))
fi

