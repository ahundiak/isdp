#
# Copyright Intergraph Corporation
#
# I/PDU Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$DESTDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

\cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

#>${LOGFILE}

Bin_Size=125
Config_Size=851
Lib_Size=2894
Help_Size=1118
Train_Size=1954
TOTAL=`expr $Bin_Size + $Config_Size + $Lib_Size`

pd=${ROOT}/usr/ip32/product_data
pdtmp=${ROOT}/usr/ip32/Product_Data

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

#
# Get responses to prompts
#

   echo
   echo I/PDU depends on I/GRNUC, I/EXNUC, and I/BSPML.
   echo
   echo CAUTION:
   echo
   echo The 1.4.1 release of I/PDU requires the 1.4.1 release of I/PDM.
   echo If you are an existing user of PDU/PDM, please read the
   echo 'README' file associated with this product.  This file contains 
   echo more information about the significant architectural and schema
   echo changes in 1.4.1 I/PDM.   This file should be reviewed before 
   echo downloading I/PDU or I/PDM.  For those who want to continue using 
   echo the current 1.3.0 I/PDM schema, you may download the 1.3.0 I/PDU that 
   echo is compatible with 1.4.1 I/EMS.
   echo
   echo The standard I/PDU platform requires approximately ${TOTAL} blocks.
   answer=`getanswer "Install the standard I/PDU platform locally (y/n) ? " "y"`

   echo
   answer131=`getanswer "Install the 1.4.1 release of I/PDU (y/n) ? " "n"`
  
   if [ "$answer131" = "n" ]
   then
   echo
   answer130=`getanswer "Install the 1.3.0 release of I/PDU (y/n) ? " "y"`
   fi

   echo
   echo The I/PDU Help Files require approximately ${Help_Size} blocks.
   helpanswer=`getanswer "Install the I/PDU Help Files locally (y/n) ? " "y"`

   echo
   echo The I/PDU Training Files require approximately ${Train_Size} blocks.
 trainanswer=`getanswer "Install the I/PDU Training Files locally (y/n) ? " "n"`

#
# Load I/PDU
#

if [ "$answer" = "y" ]
then
  Check_Space $UNIXDIR $TOTAL "I/PDU"

  echo
  echo Installing I/PDU in $UNIXDIR
  echo Installing I/PDU in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  if [ "$answer131" = "y" ]
  then
    getfile pdubin.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pduconf.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  else
    if [ "$answer130" = "y" ]
    then
       getfile pdubin130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ] ; then exit $AOK; fi

       getfile pduconf130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
  fi

#
# Fix the product_data file.
#
  CLIDIR=`echo $4 | sed s#$ROOT##`
  echo > $pdtmp
  if [ -f $pd ]; then sed '/\"Pdu\"/d' $pd > $pdtmp; fi
  echo "\"Pdu\" I/PDU GRmodule Pdu $CLIDIR" >> $pdtmp
  mv $pdtmp $pd

#
# Set the mode of the files.
#

  chown sys $UNIXDIR/config/* >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/commands -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/forms -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/icons -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/message* -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/tables -print`   >/dev/null 2>&1
  chown sys `find $UNIXDIR/training -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/bin -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/ppl -print` >/dev/null 2>&1
  chgrp bin $UNIXDIR/config/* >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/commands -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/forms -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/icons -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/message* -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/tables -print`   >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/training -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/bin -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/ppl -print` >/dev/null 2>&1
  chown root $UNIXDIR/bin/pdux
  chgrp sys  $UNIXDIR/bin/pdux
  chmod +s   $UNIXDIR/bin/pdux
  restatus=$?
fi

#
# Load the help files.
#

if [ "$helpanswer" = "y" ]
then
  Check_Space $UNIXDIR $Help_Size "I/PDU Help Files"

  echo
  echo Installing I/PDU Help Files in $UNIXDIR
  echo Installing I/PDU Help Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
  if [ "$answer130" = "y" ]
  then
     getfile pduhelp130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
     AOK=$?
     if [ "$AOK" != "0" ]; then exit $AOK; fi
  else
    if [ "$answer131" = "y" ]
    then
       getfile pduhelp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi   
  fi
  \cd ../../
fi

#
# Load the training files.
#

if [ "$trainanswer" = "y" ]
then
  Check_Space $UNIXDIR $Train_Size "I/PDU Training Files"

  echo
  echo Installing I/PDU Training Files in $UNIXDIR
  echo Installing I/PDU Training Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile pdutrain.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

getfile pduupdate.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
AOK=$?
if [ "$AOK" != "0" ]; then exit $AOK; fi
chown root Update.sh
chgrp sys Update.sh
mv Update.sh ${ROOT}/var/ingr/pdu

exit 0
