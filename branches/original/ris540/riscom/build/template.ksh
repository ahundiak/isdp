#
#	Section 1 contains all the initialization code: setting up variables,
#	commands and shell functions.  All scripts should use this section.
#
SECTION_1:#!/bin/ksh
SECTION_1:#
SECTION_1:# Copyright 1993, Intergraph Corporation, All Rights Reserved
SECTION_1:#
SECTION_1:#----------------------------------------------------------------
SECTION_1:# replace_this_word installation script
SECTION_1:#----------------------------------------------------------------
SECTION_1:
SECTION_1:set -e
SECTION_1:
SECTION_1u:# $1 is dummy; passed for old-time sake (i.e. compatibility)
SECTION_1u:PRODDIR=$2
SECTION_1u:PRODVERSION=$3
SECTION_1u:if [ $# -eq 4 ]
SECTION_1u:then
SECTION_1u:	REALDIR=$4
SECTION_1u:else
SECTION_1u:	REALDIR=$PRODDIR
SECTION_1u:fi
SECTION_1u:
SECTION_1u:EXE_PATH=$PRODDIR/bin
SECTION_1u:TCPSRV_PATH=$EXE_PATH
SECTION_1u:REAL_PATH=$REALDIR/bin
SECTION_1u:
SECTION_1d:PROJECT="project_name"
SECTION_1d:EXE_PATH=$RISDEVDIR/$PROJECT/bin/$BINDIR
SECTION_1d:TCPSRV_PATH=$RISDEVDIR/riscom/bin/$BINDIR
SECTION_1d:REAL_PATH=$EXE_PATH
SECTION_1d:PRODVERSION=$RIS_VER
SECTION_1d:
SECTION_1:EXE_NAME="executable_name"
SECTION_1:
SECTION_1:#----------------------------------------------------------------
SECTION_1:# Setup files and commands needed by this script.
SECTION_1:#----------------------------------------------------------------
SECTION_1:
SECTION_1:RM=/bin/rm
SECTION_1:CAT=/bin/cat
SECTION_1:KILL=/bin/kill
SECTION_1:GREP=/bin/grep
SECTION_1:AWK=/usr/bin/awk
SECTION_1:if [ $RIS_PLATFORM = "SunOS4" ]
SECTION_1:then
SECTION_1:	PS="/bin/ps -aux"
SECTION_1:else
SECTION_1:	PS="/bin/ps -ef"
SECTION_1:fi
SECTION_1:
SECTION_1:RISTMP=/usr/tmp/$EXE_NAME.tmp
SECTION_1:
SECTION_1:#----------------------------------------------------------------
SECTION_1:# Install the product
SECTION_1:#----------------------------------------------------------------
SECTION_1:print "\tInstalling replace_this_word"
SECTION_1:
#
#	Section 2,3 makes the network installations.
#	This will be used by the servers and the client.
#
SECTION_2:#----------------------------------------------------------------
SECTION_2:# TCP installation
SECTION_2:#----------------------------------------------------------------
SECTION_2:
SECTION_2:TCPSVC=/etc/services
SECTION_2:TCPCNF=/etc/inetd.conf
SECTION_2:
SECTION_2:if [ "$RIS_PLATFORM" != CLIX -o -d "$(proddata +%p TCPIP)" ]
SECTION_2:then
SECTION_2:	print "\t\tSetting up TCP connection"
SECTION_2:	$CAT $TCPSVC > $RISTMP
SECTION_2:	$GREP -v "180/" $RISTMP > $TCPSVC
SECTION_2:	print "ristcpsrv	180/tcp		# RIS tcp server" >> $TCPSVC
SECTION_2:	$RM -f $RISTMP 2>>$RISERR
SECTION_2:	$CAT $TCPCNF > $RISTMP
SECTION_2:	$GREP -v "ristcpsrv" $RISTMP > $TCPCNF
SECTION_2:	print "ristcpsrv	stream tcp nowait root $TCPSRV_PATH/ristcpsr ristcpsr T" >> $TCPCNF
SECTION_2:	$RM -f $RISTMP 2>>$RISERR
SECTION_2:	(set +e; $KILL -1 $($PS | $AWK '/inetd/ {print $2}') 2>/dev/null; :)
SECTION_2:fi
SECTION_2:
SECTION_3:get_version()
SECTION_3:{
SECTION_3:	echo $1 | awk 'BEGIN{FS="."} { printf "%d_%d_X", $1, $2 }'
SECTION_3:}
SECTION_3:
SECTION_3:if [ "$RIS_PLATFORM" = "CLIX" ]
SECTION_3:then
SECTION_3:	LN=/bin/ln
SECTION_3:	MKDIR=/bin/mkdir
SECTION_3:	SORT=/bin/sort
SECTION_3:	DNPSRV=/usr/lib/servers.reg
SECTION_3:	DNPENTRY="dnp_entry_name"
SECTION_3:	XNSSRV=server.dat
SECTION_3:	XNSENTRY="xns_entry_name"
SECTION_3:	DATES=/usr/bin/dates
SECTION_3:	PRODDATA=/usr/bin/proddata
SECTION_3:	CONFIGFILE=/usr/ip32/ingrconfig
SECTION_3:fi
SECTION_3:
SECTION_3:#----------------------------------------------------------------
SECTION_3:# DNP installation
SECTION_3:#----------------------------------------------------------------
SECTION_3:
SECTION_3:if [ "$RIS_PLATFORM" = "CLIX" ]
SECTION_3:then
SECTION_3:	set +e
SECTION_3:	DNPDIR=$($PRODDATA "+%p" "DNP")
SECTION_3:	set -e
SECTION_3:	if [ -d "$DNPDIR" -a "$DNPENTRY" ]
SECTION_3:	then
SECTION_3:		print "\t\tSetting up DNP connection"
SECTION_3:		set -e
SECTION_3:		if [ -s "$DNPSRV" ]
SECTION_3:		then
SECTION_3:			DNPSRV_ENTRY=${DNPENTRY}_$(get_version $PRODVERSION)
SECTION_3:			$GREP -vi $DNPSRV_ENTRY $DNPSRV > $RISTMP
SECTION_3:			print "0	$DNPSRV_ENTRY $EXE_PATH/$EXE_NAME" >> $RISTMP
SECTION_3:			#
SECTION_3:			# do not use mv because this file is a symbolic link
SECTION_3:			#
SECTION_3:			$CAT $RISTMP > $DNPSRV
SECTION_3:			$RM -f $RISTMP 2>>$RISERR
SECTION_3:			if [ "$(get_version $PRODVERSION)" = "5_1_X" ]
SECTION_3:			then
SECTION_3:				DNPSRV_ENTRY=${DNPENTRY}_5_0_X
SECTION_3:				$GREP -vi $DNPSRV_ENTRY $DNPSRV > $RISTMP
SECTION_3:				print "0 $DNPSRV_ENTRY $EXE_PATH/$EXE_NAME" >> $RISTMP
SECTION_3:				#
SECTION_3:				# do not use mv because this file is a symbolic link
SECTION_3:				#
SECTION_3:				$CAT $RISTMP > $DNPSRV
SECTION_3:				$RM -f $RISTMP 2>>$RISERR
SECTION_3:			fi
SECTION_3:		else
SECTION_3:			print
SECTION_3:			print "File $DNPSRV does not exist or is empty - RIS DNP NOT initialized."
SECTION_3:			print "After DNP is properly installed, rerun the risinstall script."
SECTION_3:			print
SECTION_3:		fi
SECTION_3:	fi
SECTION_3:fi
SECTION_3:
SECTION_3:#----------------------------------------------------------------
SECTION_3:# XNS installation
SECTION_3:#----------------------------------------------------------------
SECTION_3:
SECTION_3:if [ "$RIS_PLATFORM" = "CLIX" ]
SECTION_3:then
SECTION_3:	set +e
SECTION_3:	XNSDIR=$($PRODDATA "+%p" "XNSINGR")
SECTION_3:	set -e
SECTION_3:	if [ -d "$XNSDIR" ]
SECTION_3:	then
SECTION_3:		print "\t\tSetting up XNS connection"
SECTION_3:		if [ "$XNSENTRY" ]
SECTION_3:		then
SECTION_3:			$GREP -v "^!$XNSENTRY!" $XNSDIR/$XNSSRV > $RISTMP
SECTION_3:			print "!$XNSENTRY!UP!$EXE_PATH/$EXE_NAME X!!" >> $RISTMP
SECTION_3:			$SORT -n -t! +1 -2 $RISTMP > $XNSDIR/$XNSSRV
SECTION_3:			$RM -f $RISTMP 2>>$RISERR
SECTION_3:		fi
SECTION_3:		if [ ! -d "/usr/ip32/ris" ]
SECTION_3:		then
SECTION_3:			$MKDIR /usr/ip32/ris
SECTION_3:		fi
SECTION_3:		if [ ! -d "/usr/ip32/ris/links" ]
SECTION_3:		then
SECTION_3:			$MKDIR /usr/ip32/ris/links
SECTION_3:		fi
SECTION_3:		TARGETFILE=/usr/ip32/ris/links/$EXE_NAME.$(get_version $PRODVERSION)
SECTION_3:		if [ -L "$TARGETFILE" ]
SECTION_3:		then
SECTION_3:			$RM -f $TARGETFILE 2>>$RISERR
SECTION_3:		fi
SECTION_3:		umask 022
SECTION_3:		$LN -fs $EXE_PATH/$EXE_NAME $TARGETFILE
SECTION_3:		if [ "$(get_version $PRODVERSION)" = "5_1_X" ]
SECTION_3:		then
SECTION_3:			TARGETFILE=/usr/ip32/ris/links/$EXE_NAME.5_0_X
SECTION_3:			if [ -L "$TARGETFILE" ]
SECTION_3:			then
SECTION_3:				$RM -f $TARGETFILE 2>>$RISERR
SECTION_3:			fi
SECTION_3:			umask 022
SECTION_3:			$LN -fs $EXE_PATH/$EXE_NAME $TARGETFILE
SECTION_3:		fi
SECTION_3:	fi
SECTION_3:fi
SECTION_3:
#
#	Section 4 changes the owner and permissions for products with a single
#	executable.  This will be called by all the servers.
#
SECTION_4:#----------------------------------------------------------------
SECTION_4:#	Change owner and permissions
SECTION_4:#----------------------------------------------------------------
SECTION_4:
SECTION_4:if [ "$RIS_PLATFORM" = "SunOS4" ]
SECTION_4:then
SECTION_4:	CHOWN=/usr/etc/chown
SECTION_4:	CHMOD=/usr/5bin/chmod
SECTION_4:else
SECTION_4:	CHOWN=/bin/chown
SECTION_4:	CHMOD=/bin/chmod
SECTION_4:fi
SECTION_4:
SECTION_4:$CHOWN root $REAL_PATH/$EXE_NAME 2>>$RISERR
SECTION_4:$CHMOD 4755 $REAL_PATH/$EXE_NAME 2>>$RISERR
SECTION_4:
#
#	Everybody's got to exit
#
SECTION_1:#----------------------------------------------------------------
SECTION_1:#	Exit
SECTION_1:#----------------------------------------------------------------
SECTION_1:set +e
SECTION_1:exit 0
