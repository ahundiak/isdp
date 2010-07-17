#
# Copyright Intergraph Corporation	14-NOV-1990
#
# I/ROUTE Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#
# History
#
# 18 NOV 1990	Template taken from I/EMS
# 07 MAY 1991	Check on VDS existance before loading.
# 14 MAR 1994   Modified for the new Help Interface.
# 12 APR 1994   Added Support for C300/C400.
# 18 JAN 1995   Check on STRUCT existance before loading.



# initialization 
# --------------
UNIXDIR=$4
VERSION="02.03.00"
Route_Size=20000
Help_Size=800
Pmenu_Size=3700

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

#-------------------------------------------------------------------------------
Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  set `df $checkDIR`
  Disk_Space=$3

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
} # Check_Space
#-------------------------------------------------------------------------------
function Installing {

	echo
	echo "Installing $1 in $UNIXDIR"
	echo "Installing $1 in $UNIXDIR" >> $LOG 2>&1
	date >>$LOG 2>&1

} # function Installing
#-------------------------------------------------------------------------------
function hasVDSbeenLoaded {

	VDS=`echopath VDS 2>/dev/null`
	if [ -z "${VDS}" ] ; then
		echo "*\n* I/VDS must be loaded prior to I/ROUTE."
		echo "* Please load I/VDS, then restart this procedure.\n*"
		exit 1
	fi

        Load_Vds="OK"

        case "'proddata +%v I_VDS'" in
        02.03.*)
                ;; # VDS Version 02.03.xx.xx is the version we need
        *)
                Load_Vds="NOT"
                ;;
        esac

        if [ "$Load_Vds" = "NOT" ]
        then
                echo
                echo "This version of I/ROUTE needs :"
                echo "  NEEDS                   LOADED"
                echo "I_VDS 02.03.xx.xx         `proddata '+%n  %v' I_VDS`"
                echo
        fi


} # function hasVDSbeenLoaded
#-------------------------------------------------------------------------------
function hasSTRUCTbeenLoaded {

        STRUCT=`echopath STRUCT 2>/dev/null`
        if [ -z "${VDS}" ] ; then
                echo "*\n* I/STRUCT must be loaded prior to I/ROUTE."
                echo "* Please load I/STRUCT, then restart this procedure.\n*"
                exit 1
        fi

        Load_Struct="OK"

        case "'proddata +%v I_STRUCT'" in
        02.03.*)
                ;; # STRUCT Version 02.03.xx.xx is the version we need
        *)
                Load_Struct="NOT"
                ;;
        esac

        if [ "$Load_Struct" = "NOT" ]
        then
                echo
                echo "This version of I/STRUCT needs :"
                echo "  NEEDS                   LOADED"
                echo "I_STRUCT 02.03.xx.xx         `proddata '+%n  %v' I_STRUCT`"
                echo
        fi


} # function hasSTRUCTbeenLoaded
#-------------------------------------------------------------------------------


#
# Get responses to prompts
#
echo "Route Development ${VERSION}"
echo
echo "I/ROUTE depends on I/VDS and I/STRUCT. These must be loaded before "
echo "loading I/ROUTE"
echo
echo "Use newprod's -b /usrX option to load to a device other than /usr"
echo

      echo
      echo "\t+----------------------------------------------------------+"
      echo "\t| CAUTION:                                                 |"
      echo "\t| --------                                                 |"
      echo "\t| Any previous version of I/ROUTE should be removed from   |"
      echo "\t| the workstation, before loading I/ROUTE.                 |"
      echo "\t|                                                          |"
      echo "\t| Please read your delivery letter.  To remove I/ROUTE use |"
      echo "\t| /usr/ip32/deltools/remove in which you select I/ROUTE.   |"
      echo "\t|                                                          |"
      echo "\t+----------------------------------------------------------+"
      echo
 

# -- Check on prerequisite product existance
hasVDSbeenLoaded
hasSTRUCTbeenLoaded

# -- ROUTE product
echo
echo The standard I/ROUTE platform requires approximately ${Route_Size} blocks.
routeanswer=`getanswer \
  "Install the standard I/ROUTE platform at ${UNIXDIR} (y/n) ?" "y"`

srcanswer=`getanswer \
   "Install Route sources (y/n)?" "y"`

# -- Help module
echo
echo The I/ROUTE Help Files require approximately ${Help_Size} blocks.
 SRVR=""
 helpRT=`proddata %+p helprt`
 helpanswer="n"
 if [ "$helpRT" = "" ]
 then
   echo "*\n* The HELPRT product is required to use the online"
   echo "* help for I/VDS. You will not be able to install"
   echo "* the online help for I/VDS until you install and"
   echo "* configure the HELPRT product.\n*"
 else
   # -- help is installed, but is this machine a server?
   SRVR=`grep helpds /etc/inetd.conf`
   echo
   helpanswer=`getanswer \
   -c "The I/ROUTE Help Files require approximately ${Help_Size} blocks."\
     "Install the I/ROUTE Help Files locally (y/n) ?" "n" yesno`
 fi



