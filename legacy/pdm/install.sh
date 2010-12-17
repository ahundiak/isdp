#
# Copyright Intergraph Corporation
#
# I/PDMSRC Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <SOURCEDIR> <-y>
#

Config_Size=22000
Help_Size=1650
Train_Size=1954
TOTAL=22000

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
   echo The config/initial, dbasupport, include, lib and make directories will
   echo be downloaded automatically.

   echo The standard I/PDMSRC platform requires approximately ${TOTAL} blocks.

   answer=`getanswer "Install the standard I/PDMSRC platform locally (y/n) ? " "y"`

   answer131="y"
  
   echo
   SOURCEDIR=`getanswer "Enter the source directory. " "/usr/ip32/pdu"`

   echo
   owner=`getanswer "Enter the owner. " "root"`

\cd ${SOURCEDIR}

LOGFILE=${SOURCEDIR}/log

   echo
   assanswer=`getanswer "Install the ass directory(y/n) ? " "y"`

   echo
   bomanswer=`getanswer "Install the bom directory(y/n) ? " "y"`

   echo
   cicocpanswer=`getanswer "Install the cicocp directory(y/n) ? " "y"`

   echo
   fmgranswer=`getanswer "Install the fmgr directory(y/n) ? " "y"`

   echo
   initanswer=`getanswer "Install the init directory(y/n) ? " "y"`

   echo
   macrosanswer=`getanswer "Install the macros directory(y/n) ? " "y"`

   echo
   mulfileanswer=`getanswer "Install the mulfile directory(y/n) ? " "y"`

   echo
   pdmpanswer=`getanswer "Install the pdmp directory(y/n) ? " "y"`

   echo
   pdmsanswer=`getanswer "Install the pdms directory(y/n) ? " "y"`

   echo
   rptsanswer=`getanswer "Install the reports directory(y/n) ? " "y"`

   echo
   risanswer=`getanswer "Install the ris directory(y/n) ? " "y"`

   echo
   toolsanswer=`getanswer "Install the tools directory(y/n) ? " "y"`

#
# Load I/PDMSRC
#

if [ "$answer" = "y" ]
then
  Check_Space $SOURCEDIR $TOTAL "I/PDMSRC"
#echo
#answermenu=`getanswer "Install the menu panel for EMS/MDS/DRAFT ? " "EMS"`

  echo
  echo Installing I/PDMSRC in $SOURCEDIR
  echo Installing I/PDMSRC in $SOURCEDIR >>$LOGFILE 2>&1
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
    getfile pdmconf.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/config -print`
    chgrp users `find $SOURCEDIR/config -print`

    getfile pdmdbaspt.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/dbasupport -print`
    chgrp users `find $SOURCEDIR/dbasupport -print`

    getfile pdminclude.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/include -print`
    chgrp users `find $SOURCEDIR/include -print`

    getfile pdmlib.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/lib -print`
    chgrp users `find $SOURCEDIR/lib -print`

    getfile pdmmake.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/make -print`
    chgrp users `find $SOURCEDIR/make -print`

    getfile pdmdel.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/delivery -print`
    chgrp users `find $SOURCEDIR/delivery -print`

    getfile pdmgerman.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/german -print`
    chgrp users `find $SOURCEDIR/german -print`

    getfile pdmfrench.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/french -print`
    chgrp users `find $SOURCEDIR/french -print`

    getfile pdmdoc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/doc -print`
    chgrp users `find $SOURCEDIR/doc -print`

if [ "$assanswer" = "y" ]
then
    getfile pdmass.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ass -print`
    chgrp users `find $SOURCEDIR/ass -print`
fi

if [ "$bomanswer" = "y" ]
then
    getfile pdmbom.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/bom -print`
    chgrp users `find $SOURCEDIR/bom -print`
fi

if [ "$cicocpanswer" = "y" ]
then
    getfile pdmcicocp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/cicocp -print`
    chgrp users `find $SOURCEDIR/cicocp -print`
fi

if [ "$fmgranswer" = "y" ]
then
    getfile pdmfmgr.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/fmgr -print`
    chgrp users `find $SOURCEDIR/fmgr -print`
fi

if [ "$initanswer" = "y" ]
then
    getfile pdminit.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/init -print`
    chgrp users `find $SOURCEDIR/init -print`
fi

if [ "$macrosanswer" = "y" ]
then
    getfile pdmmacros.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/macros -print`
    chgrp users `find $SOURCEDIR/macros -print`
fi

if [ "$mulfileanswer" = "y" ]
then
    getfile pdmmulfile.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/mulfile -print`
    chgrp users `find $SOURCEDIR/mulfile -print`
fi

if [ "$pdmpanswer" = "y" ]
then
    getfile pdmpdmp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdmp -print`
    chgrp users `find $SOURCEDIR/pdmp -print`
fi

if [ "$pdmsanswer" = "y" ]
then
    getfile pdmpdms.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdms -print`
    chgrp users `find $SOURCEDIR/pdms -print`
fi

if [ "$rptsanswer" = "y" ]
then
    getfile pdmrpts.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/reports -print`
    chgrp users `find $SOURCEDIR/reports -print`
fi

if [ "$risanswer" = "y" ]
then
    getfile pdmris.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ris -print`
    chgrp users `find $SOURCEDIR/ris -print`
fi

if [ "$toolsanswer" = "y" ]
then
    getfile pdmtools.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/tools -print`
    chgrp users `find $SOURCEDIR/tools -print`
fi

fi

#
# Install the man entry
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
