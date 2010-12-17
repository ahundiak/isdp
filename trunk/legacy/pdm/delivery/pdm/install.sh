#
# Copyright Intergraph Corporation
#
# I/PDM Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

#>${LOGFILE}

Size=5700
prodtmp=/usr/tmp/SM01051

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
}

#if [ ! -f /etc/nfmd.conf ]
#then
#   echo WARNING...WARNING
#   echo 
#   echo You must install NFM before installing this version of I/PDM!!!!
#   echo 
#   exit 1
#fi

igr_conf=/usr/ip32/ingrconfig
TNFM=`cat $igr_conf | grep I_NFM`

if [ "$TNFM" = "" ]
then
   echo WARNING...WARNING
   echo
   echo You must install NFM before installing this version of I/PDM!!!!
   echo
   exit 1
else
   answer131="y"
fi

#
# Determine what kind of machine we are on
#

case `inqcpuid`
in
  C300 | c300 )
    CPUID="c100"
    ;;
  C400 | c400 )
    CPUID="c400"
    ;;
  * )
    CPUID="c100"
    ;;
esac
echo "Download executables for $CPUID processors . . ." >>$LOGFILE 2>&1

#
# Get responses to prompts
#
if [ "$5" = "y" ]
then
   answer=y
   helpanswer=n
   trainanswer=y
else
   echo
   echo I/PDM depends on I/NFM.
   echo
   echo WARNING...WARNING
   echo 
   echo NFM 3.4+ is required before installation of I/PDM.
   echo
   echo I/PDU 3.1 is also required for this version of I/PDM.
   echo
   echo CAUTION:
   echo The 3.1 release of I/PDM requires the 3.1 release of I/PDU.
   echo If you are an existing user of PDU/PDM, please read the
   echo 'README' file associated with this product.  This file contains
   echo more information about the significant architectural and schema
   echo changes in 3.0+ I/PDM.   This file should be reviewed before
   echo downloading I/PDU or I/PDM. 
   echo
   echo Any databases created with a previous version of I/PDM should be converted
   echo using the I/PDM database converter corresponding to V3.0.  Please
   echo read your Delivery Letter.
   echo
   echo The standard I/PDM platform requires approximately ${Size} blocks.
   answer=`getanswer "Install the standard I/PDM platform locally (y/n) ? " "y"`
   answer131="y"
if [ "$answer" != "y" ]
then 
  exit 1; fi
fi

if [ "$PREPROCESS" = "Y" ]; then exit 0; fi
if [ "$PREPROCESS" = "y" ]; then exit 0; fi
#
# Load I/PDM
#

if [ "$answer" = "y" ]
then
    Check_Space $UNIXDIR $Size "I/PDM"

    echo
    echo Installing I/PDM in $UNIXDIR
    echo Installing I/PDM in $UNIXDIR >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
echo
echo
echo "Download executables for $CPUID processors . . ."

    if [ "$answer131" = "y" ]
    then
           if [ "$CPUID" = "c100" ] 
           then
           getfile pdmbinc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           if [ "$CPUID" = "c300" ]
           then
           getfile pdmbinc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           if [ "$CPUID" = "c400" ]
           then
           getfile pdmbinc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           if [ "$CPUID" = "c100" ] 
           then
           getfile pdmconfc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           if [ "$CPUID" = "c300" ]
           then
           getfile pdmconfc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           if [ "$CPUID" = "c400" ]
           then
           getfile pdmconfc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           fi
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmdbaspt.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmdoc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmtrain.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
#
#  Install man entry
#   echo
#   echo "Installing I/PDM man pages"
#   echo

#    if [ -d /usr/ip32/sysvdoc ]
#    then
#        mv ${UNIXDIR}/config/english/man_pdm /usr/ip32/sysvdoc/catman/i_man/man1/pdm.1
#        if [ -f /usr/ip32/sysvdoc/newpage ]
#        then
#           man=/usr/ip32/sysvdoc/manlist
#            mantmp=/usr/tmp/manlist
#            if grep -l pdm.1 $man > /dev/null
#            then
#                sed '/\"pdm.1\"/d' $man > $mantmp
#                cp $mantmp $man
#            rm $mantmp
#         fi
#       /usr/ip32/sysvdoc/newpage /usr/ip32/sysvdoc/catman/i_man/man1/pdm.1 >> $LOGFILE
#    fi
#  fi
#
#  Update server.dat file in inc directory.
#

#if [ "$answer131" = "y" ]
#then
#   server_line=`grep -n "PDMserver" /usr/ip32/inc/server.dat | \
#         sed s/\ \ /\ /g | \
#         cut -f1 -d":"`
#   new_line="11!$UNIXDIR/bin/PDMserver XNS!nfmadmin!"
#   if (test "$server_line" = "" )
#	then
#		echo $new_line >> /usr/ip32/inc/server.dat
#	else
#		echo "${server_line}c\n$new_line\n.\nw" > /usr/tmp/pdm.tmp
#		ed /usr/ip32/inc/server.dat < /usr/tmp/pdm.tmp  >/dev/null 2>&1
#		rm /usr/tmp/pdm.tmp
#   fi
#   retstatus=$?

#
#  If they have tcp/ip, update /etc/services and /etc/inetd.conf
#
#   if [ -d /usr/ip32/tcpip ]
#   then
#      server_line=`grep -n "PDMserver" /etc/services | \
#               sed s/\ \ /\ /g | \
#               cut -f1 -d":"`
#      new_line="PDMserver  1801/tcp  none"
#      if [ "$server_line" = "" ]
#      then
#          echo $new_line >> /etc/services
#      else
#          echo "${server_line}c\n$new_line\n.\nw" > /usr/tmp/pdm.tmp
#          ed /etc/services < /usr/tmp/pdm.tmp  >/dev/null 2>&1
#          rm /usr/tmp/pdm.tmp
#      fi
#      AOK=$?
#      if [ "$AOK" != "0" ] ; then exit $AOK; fi
#   fi

   chown root `find $UNIXDIR -print`
   chgrp sys  `find $UNIXDIR -print`
   chmod 777  `find $UNIXDIR/dbasupport -print`
   chmod 775 `find $UNIXDIR/bin -print`
   chmod 6775 `find $UNIXDIR/bin/PDMinit -print`
fi
exit $retstatus
