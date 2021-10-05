#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="Cluster Teardown - 00"

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

#----------------------------------------------------
# Scenario 0 - tearDown
#----------------------------------------------------
# All appliances running
xml[${n}]="tearDown"
timeouts[${n}]=400
scenario[${n}]="${xml[${n}]} - tear down all appliances to singleton machines"
component[1]=cAppDriverLog,m1,"-e|../scripts/cluster.py,-o|-a|tearDown|-l|1|2|3|-v|2"
components[${n}]="${component[1]}"
((n+=1))

#----------------------------------------------------
# Cleanup Scenario  - Delete flow control test related configuration 
#----------------------------------------------------
xml[${n}]="clusterFC_config_cleanup"
timeouts[${n}]=30
scenario[${n}]="${xml[${n}]} - Delete flow control test related configuration   "
component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanup|-c|flow_control/flow_control.cli"
component[2]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanup|-c|flow_control/flow_control.cli|-a|2"
component[3]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanup|-c|flow_control/flow_control.cli|-a|3"
components[${n}]="${component[1]} ${component[2]} ${component[3]}"
((n+=1))

