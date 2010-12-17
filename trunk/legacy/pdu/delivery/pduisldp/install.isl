#
# Copyright Intergraph Corporation
#
# I/PDU Product Installation
#
# Synopsis
#
#    install.isl <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
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
NFMDIR=${INGRHOME}/nfm

Config_Size=26000
Help_Size=1750
Train_Size=1954
PDUpplex_Size=30
PDUapi_sol2=23500
PDUapi_ex=100
Ppl_Size=10
TOTAL=70000

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data
pdtmp1=${INGRHOME}/Product_DT
prodtmp=/usr/tmp/SM01052
hpserv=bin/helpbs

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
   echo I/PDU depends on GRNUC, EXNUC, and BSPMATH.
   echo
   echo WARNING:
   echo
   echo I/PDU version 3.2 is dependent on I/PDM version 3.0+
   echo and NFM 3.5!!!!!!!
   echo
   echo Do not download this version of I/PDU until all design
   echo files are checked in!!!!!!
   echo
   echo CAUTION:
   echo
   echo If you are an existing user of PDU/PDM, please read the
   echo 'README' file associated with this product.  This file contains
   echo more information about the significant architectural
   echo changes in 3.0 I/PDM.   This file should be reviewed before
   echo downloading I/PDU or I/PDM.
   echo
   echo WARNING:
   echo
   echo The I/PDU development platform requires approximately ${TOTAL} blocks.
   answer=`getanswer "Install I/PDU development platform locally (y/n) ? " "y"`

   if [ "$answer" = "y" ]
then
   answer131="y"
fi
  
   apianswer="n"
   if [ "$answer" = "y" ]
   then
   echo
   echo The I/PDU Help Files require approximately ${Help_Size} blocks.
   helpanswer=`getanswer "Install the I/PDU Help Files locally (y/n) ? " "y"`
 
   echo
   echo The I/PDU Training Files require approximately ${Train_Size} blocks.
   trainanswer=`getanswer "Install the I/PDU Training Files (y/n) ? " "y"`
 
   echo
   echo
    echo The ppl macro examples require approximately ${PDUpplex_Size} blocks.
    pplexanswer=`getanswer "Install ppl macro examples locally (y/n) ? " "n"`
 
    echo
    echo API examples require approximately ${PDUapi_ex} blocks.
    apiexans=`getanswer "Install PDU/PDM API examples locally (y/n) ? " "n"`
    fi

   echo
   echo API libraries require approximately ${PDUapi_sol2} blocks.
   apianswer=`getanswer "Install the API libraries (y/n) ? " "y"`

#   echo
#   HOSTNAME=`getanswer "Enter the name of the server node. " " "`
#   echo

#
# Load I/PDU
#
if [ "$answer" != "y" ]
then
  exit 1;
fi
 
if [ "$PREPROCESS" = "Y" ]; then exit 0; fi
if [ "$PREPROCESS" = "y" ]; then exit 0; fi
if [ "$answer" = "y" ]
then
#  Check_Space $UNIXDIR $TOTAL "I/PDU"
   answer131="y"
fi

if [ "$answer131" = "y" ]
then

  echo
    echo Installing I/PDUDP in $UNIXDIR for INTEL Solaris CPU
    echo Installing I/PDUDP in $UNIXDIR for INTEL Solaris CPU >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  if [ "$answer131" = "y" ]
  then
    getfile pdubin.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pduconf.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdudbaspt.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdulib.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdmlib.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pduinclude.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#Check for MDS
 MdsCheck=`grep \"Mds\" ${INGRHOME}/product_data`
 if [ "$MdsCheck" != "" ]
   then
   echo
   echo Installing Mds fixes
   echo
   \cd $UNIXDIR/config/dload/init
   getfile pdumds.isl | compress -d | cpio -ivmud >>$LOGFILE 2>&1
   AOK=$?
   if [ "$AOK" != "0" ] ; then exit $AOK; fi
   mdspath=`proddata +%p I_MDS`
