#
# Copyright Intergraph Corporation
#
# I/PDMSRC Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <SOURCEDIR> <-y>
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

TOTAL=72000

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

#
# Get responses to prompts
#


  echo
   echo The config/initial, dbasupport, include, lib and make directories will
   echo be downloaded automatically.
 
   echo The standard I/PDMSRC platform requires approximately ${TOTAL} blocks.
 
   answer=`getanswer "Install the standard I/PDMSRC platform locally (y/n) ? " "y"`
 
   answer="y"
 
   echo
   SOURCEDIR=`getanswer "Enter the source directory. " "${INGRHOME}/pdm"`
 
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
   drawanswer=`getanswer "Install the draw directory(y/n) ? " "y"`
 
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

if [ "$PREPROCESS" = "Y" ]; then exit 0; fi
if [ "$PREPROCESS" = "y" ]; then exit 0; fi

if [ "$answer" = "y" ]
then
  Check_Space $SOURCEDIR $TOTAL "I/PDMSRC"

  echo
  echo Installing I/PDMSRC in $SOURCEDIR for INTEL Solaris CPU
  echo Installing I/PDMSRC in $SOURCEDIR for INTEL Solaris CPU >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile pdmconf.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/config -print`
    chgrp users `find $SOURCEDIR/config -print`
 
    getfile pdmdbaspt.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/dbasupport -print`
    chgrp users `find $SOURCEDIR/dbasupport -print`
 
    getfile pdminclude.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/include -print`
    chgrp users `find $SOURCEDIR/include -print`
 
    getfile pdmlib.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/lib -print`
    chgrp users `find $SOURCEDIR/lib -print`
 
    getfile pdmmake.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/make -print`
    chgrp users `find $SOURCEDIR/make -print`
 
    getfile pdmdel.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/delivery -print`
    chgrp users `find $SOURCEDIR/delivery -print`
 
    getfile pdmgerman.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/german -print`
    chgrp users `find $SOURCEDIR/german -print`
 
    getfile pdmfrench.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/french -print`
    chgrp users `find $SOURCEDIR/french -print`
 
    getfile pdmdoc.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/doc -print`
    chgrp users `find $SOURCEDIR/doc -print`
 
if [ "$assanswer" = "y" ]
then
    getfile pdmass.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ass -print`
    chgrp users `find $SOURCEDIR/ass -print`
fi
 
if [ "$bomanswer" = "y" ]
then
    getfile pdmbom.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/bom -print`
    chgrp users `find $SOURCEDIR/bom -print`
 
fi
 
if [ "$cicocpanswer" = "y" ]
then
    getfile pdmcicocp.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/cicocp -print`
    chgrp users `find $SOURCEDIR/cicocp -print`
fi
 
if [ "$fmgranswer" = "y" ]
then
    getfile pdmfmgr.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/fmgr -print`
    chgrp users `find $SOURCEDIR/fmgr -print`
fi
 
if [ "$initanswer" = "y" ]
then
    getfile pdminit.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/init -print`
    chgrp users `find $SOURCEDIR/init -print`
fi
 
if [ "$macrosanswer" = "y" ]
then
    getfile pdmmacros.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/macros -print`
    chgrp users `find $SOURCEDIR/macros -print`
fi
 
if [ "$mulfileanswer" = "y" ]
then
    getfile pdmmulfile.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/mulfile -print`
    chgrp users `find $SOURCEDIR/mulfile -print`
fi
 
if [ "$pdmpanswer" = "y" ]
then
    getfile pdmpdmp.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdmp -print`
    chgrp users `find $SOURCEDIR/pdmp -print`
fi
 
if [ "$pdmsanswer" = "y" ]
then
    getfile pdmpdms.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/pdms -print`
    chgrp users `find $SOURCEDIR/pdms -print`
fi
 
if [ "$rptsanswer" = "y" ]
then
    getfile pdmrpts.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/reports -print`
    chgrp users `find $SOURCEDIR/reports -print`
fi
 
if [ "$risanswer" = "y" ]
then
    getfile pdmris.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/ris -print`
    chgrp users `find $SOURCEDIR/ris -print`
fi
 
if [ "$toolsanswer" = "y" ]
then
    getfile pdmtools.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown $owner `find $SOURCEDIR/tools -print`
    chgrp users `find $SOURCEDIR/tools -print`
fi
 
fi

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
