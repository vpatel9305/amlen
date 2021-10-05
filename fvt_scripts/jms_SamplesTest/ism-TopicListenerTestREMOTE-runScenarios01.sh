#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="Topic Listener Tests"

typeset -i n=0


# Set up the components for the test in the order they should start
# What is configured here is different for each component and the options are used in run-scenarios.sh:
#   Tool SubController:
#		component[x]=<subControllerName>,<machineNumber_ismSetup>,<config_file>
# or	component[x]=<subControllerName>,<machineNumber_ismSetup>,"-o \"-x <param> -y <params>\" "
#	where:
#   <SubControllerName>
#		SubController controls and monitors the test case running on the target machine.
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
# Scenario 1 - TopicListener 1
#----------------------------------------------------

xml[${n}]="TopicListenerTest1"
timeouts[${n}]=40
scenario[${n}]="${xml[${n}]} Sample - TopicListenerTest 128 500 T1 using IPv6 Address"
component[1]=javaAppDriver,m1,-e_TopicListenerTest,-o_128_500_T1,-s-IMAServer=${A1_IPv6_1}-IMAPort=${IMAPort}
component[2]=searchLogsEnd,m1,TopicListenerTestREMOTE_1.comparetest,9
components[${n}]="${component[1]} ${component[2]}"
((n+=1))

#----------------------------------------------------
# Scenario 2 - TopicListener 2
#----------------------------------------------------

xml[${n}]="TopicListenerTest2"
timeouts[${n}]=30
scenario[${n}]="${xml[${n}]} Sample - TopicListenerTest 65536 100 T2"
component[1]=javaAppDriver,m1,-e_TopicListenerTest,-o_65536_100_T2,-s-IMAServer=${A1_IPv4_1}-IMAPort=${IMAPort}
component[2]=searchLogsEnd,m1,TopicListenerTest_2.comparetest,9
components[${n}]="${component[1]} ${component[2]}"
((n+=1))

#----------------------------------------------------
# Scenario 3 - TopicListener 3
#----------------------------------------------------

xml[${n}]="TopicListenerTestCfg3"
timeouts[${n}]=40
scenario[${n}]="${xml[${n}]} Sample - TopicListenerTestCfg 128 50 T3 5 5 using IPv6 Address"
component[1]=javaAppDriver,m1,-e_TopicListenerTestCfg,-o_128_50_T3_5_5,-s-IMAServer=${A1_IPv6_1}-IMAPort=${IMAPort}
component[2]=searchLogsEnd,m1,TopicListenerTestCfgREMOTE_3.comparetest,9
components[${n}]="${component[1]} ${component[2]}"
((n+=1))
