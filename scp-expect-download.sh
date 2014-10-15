#!/usr/bin/expect
set USER [lindex $argv 0]
set TARGET [lindex $argv 1]
set FILE [lindex $argv 2]
set DESTINATION [lindex $argv 3]
set PASSWD [lindex $argv 4]
set PORT [lindex $argv 5]

trap {
	 set rows [stty rows]
	 set cols [stty columns]
	 stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH

spawn scp -P $PORT $USER@$TARGET:$FILE $DESTINATION

expect {
 "yes/no" { send "yes\r"; exp_continue }
 "password:" { send "$PASSWD\r"; exp_continue }
 "\n" {  }
}
interact
