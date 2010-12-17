#
# Copyright Intergraph Corporation
#
# I/PDUSRC Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <SOURCEDIR> <-y>
#

Config_Size=40000
Help_Size=1750
Train_Size=2100
TOTAL=40000

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

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
   echo The config, dbasupport, include, ldpdu, lib, messages and ppl/bin
   echo directories will be downloaded automatically. All other directories will
   echo be prompted for.
   echo
   echo The I/PDUSRC platform requires approximately ${TOTAL} blocks.

   answer=`getanswer "Install the standard I/PDUSRC platform locally (y/n) ? " "y"`

   answer131="y"
  
   echo
   SOURCEDIR=`getanswer "Enter the source directory. " "/usr/ip32/pdu"`

   echo
   owner=`getanswer "Enter the owner. " "root"`

\cd ${SOURCEDIR}

LOGFILE=${SOURCEDIR}/log

   echo
   assanswer=`getanswer "Install the assembly directory(y/n) ? " "y"`

   echo
   catanswer=`getanswer "Install the catalogs directory(y/n) ? " "y"`

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

   #if [ "$answer131" = "n" ]
   #then
   #echo
   #answer130=`getanswer "Install the 1.3.0 release of I/PDUSRC (y/n) ? " "y"`
   #fi

   echo
   echo The I/PDUSRC Help Files require approximately ${Help_Size} blocks.
   helpanswer=`getanswer "Install the I/PDUSRC Help Files locally (y/n) ? " "y"`

#
# Load I/PDUSRC
#

if [ "$answer" = "y" ]
then
  Check_Space $SOURCEDIR $TOTAL "I/PDUSRC"
#echo
#answermenu=`getanswer "Install the menu panel for EMS/MDS/DRAFT ? " "EMS"`

  echo
  echo Installing I/PDUSRC in $SOURCEDIR
  echo Installing I/PDUSRC in $SOURCEDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  if [ "$answer131" = "y" ]
  then
#if [ "$answermenu" = "EMS" ]
#then
#       getfile ems_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#       AOK=$?
#       if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
#if [ "$answermenu" = "ems" ]
#then
#getfile ems_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
#if [ "$answermenu" = "DRAFT" ]
#then
#getfile draft_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
#if [ "$answermenu" = "draft" ]
#then
#getfile draft_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
#if [ "$answermenu" = "MDS" ]
#then
#getfile mds_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
#if [ "$answermenu" = "mds" ]
#then
#getfile mds_menu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ] ; then exit $AOK; fi
#fi
    getfile pdubin.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ppl -print`
    chgrp users `find $SOURCEDIR/ppl -print` 

    getfile pduconf.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
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
    chown $owner `find $SOURCEDIR/config/english/menus -print`
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
    chgrp users `find $SOURCEDIR/config/english/menus -print`
    chgrp users `find $SOURCEDIR/config/english/messages -print`

    getfile pdudbaspt.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/dbasupport -print`
    chgrp users `find $SOURCEDIR/dbasupport -print` 

    getfile pduinclude.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/include -print`
    chgrp users `find $SOURCEDIR/include -print` 

    getfile pdulib.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/lib -print`
    chgrp users `find $SOURCEDIR/lib -print` 

    getfile pduspec.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/spec -print`
    chgrp users `find $SOURCEDIR/spec -print` 

    getfile pdumess.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/messages -print`
    chgrp users `find $SOURCEDIR/messages -print` 

    getfile pduldpdu.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ldpdu -print`
    chgrp users `find $SOURCEDIR/ldpdu -print` 

    getfile pdudel.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/delivery -print`
    chgrp users `find $SOURCEDIR/delivery -print` 

    getfile pdudesdoc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/design_doc -print`
    chgrp users `find $SOURCEDIR/design_doc -print` 

    getfile pdukernal.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/kernal -print`
    chgrp users `find $SOURCEDIR/kernal -print` 

    getfile pdubuild.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdubuild -print`
    chgrp users `find $SOURCEDIR/pdubuild -print` 

if [ "$assanswer" = "y" ]
then
    getfile pduass.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/assembly -print`
    chgrp users `find $SOURCEDIR/assembly -print` 
fi

if [ "$catanswer" = "y" ]
then
    getfile pducat.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/catalogs -print`
    chgrp users `find $SOURCEDIR/catalogs -print` 
fi

if [ "$designanswer" = "y" ]
then
    getfile pdudesign.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/design -print`
    chgrp users `find $SOURCEDIR/design -print` 
fi

if [ "$fmgranswer" = "y" ]
then
    getfile pdufmgr.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/filemgr -print`
    chgrp users `find $SOURCEDIR/filemgr -print` 
fi

if [ "$initanswer" = "y" ]
then
    getfile pduinit.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/init -print`
    chgrp users `find $SOURCEDIR/init -print` 
fi

if [ "$macrosanswer" = "y" ]
then
    getfile pdumacros.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/macros -print`
    chgrp users `find $SOURCEDIR/macros -print` 
fi

if [ "$miscanswer" = "y" ]
then
    getfile pdumisc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/misc -print`
    chgrp users `find $SOURCEDIR/misc -print` 
fi

if [ "$palanswer" = "y" ]
then
    getfile pdupal.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pal -print`
    chgrp users `find $SOURCEDIR/pal -print` 
fi

if [ "$partsanswer" = "y" ]
then
    getfile pduparts.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/parts -print`
    chgrp users `find $SOURCEDIR/parts -print` 
fi

if [ "$pdmranswer" = "y" ]
then
    getfile pdupdmr.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdmr -print`
    chgrp users `find $SOURCEDIR/pdmr -print` 
fi

if [ "$pplanswer" = "y" ]
then
    getfile pduppl.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ppl/src -print`
    chgrp users `find $SOURCEDIR/ppl/src -print` 
fi

if [ "$rptsanswer" = "y" ]
then
    getfile pdureports.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/reports -print`
    chgrp users `find $SOURCEDIR/reports -print` 
fi

if [ "$toolsanswer" = "y" ]
then
    getfile pdutools.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/tools -print`
    chgrp users `find $SOURCEDIR/tools -print` 
fi

#  else
#    if [ "$answer130" = "y" ]
#    then
#       getfile pdubin130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#       AOK=$?
#       if [ "$AOK" != "0" ] ; then exit $AOK; fi

#       getfile pduconf130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#       AOK=$?
#       if [ "$AOK" != "0" ] ; then exit $AOK; fi
#    fi
#  fi

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
#  if [ "$answer130" = "y" ]
#  then
#     getfile pduhelp130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#     AOK=$?
#     if [ "$AOK" != "0" ]; then exit $AOK; fi
#  else
    if [ "$answer131" = "y" ]
    then
       getfile pduhelp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi   
  fi
fi

#
# Fix the product_data file.
#
  echo > $pdtmp
  if [ -f $pd ]
  then
    sed '/\"Pdu\"/d' $pd > $pdtmp
  fi
  echo "\"Pdu\" I/PDU GRmodule Pdu $SOURCEDIR" >> $pdtmp
  mv $pdtmp $pd

fi

#
# check and remind for nfm listener
#
#  nfmv=`cat /usr/ip32/inc/server.dat | grep "NFMfileserver"`
#  if [ "$nfmv" = "" ]
  if [ ! -f /etc/nfmd.conf ]
  then
     if [ "$answer131" = "y" ]
     then
        echo "CAUTION: need to load NFM daemon and file server"
     fi
  fi

exit 0
