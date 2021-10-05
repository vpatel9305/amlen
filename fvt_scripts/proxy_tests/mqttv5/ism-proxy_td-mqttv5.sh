#! /bin/bash

#----------------------------------------------------
#  This script defines the scenarios for the ism Test Automation Framework.
#  It can be used as an example for defining other testcases.
#----------------------------------------------------

# TODO!:  MODIFY scenario_set_name to a short description appropriate for your testcase
# Set the name of this set of scenarios

scenario_set_name="MQTTv5 tests to PROXY"
scenario_directory="mqttv5"
sceanrio_file="ism-proxy_td-mqttv5.sh"
scenario_at=" "+${scenario_directory}+"/"+${sceanrio_file}

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

if [[ "$A1_LDAP" == "FALSE" ]] ; then
    #----------------------------------------------------
    # Enable for LDAP on M1 and initilize  
    #----------------------------------------------------
    xml[${n}]="mqttV5_M1_LDAP_setup"
    scenario[${n}]="${xml[${n}]} - Enable and init LDAP on M1 ${scenario_at}"
    timeouts[${n}]=40
    component[1]=cAppDriverLogWait,m1,"-e|../scripts/ldap-config.sh","-o|-a|start"
    component[2]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupm1ldap|-c|../common/m1ldap_config.cli"
    components[${n}]="${component[1]} ${component[2]}"
    ((n+=1))
fi


#----------------------------------------------------
# Test Case 0 - mqtt_ws1 start Proxy
#----------------------------------------------------
xml[${n}]="start_proxy"
scenario[${n}]="${xml[${n}]} - Test MQTT/WebSocket connect to an IP address and port ${scenario_at}"
timeouts[${n}]=60
# Set up the components for the test in the order they should start
component[1]=cAppDriver,m1,"-e|./startProxy.sh","-o|../common/proxy.mqttV5.cfg"
# Configure policies
component[2]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupv5|-c|mqttv5/policy_mqttv5.cli"
component[3]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupv5exp|-c|mqttv5/policy_mqttv5.cli"
component[4]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setup|-c|policy_config.cli"
### component[5]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setup|-c|tls_policy_config.cli"
components[${n}]="${component[3]} ${component[2]} ${component[1]} ${component[4]} "
((n+=1))


#----------------------------------------------------
# Test Case 1 - Connect/check/Disconnect/check with CleanStart TRUE - WebSockets MQTTv5 Client
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_01"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - WS mqttv5 connect01"
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,Test
components[${n}]="${component[1]} "

((n+=1))

#----------------------------------------------------
# Test Case 1b - check connect options - PAHO MQTTv5 Client
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_01b"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - PAHO mqttv5 connect01b"
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,Test
components[${n}]="${component[1]} "

((n+=1))


#----------------------------------------------------
# Test Case 2 - Publish, Subscribe/Receive - WebSockets MQTTv5 Client
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_02"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - mqttv5 publish, subscribe, receive"
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]}"

((n+=1))

#----------------------------------------------------------
# Test Case 4 - PAHO MQTTv5 Client Connect/Disconnect 
#                  with CleanStart TRUE and Session Expiry
#----------------------------------------------------------
xml[${n}]="testproxy_mqttv5_04"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - mqttv5 Connect, Disconnect with Expiry"
component[1]=sync,m1
component[2]=wsDriverWait,m1,mqttv5/${xml[${n}]}.xml,clearSessions
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,Test
components[${n}]="${component[1]} ${component[2]} ${component[3]}"

((n+=1))

#----------------------------------------------------
# Test Case 5 - PAHO MQTTv5 Client Connect/Disconnect 
#                  with CleanStart TRUE and Durable Session Expiry
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_05"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - mqttv5 session expiry with connection policy"
component[1]=wsDriverWait,m1,mqttv5/${xml[${n}]}.xml,clearSessions
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,Test
components[${n}]="${component[1]} ${component[2]} "

((n+=1))

#----------------------------------------------------
# Test Case 7 - will message normal close
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_07"
scenario[${n}]="${xml[${n}]} - MQTTv5 Normal disconnect does not send will message with will delay"
timeouts[${n}]=60
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))

