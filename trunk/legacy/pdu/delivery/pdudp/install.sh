#
# Copyright Intergraph Corporation
#
# I/PDU Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

\cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

#>${LOGFILE}

Config_Size=30000
Help_Size=1750
Train_Size=2100
PDUpplex_Size=30
PDUapi_c100=22700
PDUapi_c400=23500
PDUapi_ex=120
TOTAL=45000

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data
pdtmp1=/usr/ip32/Product_DT
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

  set `df $checkDIR`
  Disk_Space=$3

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
   echo
   echo I/PDU depends on I/GRNUC, I/EXNUC, and I/BSPML.
   echo
   echo WARNING:
   echo
   echo I/PDU version 3.2 is dependent on I/PDM version 3.0+
   echo and NFM 3.5+ !!!!!!!
   echo
   echo Do not download this version of I/PDU until all design 
   echo files are checked in!!!!!!
   echo
   echo CAUTION:
   echo
   echo If you are an existing user of PDU/PDM, please read the
   echo 'README' file associated with this product.  This file contains 
   echo more information about the significant architectural
   echo changes in 3.0+ I/PDM.   This file should be reviewed before 
   echo downloading I/PDU or I/PDM.  
   echo
   echo The I/PDU development platform requires approximately ${TOTAL} blocks.
   answer=`getanswer "Install I/PDU development platform locally (y/n) ? " "y"`

if [ "$answer" != "21" ]
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
   echo C100 API libraries require approximately ${PDUapi_c100} blocks.
   c100ans=`getanswer "Install the C100 API libraries (y/n) ? " "n"`

   echo
   echo C400 API libraries require approximately ${PDUapi_c400} blocks.
   c400ans=`getanswer "Install the C400 API libraries (y/n) ? " "y"`

if [ "$c100ans" = "y" ]
then
   apianswer="y" 
fi

if [ "$c400ans" = "y" ]
then
   apianswer="y" 
fi

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
  Check_Space $UNIXDIR $TOTAL "I/PDU"
   answer131="y"
#echo
#answermenu=`getanswer "Install the menu panel for EMS/MDS/DRAFT ? " "EMS"`

  echo
  echo Installing I/PDU in $UNIXDIR
  echo Installing I/PDU in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1
echo
echo
echo "Download executables for $CPUID processors . . ."

