#
# Copyright Intergraph Corporation
#
# I/PDUSRC Product Installation
#
# Synopsis
#
#    install.isl <node.usr.pass> <VMSDIR> <SOURCEDIR> <-y>
#

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="ssl"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.sgi" ]
then
  SUFF="sgi"
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
fi

if [ "$0" = "install.sh" ]
then
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

\cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

Config_Size=24364
Help_Size=1442
Train_Size=1946
TOTAL=103096

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data
pdtmp1=${INGRHOME}/Product_DT
prodtmp=/usr/tmp/SM05052

uname -n | cut -c1-1 | read ND
if [ "$ND" = "1" -o "$ND" = "2" -o "$ND" = "3" -o "$ND" = "4" \
    -o "$ND" = "5" -o "$ND" = "6" -o "$ND" = "7" -o "$ND" = "8" \
    -o "%ND" = "9" ]
then
  echo "Node names that begin with a digit will cause errors in PDU"
  answer=`getanswer "Do you want to continue (y/n) ? " "y"`
  if [ "$answer" = "n" ]
  then
    exit  1
  fi
fi

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  if [ "${SUFF}" = "isl" ]
   then
    set `/usr/bin/df $checkDIR | sed '1d' `
    Disk_Space=$4
  elif [ "${SUFF}" = "ssl" ]
   then
    set `/usr/5bin/df $checkDIR`
    Disk_Space=$7
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

echopath ()
  {
      item=$1
      pdata=$2
      me=$3
      log=$4

      if [ -f $pdata ]
      then
          path=`awk '/ '$item' / {print $5}' $pdata`
      else
          echo $me: $pdata does not exist >> $log
          exit 1
      fi

      if [ -d "$path" ]
      then
          echo $path
          exit 0
      else
          echo $me: $path no path for $item >> $log
          exit 1
      fi
  }

#
# Get responses to prompts
#

   echo
   echo The config, dbasupport, include, ldpdu, lib, messages and ppl/bin
   echo directories will be downloaded automatically. All other directories will
   echo be prompted for.
   echo
   echo The I/PDUSRC platform requires approximately ${TOTAL} blocks.

   answer=`getanswer "Install the standard I/PDUSRC platform locally (y/n) ? " "y"`
   answer131="y"
  
   echo
   SOURCEDIR=`getanswer "Enter the source directory. " "${INGRHOME}/pdu"`

   echo
   owner=`getanswer "Enter the owner. " "root"`

\cd ${SOURCEDIR}

LOGFILE=${SOURCEDIR}/log

   echo
   assanswer=`getanswer "Install the assembly directory(y/n) ? " "y"`

   echo
   catanswer=`getanswer "Install the catalogs directory(y/n) ? " "y"`

   echo
   kernalanswer=`getanswer "Install the kernal directory(y/n) ? " "y"`

   echo
   designanswer=`getanswer "Install the design directory(y/n) ? " "y"`

   echo
   fmgranswer=`getanswer "Install the filemgr directory(y/n) ? " "y"`

   echo
   initanswer=`getanswer "Install the init directory(y/n) ? " "y"`

   echo
   macrosanswer=`getanswer "Install the macros directory(y/n) ? " "y"`

   echo
   miscanswer=`getanswer "Install the misc directory(y/n) ? " "y"`

   echo
   palanswer=`getanswer "Install the pal directory(y/n) ? " "y"`

   echo
   partsanswer=`getanswer "Install the parts directory(y/n) ? " "y"`

   echo
   pdmranswer=`getanswer "Install the pdmr directory(y/n) ? " "y"`

   echo
   pplanswer=`getanswer "Install the ppl directory(y/n) ? " "y"`

   echo
   rptsanswer=`getanswer "Install the reports directory(y/n) ? " "y"`

   echo
   toolsanswer=`getanswer "Install the tools directory(y/n) ? " "y"`

   echo
   echo The I/PDUSRC Help Files require approximately ${Help_Size} blocks.
   helpanswer=`getanswer "Install the I/PDUSRC Help Files locally (y/n) ? " "y"`

#
# Load I/PDUSRC
#

if [ "$PREPROCESS" = "Y" ]; then exit 0; fi
if [ "$PREPROCESS" = "y" ]; then exit 0; fi

