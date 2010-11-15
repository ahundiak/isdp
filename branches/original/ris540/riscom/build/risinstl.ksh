#!/bin/ksh
#
# Copyright 1993, Intergraph Corporation, All Rights Reserved
#
# Installation script for RIS
#

# If not already defined, define and truncate log file
if [ -z "$RISLOG" ]
then
	export RISLOG=/usr/tmp/risinstl.log
	[ -f $RISLOG ] && /bin/rm -f $RISLOG
	print "RIS installation log file"   >$RISLOG
	date '+Date: %h %d, %Y   Time: %H:%M:%S' >>$RISLOG
fi

# If not already defined, define and truncate error file
if [ -z "$RISERR" ]
then
	export RISERR=/usr/tmp/risinstl.err
	[ -f $RISERR ] && /bin/rm -f $RISERR
	print "RIS installation error file" >$RISERR
	date '+Date: %h %d, %Y   Time: %H:%M:%S' >>$RISERR
fi

#
# commands needed by this script
#
RM=/bin/rm
KSH=/bin/ksh
RMDIR=/bin/rmdir
AWK=/usr/bin/awk
CUT=/usr/bin/cut

#
# files used in this script
#
RISCONFIGFILE=/etc/risconfig
RISDEVDIRFILE=/usr/ip32/ris/risdir

print_error_and_exit()
{
	print "RIS installation failed"
	exit 1
}

set -e
trap print_error_and_exit 1 2 3 4 6 7 8 9 10 11 12 13 15 19

if [ -z "$RIS_PLATFORM" ]
then
	$RM -f $RISLOG $RISERR
	if [ -d "$RISDEVDIR" ]
	then
		print "Attention Developers! DO NOT USE THIS SCRIPT !!!"
		print "Change to 'riscom/build' directory and use 'mk install'."
		exit 1
	else
		print "ERROR: Environment variable RIS_PLATFORM is not defined."
		print_error_and_exit
	fi
fi

######################################################################
#
#    If there are four arguments, then we are installing RIS for a
#    particular product, and the arguments are PRODDIR and the
#    product name. This is the usual case when we are newprod'ing
#    and this script is called from the newprod install.sh script.
#    Since this involves newprod, we do not need and should not
#    have a /usr/ip32/ris/risdir file to point to the RIS directory;
#    so, remove /usr/ip32/ris/risdir if it exists, and then try to
#    remove the directory /usr/ip32/ris in case risdir was the only
#    reason for having it. In most cases, /usr/ip32/ris/risdir will
#    not exist, and the rmdir of /usr/ip32/ris will not succeed. 
#  
if [ $# -eq 4 ]
then
	typeset -l LO_CASE=$1
	PRODS="$RM -f $RISDEVDIRFILE 2>>$RISERR;
	$RMDIR /usr/ip32/ris 2>>$RISERR;
	$TMPDIR/bin/$LO_CASE.ksh U $2 $3 $4"

######################################################################
#
#	if there are no arguments then we are re-installing a product.
#   This means we remove /usr/ip32/ris/risdir containing RISDEVDIR;
#   Also we locate INGRCONFIG file, since we'd be poking into it to
#   find out, what other RIS products are installed on the system.
#
elif [ $# -eq 0 ]
then
	PRODS="$RM -f $RISDEVDIRFILE 2>>$RISERR;
	$RMDIR /usr/ip32/ris 2>>$RISERR;
	$RM -f $RISCONFIGFILE 2>>$RISERR;"

	if [ $RIS_PLATFORM = "Solaris" ]
	then
		INGRCONFIGFILE=${INGRHOME:-/opt/ingr}/ingrconfig
	else
		INGRCONFIGFILE=/usr/ip32/ingrconfig
	fi
	if [ ! -r "$INGRCONFIGFILE" ]
	then
		print
		print "Fatal Error: $INGRCONFIGFILE missing or unreadable."
		print
		print_error_and_exit
	fi

	##########################################
	#
	#   loop for the entire list of products
	#
	for PRODNAME in risdp risutl riscli risorads risinfds risingds rissybds risorans risinfns risingns risdb2ds
	do
		#####################################################################
		#
		#   we look at the system to see what is installed; For each of the
		#	products, we try to get the installation directory; if there is
		#   a value and the directory exists, then we add that to the list.
		#
		let CUT_VS=4*100
		typeset -u UP_CASE_PROD=$PRODNAME
		STR=$($AWK 'BEGIN{FS="#"} { if ($2 == "'$UP_CASE_PROD'") printf "%s,", $0 }' $INGRCONFIGFILE)
		if [ -n "$STR" ]
		then
			let sp=1
			STRPROD=$(echo $STR |cut -d, -f$sp)
			while [ -n "$STRPROD" ]
			do
				PRODNUM=$(echo $STR | cut -d# -f1)
				PRODN=$(echo $STR | cut -d# -f2)
				PRODDESC=$(echo $STR | cut -d# -f3)
				PRODVER=$(echo $STR | cut -d# -f4)
				PRODDATE=$(echo $STR | cut -d# -f5)
				PRODDIR=$(echo $STR | cut -d# -f6)
				if [ -d "$PRODDIR" ] 
				then
					PRODCONFIG="$PRODNUM#$PRODN#$PRODDESC#$PRODVER#$PRODDATE#$PRODDIR#"
					PRODS="$PRODS print $PRODCONFIG >> $RISCONFIGFILE;"
					#
					# Kludge to find out if we are trying to install
					# a 4.0 or older RIS product. If we are, then we
					# call the UPPER_CASE_PRODNAME.inst script instead
					# of the lower_case_prodname.ksh
					#
					MAJ=$(echo $PRODVER | $CUT -d. -f1)
					MIN=$(echo $PRODVER | $CUT -d. -f2)
					let DEL_VS=${MAJ}*100+${MIN}
					if [ "${DEL_VS}" -le "${CUT_VS}" ]
					then
						PRODS="$PRODS $PRODDIR/bin/$UP_CASE_PROD.inst U $PRODDIR $PRODVER;"
					else
						PRODS="$PRODS $PRODDIR/bin/$PRODNAME.ksh U $PRODDIR $PRODVER;"
					fi
				fi
				let sp=$sp+1
				STRPROD=$(echo $STR |cut -d, -f$sp)
			done
		fi
		#
		#####################################################################
	done
	#
	# end of loop of entire list of products
	#
	##########################################

else
	print "Invalid arguments"
	print_error_and_exit
fi

print "Installing RIS for $RIS_PLATFORM"
$KSH -c "$PRODS"
print "Successful installation of RIS"
exit 0