#----------------------------------------------------
# Test Case 8 - will message abnormal close - should send
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_08"
scenario[${n}]="${xml[${n}]} - MQTTv5 Abnormal disconnect to send will message with will delay"
timeouts[${n}]=60
component[1]=sync,m1
component[2]=wsDriverNocheck,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive,-o_-l_9
component[4]=killComponent,m1,2,1,testproxy_mqttv5_08
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))

#----------------------------------------------------
# Test Case 9 - will message normal close with rc=4 willdelay>expiry
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_09"
scenario[${n}]="${xml[${n}]} - MQTTv5 Disconnect with rc=4 to publish will msg after delay"
timeouts[${n}]=60
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))


#----------------------------------------------------
# Test Case 9b - will message normal close with rc=4 willdelay<expiry
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_09b"
scenario[${n}]="${xml[${n}]} - MQTTv5 Disconnect with rc=4 to publish will msg after delay"
timeouts[${n}]=60
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))


#----------------------------------------------------
# Test Case 10 - session expiry over restart
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_10"
timeouts[${n}]=300
scenario[${n}]="${xml[${n}]} - MQTTv5 session expiry across server restart"
component[1]=wsDriverWait,m1,mqttv5/${xml[${n}]}.xml,clearSessions
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,Test
components[${n}]="${component[1]} ${component[2]}"

((n+=1))

#----------------------------------------------------
# Test Case 11 - will delay - create new connection before will delay
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_11"
scenario[${n}]="${xml[${n}]} - MQTTv5 Will delay - create new connection before delay - no send"
timeouts[${n}]=160
component[1]=sync,m1
component[2]=wsDriverNocheck,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive,-o_-l_9
component[4]=killComponent,m1,2,1,${xml[${n}]}
components[${n}]="${component[1]} ${component[2]} ${component[3]} ${component[4]} "

((n+=1))


#----------------------------------------------------
# Test Case 12 - will delay - cclient steals and  will delay
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_12"
scenario[${n}]="${xml[${n}]} - MQTTv5 Will delay - clientSteals and Clean Session"
timeouts[${n}]=160
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive,-o_-l_9
components[${n}]="${component[1]} ${component[2]} ${component[3]}  "

((n+=1))

#----------------------------------------------------
# Test Case 13 - big publish
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_13"
scenario[${n}]="${xml[${n}]} - MQTTv5 publish many messages"
timeouts[${n}]=360
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))

#----------------------------------------------------
# Test Case 14 - user properties on publish
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_14"
scenario[${n}]="${xml[${n}]} - MQTTv5 publish user properties"
timeouts[${n}]=360
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))



#----------------------------------------------------
# Test Case 14 - GVT user properties on publish
#----------------------------------------------------
xml[${n}]="testproxy_mqttv5_14_GVT"
scenario[${n}]="${xml[${n}]} - MQTTv5 publish GVT user properties"
timeouts[${n}]=360
component[1]=sync,m1
component[2]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,publish
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive
components[${n}]="${component[1]} ${component[2]} ${component[3]} "

((n+=1))

#----------------------------------------------------
# Test Case 15 - gvt subscribe topic #
#----------------------------------------------------
xml[${n}]="testproxy_mqttV5_gvt01"
timeouts[${n}]=30
scenario[${n}]="${xml[${n}]} - Test ability use GVT characters in topic and ClientID [ ${xml[${n}]}.xml ]"
###  MOVED SETUP  ###component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setup|-c|policy_config.cli"
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,ALL,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"
components[${n}]="${component[1]}"

((n+=1))

#----------------------------------------------------
# Test Case 16 - gvt WILL Topic QoS 2
#----------------------------------------------------
xml[${n}]="testproxy_mqttV5_gvt02"
scenario[${n}]="${xml[${n}]} - MQTTv5 publish user properties"
timeouts[${n}]=90
scenario[${n}]="${xml[${n}]} - Test ability to connect over an SSL connection [ ${xml[${n}]}.xml ]"

### ACTUALLY NOT USING LDAP for USERs in GVT03|05|06 with TLS Config  - DELETE_USERS was causing an error here anyway
#component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|DELETE_USERS|-c|../common/cli_gvt_user_and_group_test.cli"
# RENUMBERED:
component[1]=sync,m1
component[2]=wsDriverNocheck,m1,mqttv5/${xml[${n}]}.xml,publish,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"
component[3]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,receive,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"
component[4]=killComponent,m1,2,1,testproxy_mqttV5_gvt02

