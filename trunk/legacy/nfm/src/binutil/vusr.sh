#!/bin/ksh
# verify the existence of a user name or alias on a given machine
#
# sample usage:
#	vusr cgsp@sprite
#	vusr montnaro
#	vusr lorensen@dwaskill egan smithwd@crd

if [ $# = 0 ] ; then
    echo "usage: `basename $0` alias ..."
    echo "       where alias can be of the form \"user@node\" or \"user\""
    exit 1
fi

while [ $# -gt 0 ] ; do
    alias=`echo $1 | sed -e 's/@.*//'`
    node=`echo $1 | sed -e 's/^[^@]*$//' -e 's/\(.*\)@\(.*\)/\2/'`

    if [ x$node = x ] ; then
	node=`uname -n`
    fi

    # try to open connection to SMTP server on $node. No real provision is
    # made for errors in attempts to connect, unless the node is unknown.
    telnet $node 25 2>/dev/null |&

    read -p line	# Trying...
    if [ "$line" = "$node: unknown host" ] ; then
	print -p quit
	echo $line
	shift
	continue
    fi

    read -p line	# Connected ...
    read -p line	# Escape ...
    read -p line	# 220 ...

    # check to see if we connected okay
    if [ "${line%% *}" != "220" ] ; then
	echo Unable to connect to host $node:
	shift
	continue
    fi

    # ask the SMTP server about $alias
    print -p "vrfy $alias"
    read -p line

    if [ "${line%% *}" = "550" ] ; then
	# unknown user
	echo "${line#* } on host $node."
    elif [ "${line%%-*}" = "250" -o "${line%% *}" = "250" ] ; then
	# one or more 250 lines follow with the alias expansion
	print -n "$alias@$node == "
	while [ "${line%%-*}" = "250" ] ; do
	    echo "${line#*-}"
	    print -n "	+ "
	    read -p line
	done
	echo "${line#* }"
    else
	# unknown response from SMTP
	echo "${line}"
    fi

    print -p "quit"

    shift
done