if [ "$answer131" = "y" ]
then
  Check_Space $SOURCEDIR $TOTAL "I/PDUSRC"

  echo
  echo Installing I/PDUSRC in $SOURCEDIR for INTEL Solaris CPU
  echo Installing I/PDUSRC in $SOURCEDIR for INTEL Solaris CPU >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

    getfile pdubin.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ppl -print`
    chgrp users `find $SOURCEDIR/ppl -print` 

    getfile pduconf.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner $SOURCEDIR/config
    chown $owner $SOURCEDIR/config/*
    chown $owner `find $SOURCEDIR/config/commands -print`
    chown $owner `find $SOURCEDIR/config/dload -print`
    chown $owner `find $SOURCEDIR/config/tables -print`
    chown $owner $SOURCEDIR/config/english
    chown $owner $SOURCEDIR/config/english/*
    chown $owner `find $SOURCEDIR/config/english/forms -print`
    chown $owner `find $SOURCEDIR/config/english/icons -print`
    chown $owner `find $SOURCEDIR/config/english/messages -print`
    chgrp users $SOURCEDIR/config
    chgrp users $SOURCEDIR/config/*
    chgrp users `find $SOURCEDIR/config/commands -print`
    chgrp users `find $SOURCEDIR/config/dload -print`
    chgrp users `find $SOURCEDIR/config/tables -print`
    chgrp users $SOURCEDIR/config/english
    chgrp users $SOURCEDIR/config/english/*
    chgrp users `find $SOURCEDIR/config/english/forms -print`
    chgrp users `find $SOURCEDIR/config/english/icons -print`
    chgrp users `find $SOURCEDIR/config/english/messages -print`

    getfile pdudbaspt.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/dbasupport -print`
    chgrp users `find $SOURCEDIR/dbasupport -print` 

    getfile pduinclude.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/include -print`
    chgrp users `find $SOURCEDIR/include -print` 

    getfile pdulib.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/lib -print`
    chgrp users `find $SOURCEDIR/lib -print` 

    getfile pduspec.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/spec -print`
    chgrp users `find $SOURCEDIR/spec -print` 

    getfile pdumess.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/messages -print`
    chgrp users `find $SOURCEDIR/messages -print` 

    getfile pduldpdu.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ldpdu -print`
    chgrp users `find $SOURCEDIR/ldpdu -print` 

    getfile pdubuild.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdubuild -print`
    chgrp users `find $SOURCEDIR/pdubuild -print` 

if [ "$assanswer" = "y" ]
then
    getfile pduass.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/assembly -print`
    chgrp users `find $SOURCEDIR/assembly -print` 
fi

if [ "$catanswer" = "y" ]
then
    getfile pducat.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/catalogs -print`
    chgrp users `find $SOURCEDIR/catalogs -print` 
fi

if [ "$kernalanswer" = "y" ]
then
    getfile pdukernal.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/kernal -print`
    chgrp users `find $SOURCEDIR/kernal -print` 
fi

if [ "$designanswer" = "y" ]
then
    getfile pdudesign.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/design -print`
    chgrp users `find $SOURCEDIR/design -print` 
fi

if [ "$fmgranswer" = "y" ]
then
    getfile pdufmgr.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/filemgr -print`
    chgrp users `find $SOURCEDIR/filemgr -print` 
fi

if [ "$initanswer" = "y" ]
then
    getfile pduinit.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/init -print`
    chgrp users `find $SOURCEDIR/init -print` 
fi

if [ "$macrosanswer" = "y" ]
then
    getfile pdumacros.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/macros -print`
    chgrp users `find $SOURCEDIR/macros -print` 
fi

if [ "$miscanswer" = "y" ]
then
    getfile pdumisc.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/misc -print`
    chgrp users `find $SOURCEDIR/misc -print` 
fi

if [ "$palanswer" = "y" ]
then
    getfile pdupal.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pal -print`
    chgrp users `find $SOURCEDIR/pal -print` 
fi

if [ "$partsanswer" = "y" ]
then
    getfile pduparts.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/parts -print`
    chgrp users `find $SOURCEDIR/parts -print` 
fi

if [ "$pdmranswer" = "y" ]
then
    getfile pdupdmr.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdmr -print`
    chgrp users `find $SOURCEDIR/pdmr -print` 
fi

if [ "$pplanswer" = "y" ]
then
    getfile pduppl.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ppl/src -print`
    chgrp users `find $SOURCEDIR/ppl/src -print` 
fi

if [ "$rptsanswer" = "y" ]
then
    getfile pdureports.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/reports -print`
    chgrp users `find $SOURCEDIR/reports -print` 
fi

if [ "$toolsanswer" = "y" ]
then
    getfile pdutools.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/tools -print`
    chgrp users `find $SOURCEDIR/tools -print` 
fi
fi


#
# Load the help files.
#

if [ "$helpanswer" = "y" ]
then
  Check_Space $SOURCEDIR $Help_Size "I/PDUSRC Help Files"

  echo
  echo Installing I/PDUSRC Help Files in $SOURCEDIR
  echo Installing I/PDUSRC Help Files in $SOURCEDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  \cd $SOURCEDIR
    if [ "$answer131" = "y" ]
    then
       getfile pduhelp.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi   
fi

answer=n

#
# Fix the product_data file.
#
echo > $pdtmp
  if [ -f $pd ]
  then
    sed '/\"Pdu\"/d' $pd > $pdtmp
  fi

  igr_conf=$INGRHOME/ingrconfig
  TNORM=`cat $igr_conf | grep I_PDMNORM`

  if [ "$TNORM" = "" ]
  then
  echo "\"Pdu\" I/PDU GRmodule Pdu $UNIXDIR" >> $pdtmp
  sed -e 's/Grnuc:Exnuc/Grnuc:Pdu:Exnuc/g' $pdtmp > $pdtmp1
  mv $pdtmp1 $pdtmp
  else
  echo "\"Pdu\" I/PDU GRmodule Pdu:Pdmnorm $UNIXDIR" >> $pdtmp
  fi
  mv $pdtmp $pd

#
# check and remind for nfm listener
#
#  nfmv=`cat /usr/ip32/inc/server.dat | grep "NFMfileserver"`
#  if [ "$nfmv" = "" ]
  if [ ! -f /etc/nfmd.conf ]
  then
     if [ "$answer" = "y" ]
     then
        echo "CAUTION: need to load NFM daemon and file server"
     fi
  fi

exit 0