# -- Paper Menu Design module
#echo
#echo The I/ROUTE Paper Menu Design Files require approximately ${Pmenu_Size} blocks.
#pmenuanswer=`getanswer 
#  "Install the I/ROUTE Paper Menu Design Files locally (y/n) ?" "n"`
pmenuanswer="n"

#       Actual Installation begins.
#
#       Set CPU ID and extension for prod files.

CPUID=`/bin/inqcpuid`   # Get the CPUID

case $CPUID in
C100)
        EXT=C100
        ;;
C300)
        EXT=C100
        ;;
C400)
        EXT=C400
        ;;
esac


#
# fix the product data file
# -------------------------
echo > $pdtmp
if [ -f $pd ]; then sed '/\"Route\"/d' $pd > $pdtmp; fi
echo "\"Route\" I/ROUTE GRmodule Route:Struct:Vds $UNIXDIR" >> $pdtmp
mv $pdtmp $pd

# goto directory
# --------------
if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1 ; fi
cd ${UNIXDIR}
LOG=${UNIXDIR}/log

#
# -- Route product
#
if [ "$routeanswer" = "y" ]
then

	Check_Space $UNIXDIR $Route_Size "I/ROUTE"

	Installing "I/ROUTE"

	getfile config.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi

	getfile route${EXT}.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi

	getfile include.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi

	getfile ppl.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi

	getfile devel.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi

fi

if [ "$srcanswer" = "y" ]
then
	getfile src.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load the help files
#
case "$helpanswer" in
     [Yy]*)

       Check_Space $UNIXDIR $Help_Size "I/ROUTE Help Files"

       echo
       echo Installing I/ROUTE Help Files in $UNIXDIR
       echo Installing I/ROUTE Help Files in $UNIXDIR >>$LOGFILE 2>&1
       date >>$LOGFILE 2>&1

       getfile routehelp.p | compress -d | cpio -imud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi

       if [ "${SRVR}" = "" ]
       then
         echo "*\n* This workstation is a help client. You will also need to"
         echo "* load the I/ROUTE Help Files on to your help server. See the"
         echo "* I/ROUTE README file for more information."
          # -- for a client, we need HELPINFO but not HELPFILE
         if [ -f $UNIXDIR/config/english/HELPFILE ]
         then
           rm $UNIXDIR/config/english/HELPFILE
         fi
       else
         # -- this is a help server; install the help files by
         # -- running installhdoc.sh
         HLPATH=`proddata +%p helprt`
         ${HLPATH}/bin/installhdoc.sh ${UNIXDIR}/config/english/HELPFILE
       fi
esac

#
# Load the paper menu design files
#
if [ "$pmenuanswer" = "y" ]
then

	Check_Space $UNIXDIR $Pmenu_Size "I/ROUTE Paper Menu Design Files"

	Installing "I/ROUTE Paper Menu Design Files"

	getfile pmenu.p | compress -d | cpio -imud >>$LOGFILE 2>&1
	AOK=$?
	if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

        #
        #       Adapt for Looking Glass (TM)
        #
if inqlgexist
then
  cat << EO > /usr/tmp/routep.ftc
#include <ftdefs.h>
DEFINE TYPE     DEM_ROUTE
 ICON           DEM_ROUTE
  FILE_DESCRIPTION      "I/ROUTE script"
 TEXT
 AND NAME "route"
 AND DIRECTORY "*/route/bin"
COMMAND  CdEx(/bin/ksh -c #c/.lgshell)
COMMAND_DESCRIPTION "Run I/ROUTE"
COMMAND ATTRIBUTE : NATIVE "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions I/ROUTE'"
COMMAND_DESCRIPTION "Set I/ROUTE options"
END
EO

  cat << EO > /usr/tmp/routed.ftc
#include <ftdefs.h>
DEFINE TYPE DEM_ROUTE_OS
 ICON           DEM_ROUTE_OS
        FILE_DESCRIPTION "I/ROUTE Design File ( Object Based )"
 BINARY_DATA
   AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 TO 414 STRING "Route"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 TO 414 STRING "Route"

COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '${UNIXDIR}/bin/.lgshell -f #c/#f'"
COMMAND_DESCRIPTION "Run I/ROUTE"
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EO
  lgadddefs prog /usr/tmp/routep.ftc
  lgadddefs prog /usr/tmp/routed.ftc
fi


exit 0