#   if [ "${mdspath}" != "" ]
#   then
#     \cd ${mdspath}/bin
#     getfile Mds.isl | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#     AOK=$?
#     if [ "$AOK" != "0" ]; then exit $AOK; fi
#     chmod 755 ${mdspath}/bin/Mds
#   fi
   \cd $UNIXDIR/config/dload/patch
   rm EMsplitpart.so
   \cd $UNIXDIR
 fi

    mkdir ${UNIXDIR}/config/english/messages/src
    \cd  ${UNIXDIR}/config/english/messages/src
    getfile pdumsgsrc.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    \cd  ${UNIXDIR}
fi

#
# Load the help files.
#

if [ "$helpanswer" = "y" ]
then
#  Check_Space $UNIXDIR $Help_Size "I/PDU Help Files"

  helppath=`proddata +%p helprt`
  if [ "${helppath}" = "" ]
  then
    echo
    echo "You need to download HELPRT before downloading PDU HELP"
    echo
    helpanswer=n
  else
    if [ ! -f $helppath/$hpserv ]
    then
    echo
    echo "You need to download the HELPRT help servers before downloading PDU HE
LP"
    echo
    echo "PDU HELP files will not be loaded"
    echo
    helpanswer=n
    fi
   fi

if [ "$helpanswer" = "y" ]
then
  echo
    echo Installing I/PDU Help Files in $UNIXDIR for INTEL Solaris CPU
    echo Installing I/PDU Help Files in $UNIXDIR for INTEL Solaris CPU >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
       getfile pduhelp.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi

       if [ "$helpanswer" = "y" ]
       then
         installhdoc.sh ${UNIXDIR}/config/english/HELPFILE
       fi
    fi   
  fi
fi

#
# Load HELPINFO file
#
 
if [ "$helpanswer" = "n" ]
    then
       getfile pduhelp.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
       rm `find $UNIXDIR/config/english/HELPFILE -print`  >/dev/null 2>&1
    fi

#
# Load the training files.
#

if [ "$trainanswer" = "y" ]
then
#  Check_Space $UNIXDIR $Help_Size "I/PDU Training Files"

  echo
    echo Installing I/PDU - I/PDM  Training Files in $UNIXDIR
    echo Installing I/PDU - I/PDM  Training Files in $UNIXDIR >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
       getfile pdutrain.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi   
  fi
fi

# Load ppl macro examples
 
if [ "$pplexanswer" = "y" ]
then
#  Check_Space $UNIXDIR ${PDUpplex_Size} "I/PDU PPL Macro Examples"
 
  echo
  echo Installing I/PDU PPL Macro Examples in $UNIXDIR/ppl/examples
  echo Installing I/PDU PPL Macro Examples in $UNIXDIR/ppl/examples >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1
 
  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
       getfile pdupplex.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi
fi
# Load API examples

if [ "$apiexans" = "y" ]
then

  echo
  echo Installing I/PDU API examples in $UNIXDIR/apiexamples
  echo Installing I/PDU API examples in $UNIXDIR/apiexamples >>$LOGFILE 2
  echo
>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
    getfile apiexam.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    \cd $UNIXDIR
fi

# Load api
 
if [ "$apianswer" = "y" ]
then
 
  echo
  echo Installing I/PDU API in $UNIXDIR/lib
  echo Installing I/PDU API in $UNIXDIR/lib >>$LOGFILE 2
  echo
>&1
  date >>$LOGFILE 2>&1
 
  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
    getfile apilib.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR/lib/isl
    getfile nfmapi.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile dbaapi.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile umsapi.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile risapi.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
 
  \cd $UNIXDIR/include
    getfile apiincl.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi

    \cd $UNIXDIR
