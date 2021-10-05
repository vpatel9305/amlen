#! /bin/bash

#-------------------------------------------------------------------
#  This script defines the M1 Setup of LDAP for the MQConn tests
#-------------------------------------------------------------------

# Set the name of this set of scenarios

scenario_set_name="MQConn M1 Setup LDAP"

typeset -i n=0

#----------------------------------------------------
# Enable for LDAP on M1 and initilize  
#----------------------------------------------------
xml[${n}]="MQConn_M1_LDAP_setup"
scenario[${n}]="${xml[${n}]} - Enable and init LDAP"
timeouts[${n}]=40
component[1]=cAppDriverLogWait,m1,"-e|../scripts/ldap-config.sh","-o|-a|start"
component[2]=cAppDriverLogWait,m1,"-e|../scripts/run-cli.sh","-o|-s|setupm1ldap|-c|../common/m1ldap_config.cli"
components[${n}]="${component[1]} ${component[2]}"
((n+=1))


