#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the MQTT test driver
#    driven automated tests.
#       04/25/2012 - MLC - Updated to MQTT test driver
#
#----------------------------------------------------

# Set the name of this set of scenarios

scenario_set_name="MQTTV5 Publish via WSTestDriver"

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
# Test Case 0 - mqtt_policyconfig_setup
#----------------------------------------------------
xml[${n}]="mqtt_v5_policy_setup"
timeouts[${n}]=60
scenario[${n}]="${xml[${n}]} - set policies for the mqttv5 bucket"
component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupv5|-c|mqttv5_cleanstart/policy_mqttv5.cli"
components[${n}]="${component[1]}"
((n+=1))


#----------------------------------------------------
# Test Case  - Clear old RETAINed Msgs
#----------------------------------------------------
xml[${n}]="clear_retained"
timeouts[${n}]=90
scenario[${n}]="${xml[${n}]} - Clear retained before"
component[1]=wsDriverWait,m1,../jms_td_tests/msgdelivery/mqtt_clearRetained.xml,ALL
components[${n}]="${component[1]}"
((n+=1))


#----------------------------------------------------------
# Test Case 1 - MQTTv3 PUB upgrade v3 to V5 Pub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_PubUpV5"
scenario[${n}]="${xml[${n}]} - MQTTv3 PUB upgrade v3 to V5 Pub"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))

#----------------------------------------------------------
# Test Case 1 - MQTTv3 SUB upgrade v3 to V5 Sub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_SubUpV5"
scenario[${n}]="${xml[${n}]} - MQTTv3 SUB upgrade v3 to V5 Sub"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))


#----------------------------------------------------
# Test Case  - Clear leftover RETAINed Msgs
#----------------------------------------------------
xml[${n}]="clear_retained"
timeouts[${n}]=90
scenario[${n}]="${xml[${n}]} - Clear retained after"
component[1]=wsDriverWait,m1,../jms_td_tests/msgdelivery/mqtt_clearRetained.xml,ALL
components[${n}]="${component[1]}"
((n+=1))


#----------------------------------------------------------
# Test Case 1 - MQTTv3 PUB Retain/NoRetain to v3 and V5 Sub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_01"
scenario[${n}]="${xml[${n}]} - Test RETAIN, simple scenario v3 publisher"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 2 - MQTTv5 PUB Retain/NoRetain to v3 and V5 Sub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_01"
scenario[${n}]="${xml[${n}]} - Test RETAIN, simple scenario v5 publisher"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 3 - MQTTv3 PUB 2 Retain/ 1 NoRetain to v3 and V5 Sub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_02"
scenario[${n}]="${xml[${n}]} - Test RETAIN replaced v3 publisher"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 4 - MQTTv5 PUB 2 Retain/ 1 NoRetain to v3 and V5 Sub
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_02"
scenario[${n}]="${xml[${n}]} - Test RETAIN replaced v5 publisher"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 5 - MQTTv3 PUB 2 Retain to v3 and V5 Sub receive RETAIN and as NON_RETAIN
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_03"
scenario[${n}]="${xml[${n}]} - Test RETAIN, receive RETAIN and as NON_RETAIN"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 6 - MQTTv5 PUB 2 Retainto v3 and V5 Sub receive RETAIN and as NON_RETAIN
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_03"
scenario[${n}]="${xml[${n}]} - Test RETAIN, receive RETAIN and as NON_RETAIN"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 7 - MQTTv3 PUB 1 Retain to Durable v3 and V5 Sub receive  as NON_RETAIN
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV3_04"
scenario[${n}]="${xml[${n}]} - Test RETAIN, Durable Subs receive as NON_RETAIN"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 8 - MQTTv5 PUB 1 Retain to Durable v3 and V5 Sub receive  as NON_RETAIN
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_04"
scenario[${n}]="${xml[${n}]} - Test RETAIN, Durable Subs receive as NON_RETAIN"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 9 - PAHO MQTTv5 PUB Msg with Expiry to Durable v3 and V5 Sub receive before expires and not after
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_05"
scenario[${n}]="${xml[${n}]} - Test Message Expiry PAHO"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 9 - WEBSOCKET MQTTv5 PUB Msg with Expiry to Durable v3 and V5 Sub receive before expires and not after
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testWSmqttV5_publishV5_05"
scenario[${n}]="${xml[${n}]} - Test Message Expiry WebSockets"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 10 - PAHO MQTTv5 PUB RETAIN Msg with Expiry to Durable v3 and V5 Sub receive RETAIN before expires and not after
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testmqttV5_publishV5_06"
scenario[${n}]="${xml[${n}]} - Test RETAIN and Message Expiry PAHO"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------------
# Test Case 10 - WEBSOCKET MQTTv5 PUB RETAIN Msg with Expiry to Durable v3 and V5 Sub receive RETAIN before expires and not after
#----------------------------------------------------------
# The prefix of the XML configuration file for the driver
xml[${n}]="testWSmqttV5_publishV5_06"
scenario[${n}]="${xml[${n}]} - Test RETAIN and Message Expiry WebSockets"
timeouts[${n}]=180
# Set up the components for the test in the order they should start
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV3
component[4]=wsDriver,m1,mqttv5_publish/${xml[${n}]}.xml,receiveV5,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))

