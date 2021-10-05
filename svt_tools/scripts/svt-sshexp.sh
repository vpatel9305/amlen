#!/usr/bin/expect -f
### To be used for setting up production release ISM appliances that do no have busybox
### create the known_hosts file on the ISM server for the client specified
### syntax: build_known_hosts ismServerIP ismClientIP (ie. build_known_hosts 10.10.10.10 10.10.10.10)
############## TO ADD ALL AF client IPs run the following bash commands from directory containing globalVARS.xml #####################################
### for i in `grep mar globalVARS.xml | grep client | awk -F '[,,]' '{print $3}' | sed s/\'//g | sed s/\,//g | tr -d "["` ; do ./build_known_hosts.sh ISM_SERVER_IP $i ; done
### for i in `grep mar globalVARS.xml | grep client | awk -F '[,,]' '{print $4}' | sed s/\'//g | sed s/\,//g | tr -d "["` ; do ./build_known_hosts.sh ISM_SERVER_IP $i ; done
### ./build_known_hosts.sh 10.10.10.10 10.10.10.10
#######################################################################################################################################################
set timeout -1

set server [lindex $argv 0]
set c1 [lindex $argv 1]
set c2 [lindex $argv 2]
set c3 [lindex $argv 3]
set c4 [lindex $argv 4]

spawn ssh $server

expect {
  "> " { }
  "(yes/no)? " {
       send "yes\n"
       expect { "> " }
  }
  default {
       send_user "SSH to ISM Server Failed\n"
       exit
  }
}

send "$c1 $c2 $c3 $c4\n"
expect {
  "> " { }
  "assword: " {
       send "admin\n"
       expect { "> " }
  }
  "(yes/no)? " {
       send "yes\n"
       expect { "> " }
  }
  default {
       send_user "SSH to ISM Server Failed\n"
       exit
  }
}

send "exit\n"
send_user "Finshed\n"
exit
