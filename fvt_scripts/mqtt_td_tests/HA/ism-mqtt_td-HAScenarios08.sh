#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="MQTT HAScenarios08 via WSTestDriver"

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

# if [[ "$A1_LDAP" == "FALSE" ]] ; then
#     #----------------------------------------------------
#     # Enable for LDAP on M1 and initilize  
#     #----------------------------------------------------
#     xml[${n}]="mqtt_sharedsub_00_M1_LDAP_setup"
#     scenario[${n}]="${xml[${n}]} - Enable and init LDAP on M1"
#     timeouts[${n}]=40
#     component[1]=cAppDriverLogWait,m1,"-e|../scripts/ldap-config.sh","-o|-a|start"
#     component[2]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupm1ldap|-c|../common/m1ldap_config.cli"
#     components[${n}]="${component[1]} ${component[2]}"
#     ((n+=1))
# fi

#----------------------------------------------------
# restart a2 so a1 is primary again
#----------------------------------------------------
xml[${n}]="makeA1primary"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - Restart A2 so A1 is primary again "
component[1]=cAppDriverWait,m1,"-e|../scripts/serverControl.sh","-o|-a|restartServer|-i|2"
component[2]=cAppDriverLogWait,m1,"-e|../scripts/cluster.py,-o|-a|verifyStatus|-m|2|-t|60|-v|2|-s|STATUS_STANDBY"
components[${n}]="${component[1]} ${component[2]}"
((n+=1))


#----------------------------------------------------
# Test Case 0 - policy setup
#----------------------------------------------------
xml[${n}]="mqtt_iotp_mon_policy_setup"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - set policies for the IoTP monitoring HA bucket"
component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupMon|-c|HA/policy_iotp_monitoring.cli"
components[${n}]="${component[1]}"
((n+=1))


#----------------------------------------------------
# Test Case 1 - testmqtt_iotp_monitoring_cleanup_01
#----------------------------------------------------
xml[${n}]="testmqtt_iotp_monitoring_cleanup_01"
timeouts[${n}]=320
scenario[${n}]="${xml[${n}]} - fixup of IoTP monitoring retained msgs on startup: devices"
component[1]=sync,m1
component[2]=wsDriverWait,m1,HA/${xml[${n}]}.xml,test
components[${n}]="${component[1]} ${component[2]}"
((n+=1))

#----------------------------------------------------
# restart a2 so a1 is primary again
#----------------------------------------------------
xml[${n}]="makeA1primary"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - Start A1 and Restart A2 so A1 is primary again "
component[1]=cAppDriverLogWait,m1,"-e|../scripts/haFunctions.py,-o|-a|startServer|-m1|1"
component[2]=cAppDriverWait,m1,"-e|../scripts/serverControl.sh","-o|-a|restartServer|-i|2"
component[3]=cAppDriverLogWait,m1,"-e|../scripts/cluster.py,-o|-a|verifyStatus|-m|2|-t|60|-v|2|-s|STATUS_STANDBY"
components[${n}]="${component[1]} ${component[2]} ${component[3]}"
((n+=1))

#----------------------------------------------------
# Test Case 1b - testmqtt_iotp_monitoring_cleanup_02 - all behaviors
#----------------------------------------------------
xml[${n}]="testmqtt_iotp_monitoring_cleanup_02"
timeouts[${n}]=320
scenario[${n}]="${xml[${n}]} - fixup of IoTP monitoring retained msgs on startup: all behaviors"
component[1]=sync,m1
component[2]=wsDriverWait,m1,../jms_td_tests/msgdelivery/mqtt_clearRetained.xml,ALL
component[3]=wsDriverWait,m1,HA/${xml[${n}]}.xml,test
components[${n}]="${component[1]} ${component[2]} ${component[3]}"
((n+=1))


#----------------------------------------------------
# restart a2 so a1 is primary again
#----------------------------------------------------
xml[${n}]="makeA1primary"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - Start A1 and Restart A2 so A1 is primary again "
component[1]=cAppDriverLogWait,m1,"-e|../scripts/haFunctions.py,-o|-a|startServer|-m1|1"
component[2]=cAppDriverWait,m1,"-e|../scripts/serverControl.sh","-o|-a|restartServer|-i|2"
component[3]=cAppDriverLogWait,m1,"-e|../scripts/cluster.py,-o|-a|verifyStatus|-m|2|-t|60|-v|2|-s|STATUS_STANDBY"
components[${n}]="${component[1]} ${component[2]} ${component[3]}"
((n+=1))

#----------------------------------------------------
# Test Case 1b - testmqtt_iotp_monitoring_cleanup_01b - many devices
#----------------------------------------------------
xml[${n}]="testmqtt_iotp_monitoring_cleanup_01b"
timeouts[${n}]=620
scenario[${n}]="${xml[${n}]} - fixup of IoTP monitoring retained msgs on startup: many devices"
component[1]=sync,m1
component[2]=wsDriverWait,m1,../jms_td_tests/msgdelivery/mqtt_clearRetained.xml,ALL
component[3]=wsDriverWait,m1,HA/${xml[${n}]}.xml,test
components[${n}]="${component[1]} ${component[2]} ${component[3]}"
((n+=1))


#----------------------------------------------------
# start A1 so servers are up
#----------------------------------------------------
xml[${n}]="startA1"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - Start A1 so both servers are up "
component[1]=cAppDriverLogWait,m1,"-e|../scripts/haFunctions.py,-o|-a|startServer|-m1|1"
component[2]=cAppDriverLogWait,m1,"-e|../scripts/cluster.py,-o|-a|verifyStatus|-m|1|-t|60|-v|2|-s|STATUS_STANDBY"
components[${n}]="${component[1]} ${component[2]}"
((n+=1))




#----------------------------------------------------
# Finally - policy_cleanup
#----------------------------------------------------
xml[${n}]="mqtt_iotp_mon_policy_cleanup"
timeouts[${n}]=80
scenario[${n}]="${xml[${n}]} - cleanup policies for the iotp montioring HA bucket"
component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanupMon|-c|HA/policy_iotp_monitoring.cli|-a|2"
components[${n}]="${component[1]}"
((n+=1))

# if [[ "$A1_LDAP" == "FALSE" ]] ; then
#     #----------------------------------------------------
#     # Cleanup and disable LDAP on M1 
#     #----------------------------------------------------
#     xml[${n}]="mqtt_sharedsub_00_M1_LDAP_cleanup"
#     scenario[${n}]="${xml[${n}]} - disable and clean LDAP on M1"
#     timeouts[${n}]=10
#     component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanupm1ldap|-c|../common/m1ldap_config.cli"
#     component[2]=cAppDriverLogWait,m1,"-e|../scripts/ldap-config.sh","-o|-a|stop"
#     components[${n}]="${component[1]} ${component[2]}"
#     ((n+=1))
# fi