# check for files in the patch directory
if [ -d $UNIXDIR/config/dload/patch ]
then
  echo 
  echo "Cleaning up patch directory"
  echo 
  rm $UNIXDIR/config/dload/patch/*.o
fi

  if [ "$answer131" = "y" ]
  then
    getfile pdubin.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    if [ "$CPUID" = "c100" ] 
    then
    getfile pduconfc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$CPUID" = "c400" ]
    then
    getfile pduconfc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdudbaspt.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pduinclude.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdulibc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    getfile pdmlibc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    mkdir ${UNIXDIR}/config/english/messages/src
    \cd  ${UNIXDIR}/config/english/messages/src
    getfile pdumsgsrc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    \cd  ${UNIXDIR}

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
    echo "You need to download the HELPRT help servers before downloading PDU HELP"
    echo
    echo "PDU HELP files will not be loaded"
    echo
    helpanswer=n
    fi
  fi

 if [ "$helpanswer" = "y" ]
 then
  Check_Space $UNIXDIR $Help_Size "I/PDU Help Files"

  echo
  echo Installing I/PDU Help Files in $UNIXDIR
  echo Installing I/PDU Help Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
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

       installhdoc.sh ${UNIXDIR}/config/english/HELPFILE
    fi   
  fi
 fi

#
# Load HELPINFO file
#

if [ "$helpanswer" = "n" ]
    then
       getfile pduhelp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
       rm `find $UNIXDIR/config/english/HELPFILE -print`  >/dev/null 2>&1
    fi

if [ "$trainanswer" = "y" ]
then
  Check_Space $UNIXDIR ${Train_Size} "I/PDU Training Files"

  echo
  echo Installing I/PDU - I/PDM  Training Files in $UNIXDIR
  echo Installing I/PDU - I/PDM  Training Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
#  if [ "$answer130" = "y" ]
#  then
#     getfile pduhelp130.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#     AOK=$?
#     if [ "$AOK" != "0" ]; then exit $AOK; fi
#  else
    if [ "$answer131" = "y" ]
    then
       getfile pdutrain.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
       AOK=$?
       if [ "$AOK" != "0" ]; then exit $AOK; fi
    fi   
  fi
fi

#
# Load PDUext executable
#

#if [ "$extanswer" = "y" ]
#then
#  Check_Space $UNIXDIR $PDUext_Size "PDUext executable"

#  echo
#  echo Installing electro-mechanical integration tools in $UNIXDIR
#  echo Installing electro-mechanical integration tools in $UNIXDIR >>$LOGFILE 2>&1
#  date >>$LOGFILE 2>&1
#
#  \cd $UNIXDIR
#    if [ "$answer131" = "y" ]
#
#    then
#       getfile pduext.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#       AOK=$?
#       if [ "$AOK" != "0" ]; then exit $AOK; fi
#    chown sys `find $UNIXDIR/pduext/bin -print` >/dev/null 2>&1
#    chgrp bin `find $UNIXDIR/pduext/bin -print` >/dev/null 2>&1
#   fi
#fi

# Load ppl macro examples

if [ "$pplexanswer" = "y" ]
then
  Check_Space $UNIXDIR ${PDUpplex_Size} "I/PDU PPL Macro Examples"

  echo
  echo Installing I/PDU PPL Macro Examples in $UNIXDIR/ppl/examples
  echo Installing I/PDU PPL Macro Examples in $UNIXDIR/ppl/examples >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
       getfile pdupplex.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
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
    getfile apiexamples.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
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
>&1
  date >>$LOGFILE 2>&1

  \cd $UNIXDIR
    if [ "$answer131" = "y" ]
    then
    if [ "$c100ans" = "y" ]
    then
    getfile apilibc100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR/lib/c100
    getfile nfmapic100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile dbaapic100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile risapic100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile umsapic100.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR
    fi
    if [ "$c400ans" = "y" ]
    then
    getfile apilibc400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR/lib/c400
    getfile nfmapic400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile dbaapic400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile risapic400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile umsapic400.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

  \cd $UNIXDIR/include
    getfile apiincl.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
    fi

  \cd $UNIXDIR
fi

# Install the man entry
  MdsCheck=`grep \"Mds\" /usr/ip32/product_data`
  if [ "$MdsCheck" != "" ]
    then
    \cd $UNIXDIR/config/dload/init
    getfile pdumds.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    \cd $UNIXDIR
  fi

chown sys `find $UNIXDIR/config/english/man_pdu -print`  >/dev/null 2>&1
chgrp bin `find $UNIXDIR/config/english/man_pdu -print`  >/dev/null 2>&1
echo
echo "Installing I/PDU man pages"
echo
if [ -d /usr/ip32/sysvdoc ]
then
 mv ${UNIXDIR}/config/english/man_pdu /usr/ip32/sysvdoc/catman/i_man/man1/pdu.1
 if [ -f /usr/ip32/sysvdoc/newpage ]
  then
   man=/usr/ip32/sysvdoc/manlist
   mantmp=/usr/tmp/manlist
   if grep -l pdu.1 $man > /dev/null
    then
      sed '/\"pdu.1\"/d' $man > $mantmp
      cp $mantmp $man
      rm $mantmp
   fi
 /usr/ip32/sysvdoc/newpage /usr/ip32/sysvdoc/catman/i_man/man1/pdu.1 >> $LOGFILE
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

  igr_conf=/usr/ip32/ingrconfig
  TNORM=`cat $igr_conf | grep I_PDMNORM`

  if [ "$TNORM" = "" ]
  then
  echo "\"Pdu\" I/PDU GRmodule Pdu $UNIXDIR" >> $pdtmp
  sed -e 's/Grnuc:Exnuc/Grnuc:Pdu:Exnuc/g' $pdtmp > $pdtmp1
  mv $pdtmp1 $pdtmp
  else
  echo "\"Pdu\" I/PDU GRmodule Pdu:Pdmnorm $UNIXDIR" >> $pdtmp
  fi
  
# echo "\"Pdu\" I/PDU GRmodule Pdu:Pdmnorm $UNIXDIR" >> $pdtmp
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
  chown sys `find $UNIXDIR/config/dload/prod -print` >/dev/null 2>&1
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
  fi
  if [ "$apianswer" = "y" ]
  then
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
  chgrp bin `find $UNIXDIR/config/dload/prod -print` >/dev/null 2>&1
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
  fi
  if [ "$apianswer" = "y" ]
  then
  chgrp bin `find $UNIXDIR/lib -print`  >/dev/null 2>&1
  fi
#  chgrp bin `find $UNIXDIR/config/english/menus -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/english/message* -print`  >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/config/tables -print`   >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/ppl -print` >/dev/null 2>&1
  chgrp bin `find $UNIXDIR/dbasupport -print` >/dev/null 2>&1
  restatus=$?

# Set mode of reactive loading directories and files

  \cd $UNIXDIR/config/dload/prod

  find . -exec chown sys {} \;
  find . -exec chgrp bin {} \; 
  find . -exec chmod 775 {} \;

  \cd $UNIXDIR
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
  if [ ! -f /etc/nfmd.conf ]
  then
     if [ "$answer131" = "y" ]
     then
        echo "CAUTION: need to load NFM daemon and file server"
     fi
  fi

# Check for PDUdrawings.o
if [ -f $UNIXDIR/config/dload/init/PDUdrawings.o ]
then
  rm $UNIXDIR/config/dload/init/PDUdrawings.o
fi

exit 0
