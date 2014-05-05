#!/usr/bin/expect
set ROUTE [lindex $argv 0]

# spawn sudo route add -net $ROUTE  netmask 255.255.0.0 gw 10.61.2.2
spawn sudo route -n add -net $ROUTE -netmask 255.255.0.0 10.61.2.2
expect {
	"Password" { send "09092020\r"; exp_continue }
  	"password" { send "09092020\r" }
}

# interact