components[${n}]="                ${component[1]} ${component[2]} ${component[3]} ${component[4]}"

((n+=1))


#----------------------------------------------------
# Test Case 0 - SWITCH Proxy Config
#----------------------------------------------------
xml[${n}]="switch_proxy_config"
scenario[${n}]="${xml[${n}]} - Test MQTT/WebSocket connect to an IP address and port ${scenario_at}"
timeouts[${n}]=60
# Set up the components for the test in the order they should start
###  
### See NOTE at top of GVT03/05/06
###   
component[1]=cAppDriverWait,m1,"-e|./killProxy.sh"
component[2]=cAppDriver,m1,"-e|./startProxy.sh","-o|proxyTLS.cfg"
components[${n}]="${component[1]} ${component[2]} "
((n+=1))


#----------------------------------------------------
# Test Case 17 - gvt SSL Properties, , ClientId, User and Password
#----------------------------------------------------
xml[${n}]="testproxy_mqttV5_gvt03"
timeouts[${n}]=90
scenario[${n}]="${xml[${n}]} - Test ability to connect with GVT characters in user/password [ ${xml[${n}]}.xml ]"

### ACTUALLY NOT USING LDAP for USERs in GVT03|05|06  -- but I will leave here incase that can be fixed
#component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|ADD_USERS|-c|../common/cli_gvt_user_and_group_test.cli"
#RENUMBERED:
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,ALL,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"

components[${n}]=" ${component[1]}"

((n+=1))

#----------------------------------------------------
# Test Case 18 - gvt SSL, ClientId, User and Password
#----------------------------------------------------
xml[${n}]="testproxy_mqttV5_gvt05"
timeouts[${n}]=30
scenario[${n}]="${xml[${n}]} - Test ability to connect with GVT characters C4 in user/password [ ${xml[${n}]}.xml ]"
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,ALL,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"
components[${n}]="${component[1]}"

((n+=1))

#----------------------------------------------------
# Test Case 19 - gvt SSL, ClientId, User and Password
#----------------------------------------------------
xml[${n}]="testproxy_mqttV5_gvt06"
timeouts[${n}]=30
scenario[${n}]="${xml[${n}]} - Test ability to connect with GVT characters E3 in user/password [ ${xml[${n}]}.xml ]"
component[1]=wsDriver,m1,mqttv5/${xml[${n}]}.xml,ALL,,"-s|BITFLAG=-Djavax.net.ssl.trustStore=../common/ibm.jks"
components[${n}]="${component[1]}"

((n+=1))

#----------------------------------------------------
# Finally - policy_cleanup and gather proxy logs.  
#----------------------------------------------------
xml[${n}]="mqtt_v5_policy_cleanup"
timeouts[${n}]=90
scenario[${n}]="${xml[${n}]} - Cleanup policies for v5 connect bucket ${scenario_at}"
component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanupv5|-c|mqttv5/policy_mqttv5.cli"
component[2]=cAppDriverLog,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanupv5exp|-c|mqttv5/policy_mqttv5.cli"
component[3]=cAppDriverLog,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanup|-c|policy_config.cli"
component[4]=cAppDriverLog,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanup|-c|tls_policy_config.cli"
component[5]=cAppDriver,m1,"-e|../common/rmScratch.sh"
component[6]=cAppDriver,m1,"-e|./killProxy.sh"
components[${n}]="${component[1]} ${component[2]} ${component[3]}    ${component[5]} ${component[6]}"
((n+=1))



if [[ "$A1_LDAP" == "FALSE" ]] ; then
    #----------------------------------------------------
    # Cleanup and disable LDAP on M1
    #----------------------------------------------------
    xml[${n}]="mqtt_mqttv5__M1_LDAP_cleanup"
    scenario[${n}]="${xml[${n}]} - disable and clean LDAP on M1 ${scenario_at}"
    timeouts[${n}]=10
    component[1]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|cleanupm1ldap|-c|../common/m1ldap_config.cli"
    component[2]=cAppDriverLogWait,m1,"-e|../scripts/ldap-config.sh","-o|-a|stop"
    components[${n}]="${component[1]} ${component[2]}"
    ((n+=1))
fi
