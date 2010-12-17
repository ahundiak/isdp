#
# Copyright Intergraph Corporation
#
# I/PDM Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

#
# Determine what kind of machine we are on
#

if [ "$0" = "install.sco" ]
then
  SUFF="sco"
  export INGRHOME=${INGRHOME:-/u/ip32}
fi
 
if [ "$0" = "install.ssl" ]
then
  SUFF="sco"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi
 
if [ "$0" = "install.sgi" ]
then
  SUFF="sgi"
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
fi
 
if [ "$0" = "install.sh" ]
then
echo setting variables for CLIPPER
  SUFF="p"
  export INGRHOME=${INGRHOME:-/usr/ip32}
  if [ "$INGRHOME" = "/dev/null" ]
  then
    INGRHOME="/usr/ip32"
  fi
fi

INGRHOME="$(echo $INGRHOME | cut -f1 -d:)"

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

#>${LOGFILE}

Size=5700
prodtmp=/usr/tmp/SM05051

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

if [ "${SUFF}" = "sco" ]
   then
    set `/bin/df $checkDIR`
    Disk_Space=$6
  else
    set `df $checkDIR`
    Disk_Space=$3
  fi

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

igr_conf=${INGRHOME}/ingrconfig

answer131="y"

#
# Get responses to prompts
#
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
   answer=`getanswer "Install the standard I/PDM platform locally [y/n] ?" "y"`
   answer131="y"
if [ "$answer" != "y" ]
then 
  exit 1; fi

if [ "$PREPROCESS" = "Y" ]; then exit 0; fi
if [ "$PREPROCESS" = "y" ]; then exit 0; fi
#
# Load I/PDM
#

if [ "$answer" = "y" ]
then
    Check_Space $UNIXDIR $Size "I/PDM"

    echo
    echo Installing I/PDM in $UNIXDIR for INTEL SCO CPU
    echo Installing I/PDM in $UNIXDIR for INTEL SCO CPU >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
echo
echo

    if [ "$answer131" = "y" ]
    then
           getfile pdmbin.sco | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmconf.sco | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmdbaspt.sco | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmdoc.sco | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi

           getfile pdmtrain.sco | compress -d | cpio -ivmud >>$LOGFILE 2>&1
           AOK=$?
           if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi

   # add link from INGRHOME to /usr/ip32
   if [ ! -d /usr/ip32 ]
   then
    echo
    echo Linking INGRHOME to /usr/ip32
    ln -s $INGRHOME /usr/ip32
   else
     if [ ! -d /usr/ip32/pdm ]
     then
      echo
      echo Linking UNIXDIR to /usr/ip32
      ln -s ${UNIXDIR} /usr/ip32
     fi
   fi

   chown root `find $UNIXDIR -print`
   chgrp sys  `find $UNIXDIR -print`
   chmod 777  `find $UNIXDIR/dbasupport -print`
   chmod 775 `find $UNIXDIR/bin -print`
   chmod 6775 `find $UNIXDIR/bin/PDMinit -print`
fi
exit $retstatus