fi

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
# Set the mode of the files.
#

  chown sys $UNIXDIR/config/* >/dev/null 2>&1
  chown root $UNIXDIR/READMEAPI >/dev/null 2>&1
  if [ "$trainanswer" = "y" ]
  then
  chown sys `find $UNIXDIR/training -print` >/dev/null 2>&1
  fi
  chown sys `find $UNIXDIR/include -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/commands -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/dload -print` >/dev/null 2>&1
#  chown sys `find $UNIXDIR/config/dload/prod -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/dload/init -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/dload/patch -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/forms -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/icons -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/HELPINFO -print`  >/dev/null 2>&1
  if [ "$helpanswer" = "y" ]
  then
  chown sys `find $UNIXDIR/config/english/HELPFILE -print`  >/dev/null 2>&1
  fi
  if [ "$apiexans" = "y" ]
  then
  chown sys `find $UNIXDIR/apiexamples -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/lib -print`  >/dev/null 2>&1
  fi
#  chown sys `find $UNIXDIR/config/english/menus -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/english/message* -print`  >/dev/null 2>&1
  chown sys `find $UNIXDIR/config/tables -print`   >/dev/null 2>&1
  chown sys `find $UNIXDIR/ppl -print` >/dev/null 2>&1
  chown sys `find $UNIXDIR/dbasupport -print` >/dev/null 2>&1
  chgrp bin $UNIXDIR/config/* >/dev/null 2>&1
  chgrp sys $UNIXDIR/READMEAPI >/dev/null 2>&1
  chmod 644 $UNIXDIR/READMEAPI >/dev/null 2>&1
  if [ "$trainanswer" = "y" ]
  then
  chgrp bin `find $UNIXDIR/training -print` >/dev/null 2>&1
  fi
  chgrp bin `find $UNIXDIR/include -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/commands -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/dload -print` >/dev/null 2>&1
#  chgrp bin `find $UNIXDIR/config/dload/prod -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/dload/init -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/dload/patch -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/forms -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/icons -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/HELPINFO -print`  >/dev/null 2>&1
  chmod 777 `find $UNIXDIR/config/english/HELPINFO -print`  >/dev/null 2>&1
  if [ "$helpanswer" = "y" ]
  then
  chgrp bin `find $UNIXDIR/config/english/HELPFILE -print`  >/dev/null 2>&1
  fi
  if [ "$apiexans" = "y" ]
  then
  chgrp bin `find $UNIXDIR/apiexamples -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/lib -print`  >/dev/null 2>&1
  fi
#  chgrp bin `find $UNIXDIR/config/english/menus -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/message* -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/tables -print`   >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/ppl -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/dbasupport -print` >/dev/null 2>&1
  restatus=$?

# Set mode of reactive loading directories and files

#  \cd $UNIXDIR/config/dload/prod
#
#  find . -exec chown sys {} \;
#  find . -exec chgrp bin {} \; 
#  find . -exec chmod 775 {} \;
#
#  \cd $UNIXDIR


#
#  If they have tcp/ip, update /etc/services and /etc/inetd.conf
#
#  if [ -d /usr/ip32/tcpip ]
#  then
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
#    fi
#
#
#
# check and remind for nfm listener
#
#  nfmv=`cat /usr/ip32/inc/server.dat | grep "NFMfileserver"`
#  if [ "$nfmv" = "" ]
#  if [ ! -f /etc/nfmd.conf ]
#  then
#     if [ "$answer131" = "y" ]
#     then
#        echo "CAUTION: need to load NFM daemon and file server"
#     fi
#  fi

# add entry to hosts file for NFMenv.dat file
#  if [ -f /etc/hosts ]
#  then
#    test_host_entry=`fgrep "	$HOSTNAME " /etc/hosts | grep NFMENV `
#    if [ "$test_host_entry" = "" ]
#    then
#      test_host_entry=`fgrep " $HOSTNAME " /etc/hosts | grep NFMENV `
#      if [ "$test_host_entry" = "" ]
#       then
#         echo "Updating /etc/hosts file..."
#         server_entry=`fgrep "	$HOSTNAME " /etc/hosts`
#         if [ "$server_entry" = "" ]
#         then
#           server_entry=`fgrep " $HOSTNAME " /etc/hosts`
#           DELIMITER="space"
#         else
#           DELIMITER="tab"
#         fi
#         if [ "$DELIMITER" = "tab" ]
#         then
#           sed  '/'"	$HOSTNAME "'/d' /etc/hosts > /usr/tmp/.x
#         else
#           sed  '/'" $HOSTNAME "'/d' /etc/hosts > /usr/tmp/.x
#         fi
#         mv /usr/tmp/.x /etc/hosts
#         server_entry="${server_entry} NFMENV"
#         if [ "$server_entry" != "NFMENV" ]
#         then
#           echo ${server_entry} >> /etc/hosts
#         fi
#      fi
#    fi
#  fi

#Install NFM
echo
echo Installing NFMfileserver and NFMdaemon in $INGRHOME/nfm for INTEL Solaris CPU
echo Installing NFMfileserver and NFMdaemon in $INGRHOME/nfm for INTEL Solaris CPU >>$LOGFILE 2>&1
echo
if [ "$answer131" = "y" ]
then
  date >>$LOGFILE 2>&1

  if [ ! -d ${INGRHOME}/nfm/bin ]
  then
     mkdir ${INGRHOME}/nfm
     mkdir ${INGRHOME}/nfm/bin
  fi

  if [ ! -d ${INGRHOME}/nfm/bin ]
  then
    echo
    echo Cannot create ${INGRHOME}/nfm/bin
    echo
    exit 1
  fi

  \cd  ${INGRHOME}/nfm/bin
  getfile nfmbin.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  \cd /etc
  getfile nfmdconf.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi


# Fix /etc/rc0.d and /etc/rc2.d startup files to contain the correct
# INGRHOME path at reboot time.

   \cd /etc

   echo "s,\$INGRHOME,$INGRHOME,g" > /usr/tmp/SedfileForNFM

   sed -f /usr/tmp/SedfileForNFM init.d/nfm > /usr/tmp/nfm
   sed -f /usr/tmp/SedfileForNFM rc0.d/K99nfm > /usr/tmp/K99nfm
   sed -f /usr/tmp/SedfileForNFM rc2.d/S99nfm > /usr/tmp/S99nfm
   sed -f /usr/tmp/SedfileForNFM nfmd.conf > /usr/tmp/nfmd.conf

   mv /usr/tmp/nfm /etc/init.d
   mv /usr/tmp/K99nfm /etc/rc0.d
   mv /usr/tmp/S99nfm /etc/rc2.d
   mv /usr/tmp/nfmd.conf /etc

   chmod 777 /etc/init.d/nfm
   chmod 777 /etc/rc0.d/K99nfm
   chmod 777 /etc/rc2.d/S99nfm

   rm /usr/tmp/SedfileForNFM

   echo
   echo Starting NFMdaemon
   echo
#   . /etc/init.d/nfm start
   if [ -x $INGRHOME/nfm/bin/NFMdaemon ]
    then
        pid=`/bin/ps -ef | grep NFMdaemon | grep -v grep | awk '{print $2}'`
        if [ "${pid}" != "" ]
        then
            echo "$0:Warning: NFMdaemon : PID = ${pid} already running" > /dev/console
        else
            $INGRHOME/nfm/bin/NFMdaemon &
        fi
   fi

fi

# add link from INGRHOME to /usr/ip32
if [ ! -f /usr/ip32 ]
then
 echo
 echo Linking INGRHOME to /usr/ip32
# if /usr/ip32 already exists, link /opt/ingr/pdu to /usr/ip32/pdu,
# else link /opt/ingr to /usr/ip32. raj.
#ln -s $INGRHOME /usr/ip32
 if [ -d /usr/ip32 ]
 then
 ln -s $INGRHOME/pdudp /usr/ip32/pdudp
 else
 ln -s $INGRHOME /usr/ip32
 fi
else
 if [ ! -f /usr/ip32/ris ]
   then
    echo
    echo Linking INGRHOME to /usr/ip32/ris
    ln -s $INGRHOME/ris /usr/ip32/ris
    fi
  if [ ! -f /usr/ip32/nfm ]
    then
     echo
     echo Linking INGHROME to /usr/ip32/nfm
     ln -s $INGRHOME/nfm /usr/ip32/nfm
    fi
fi

# Deliver the risbatch utility
    mkdir ${UNIXDIR}/tools
    \cd  ${UNIXDIR}/tools
    getfile ris_fix.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    chown root $UNIXDIR/tools/ris_fix >/dev/null 2>&1
    chgrp sys $UNIXDIR/tools/ris_fix >/dev/null 2>&1
    chmod 777 $UNIXDIR/tools/ris_fix >/dev/null 2>&1

# Temporarily commented out. Can not find source code for button_fix .so files.
# See $PDU/delivery/collect_isl. 04/may/95 - raj.

# Deliver the button timing enhancements
# mkdir ${UNIXDIR}/button_fix
# \cd ${UNIXDIR}/button_fix
#  getfile button.${SUFF} | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#  AOK=$?
#  if [ "$AOK" != "0" ] ; then exit $AOK; fi

exit 0
