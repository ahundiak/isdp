#!/bin/ksh
#
# Installation script for RIS Source Code Developement Machine
#

export RISLOG=/usr/tmp/devinstl.log
export RISERR=/usr/tmp/devinstl.err

#
# commands needed by this script
#
RM=/bin/rm
SU=/bin/su
CHMOD=/bin/chmod
MKDIR=/bin/mkdir

#
# files used in this script
#
RISDEVDIRFILE=/usr/ip32/ris/risdir
RISTMP=/usr/tmp/ris$$

print_error_and_exit()
{
	print "RIS installation failed"
	$RM -f $RISTMP
	exit 1
}

set -e
trap print_error_and_exit 1 2 3 4 6 7 8 9 10 11 12 13 15 19

#####################################################################
#
#   if our environment variable RISDEVDIR is set and the directory
#   exists, then set up for a development environment; build the
#   commands to create /usr/ip32/ris/risdir with RISDEVDIR value.
#
if [ $# -eq 0 -a -d "$RISDEVDIR" ]
then
	if [ "$MK_CALLED" != "1" ]
	then
		print "\n***** \c"
		print "This script must be invoked by using 'mk install'\c"
		print " *****\n"
		print_error_and_exit
	fi
	PRODS="$MKDIR -p /usr/ip32/ris 2>>$RISERR;
	print \"$RISDEVDIR\" > $RISDEVDIRFILE;"
#
#####################################################################

else
	print "This script \"$0\"is not invoked properly."
	print_error_and_exit
fi

##########################################
#
#   loop for the entire list of products
#
for PRODNAME in risutl risdp riscli risorads risinfds risingds rissybds risorans risinfns risingns risdb2ds
do
	case $PRODNAME in
		risdp)
			SUBSYS="risapp"
			[ -f "$RISDEVDIR/$SUBSYS/lib/$LIBDIR/ris.a" ] ||
			continue
			;;
		risutl)
			SUBSYS="risutl"
			[ -f "$RISDEVDIR/$SUBSYS/lib/$LIBDIR/rislduld.a" ] ||
			continue
			;;
		riscli)
			SUBSYS="riscli"
			[ -f "$RISDEVDIR/$SUBSYS/bin/$BINDIR/riscli" ] ||
			continue
			;;
		ris???[dn]s)
			SUBSYS="rissrv"
			[ -f "$RISDEVDIR/$SUBSYS/bin/$BINDIR/$PRODNAME" ] ||
			continue
			;;
	esac

	$RISDEVDIR/riscom/build/crescrip.ksh $PRODNAME D
	PRODINST=$RISDEVDIR/$SUBSYS/bin/$PRODNAME.ksh
	PRODS="$PRODS $PRODINST; $RM -f $PRODINST;"
done
#
# end of loop of entire list of products
#
##########################################

[ -z "$PRODS" ] && print_error_and_exit

print "#!/bin/ksh
$PRODS" > $RISTMP
$CHMOD +x $RISTMP

print "Installing RIS $RIS_VER for $RIS_PLATFORM"
$SU root -c $RISTMP
$RM -f $RISTMP $RISLOG $RISERR
print "Successful installation of RIS"
exit 0
