#
# Copyright Intergraph Corporation	14-DEC-1986
#
# I/GRNUC DP Product Installation
#
# Synopsis
#
#    install.sh -[VTF] <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#
#       27 Jun 1990     DLB     Added options for ppl/cvrt and msg src
#       29 Sep 1993     SCW     Added INGRHOME support
#       27 Oct 1993     SCW     Added INGRHOME dso link support
#       15 Dec 1993     SCW     Fixed syntax error in test
#       05 Jan 1994     SCW     Removed all references to SunOS 4.X
#       05 Jan 1994     SCW     Added extra prompts for invalid responses
#       24 Feb 1994     SCW     Changed Check_Space() to use Free for Solaris
#       08 Mar 1994     SCW     Changed protections once loaded
#       09 Mar 1994     SCW     Changed chmod to use ugo
#       18 Aug 1994     SCW     Added ISL processor type
#       30 Sep 1994     SCW     Added ntplotlib package
#       05 OCT 1994     KBR     Removed raster install for isl CR# 119422937
#       05 OCT 1994     SCW     Cleaned up raster prompting for pload
#       12 JAN 1995     SCW     Corrected newsymbols placement
#       14 MAR 1995     SCW     Added XGL prompting
#       13 JUL 1995     SCW     Changed Check_Space() to use Free for all boxes
#       19 JUL 1995     SCW     Changed XGL prompting for 2.4 or higher OS
#   

PROMPTXGL=n
DEFDIR=$4

if [ "$0" = "install.isl" ]
then 
  SUFF=isl
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.ssl" ]
then 
  SUFF=ssl
  export INGRHOME=${INGRHOME:-/opt/ingr}

  OSver="$(uname -r | cut -c1-3)"
  if [ "${OSver}" -ge "5.4" ]  # Solaris 2.4 or higher
  then
    PROMPTXGL="y"
  fi
fi

if [ "$0" = "install.sgi" ]
then
  SUFF=sgi
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
fi

if [ "$0" = "install.sh" ]
then
  SUFF=p
  export INGRHOME=${INGRHOME:-/usr/ip32}
  if [ "$INGRHOME" = "/dev/null" ]
  then
    INGRHOME="/usr/ip32"
  fi
fi

INGRHOME="$(echo $INGRHOME | cut -f1 -d:)"

if [ "$SUFF" = "p" ]
then
  ProDir="`basename ${DEFDIR}`"
  Df3="`echo $DEFDIR | cut -d'/' -f3`"
  if [ "$Df3" = "$ProDir" ]
  then
    Df2="`echo $DEFDIR | cut -d'/' -f2`"
    DEFDIR="/${Df2}/ip32/${Df3}"
  fi
fi

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3

  Disk_Space=`Free -f $checkDIR`

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires approximately ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    while true
    do
      KEEP_ON=`getanswer "Continue loading ${checkPRODUCT} (y/n) ?" "n"`
      case "$KEEP_ON" in
        y|n ) break;;
           *) echo "\nInvalid. Try again\n" ;;
      esac
    done
    if [ "${KEEP_ON}" != "y" ]; then exit 1; fi
  fi
}

Grnucdp_Size=13400
Archlib_Size=7700
Cvrt_Size=47000
Shlib_Size=7400
Raster_Size=1700
Examples_Size=2400
Integ_Size=100
Fontlib_Size=7000
NTplot_Size=14000
Pplcvrt_Size=100
Msgsrc_Size=600
Plot_Size=2400
IGDScl_Size=2200
Atp_Size=1000

if [ -d $DEFDIR ]; then LOGFILE=$DEFDIR/log; else LOGFILE=/dev/null; fi>$LOGFILE

UNIXDIR=`getanswer "Enter directory for GRNUCDP" "$DEFDIR"`

echo "\nThe base GRNUC Development Platform requires approximately ${Grnucdp_Size} blocks."
while true
do
  BASE=`getanswer "Install the base GRNUC Development Platform (y/n) ?" "y"`
  case "$BASE" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "$PROMPTXGL" = "y" ]
then
  echo
  while true
  do
    xgl=`getanswer \
    "Install GRNUCDP platform which supports XGL display (y/n) ?" "n"`
    case "$xgl" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

if [ "${SUFF}" = "p" ]
 then 
tarcpu=`getanswer "Install the GRNUCDP Libraries for C100, C400, or BOTH ?" "C100"`
tarcpu=`echo ${tarcpu} | tr "[a-z]" "[A-Z]"`
if [ "$tarcpu" = "C400" ]
then
  SUFF=p4
fi
if [ "$tarcpu" = "BOTH" ]
then
  SUFF=BOTH
  tarcpu="C100 and C400"
fi
echo "\nDownloading GRNUCDP Libraries for $tarcpu . . ."
fi

if [ "${SUFF}" = "BOTH" ]
then
#Load C100/C400 with runtime files of the machine cpu type - no prompting
  tarcpu=`inqcpuid`
  if [ "$tarcpu" = "C100" ]
  then
     SUFF="p"
     OTHERSUFF="p4"
  else
     SUFF="p4"
     OTHERSUFF="p"
  fi
#Use tarcpu to flag when loading grlib and grarchlib for C100 and C400
  tarcpu=BOTH
fi

echo "\nThe GRNUCDP Archive Libraries require approximately ${Shlib_Size} blocks."
while true
do
  LIBS=`getanswer "Install the GRNUCDP Archive Libraries (y/n) ?" "y"`
  case "$LIBS" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

#
# install Raster Component
#
if [ "$SUFF" = "isl" ]
then
  RASTER="n"
  RASTERINCSPC="n"
else
  echo "\nThe GRNUCDP Raster Component requires approximately ${Raster_Size} blocks."
  while true
  do
    RASTER=`getanswer "Install the GRNUCDP Raster Component (y/n) ?" "y"`
    case "$RASTER" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    RASTERINCSPC=`getanswer "Install the GRNUCDP Raster Specs and Includes (y/n) ?" "n"`
    case "$RASTERINCSPC" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

echo "\nThe GRNUCDP PPL Examples require approximately ${Examples_Size} blocks."
while true
do
  EXAMPLES=`getanswer "Install the GRNUCDP PPL Examples (y/n) ?" "n"`
  case "$EXAMPLES" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUCDP Integration Utilities require approximately ${Integ_Size} blocks."
while true
do
  INTEG=`getanswer "Install the GRNUCDP Integration Utilities (y/n) ?" "y"`
  case "$INTEG" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUCDP Font Library requires approximately ${Fontlib_Size} blocks."
while true
do
  FONTLIB=`getanswer "Install the GRNUCDP Font Library (y/n) ?" "n"`
  case "$FONTLIB" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe NT Font Resource Library requires approximately ${NTplob_Size} blocks."
while true
do
  NTPLOT=`getanswer "Install the NT Font Resource Library (y/n) ?" "n"`
  case "$NTPLOT" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUCDP IGDS Cell Files require approximately ${IGDScl_Size} blocks."
while true
do
  IGDSCL=`getanswer "Install the GRNUCDP IGDS Cell Files (y/n) ?" "n"`
  case "$IGDSCL" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUCDP Message Source Files require approximately ${Msgsrc_Size} blocks."
while true
do
  MSGSRC=`getanswer "Install the GRNUCDP Message Source Files (y/n) ?" "n"`
  case "$MSGSRC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "${SUFF}" = "isl" -o "${SUFF}" = "ssl" -o "${SUFF}" = "zx" -o "${SUFF}" = "sgi" ]
then
  echo "\nThe GRNUCDP Design File Converter requires approximately ${Cvrt_Size} blocks."
  while true
  do
    CVRT=`getanswer "Install the GRNUCDP Design File Converter (y/n) ?" "n"`
    case "$CVRT" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
else
  CVRT="n"
fi

echo "\nThe GRNUCDP ATPs require approximately ${Atp_Size} blocks."
while true
do
  ATPS=`getanswer "Install the GRNUCDP ATPs (y/n) ?" "n"`
  case "$ATPS" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "$PREPROCESS" = "y" ]
then
  exit 0
fi

#
# create the base directory
#
if [ ! -d $UNIXDIR ]
then
    mkdir -p $UNIXDIR
    if [ ! -d $UNIXDIR ]
    then
        echo 'Unable to make' $UNIXDIR
        exit 1
    fi
fi

cd $UNIXDIR
retstatus=0

date >$LOGFILE 2>&1

#
# fix the product data file.
#
echo > $pdtmp
if [ -f $pd ]; then sed '/\"Grnuc\"/d' $pd > $pdtmp; fi
echo "\"Grnuc\" I/GRNUC GRmodule Grnuc:Pdu:Exnuc $UNIXDIR" >> $pdtmp
mv $pdtmp $pd

#
# Load XGL/ZX display if positive response to XGL prompt
#
if [ "$xgl" = "y" ]
then
  SUFF="zx"
fi


#
# install the base GRNUCDP Development Platform
#
if [ "${BASE}" = "y" ]
then
  Check_Space $UNIXDIR $Grnucdp_Size "GRNUCDP"
  echo
  echo "Installing base GRNUC Development Platform in $UNIXDIR"
  echo "Installing base GRNUC Development Platform in $UNIXDIR" >>$LOGFILE 2>&1
  echo
  date >> $LOGFILE 2>&1

  rm -f config/dload/init/*

  getfile grnucdp.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  getfile grnucdp.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
  then
    getfile grdplot.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
  then
    getfile grnuclg.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  fi

  getfile grconfig.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${SUFF}" = "sgi" ]
  then
     rm -f config/trhooks.cmd
  fi

  getfile grversno.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${SUFF}" = "ssl" -o "${SUFF}" = "zx" -o "${SUFF}" = "sgi" ]
  then
    getfile grtransos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  getfile grinclude.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  getfile grbasinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  getfile groptinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  getfile protoinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  getfile grlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${tarcpu}" = "BOTH" ]
  then
    getfile grlib.${OTHERSUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  fi

  getfile grppl.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ ! -d userdata ]
  then
    mkdir userdata
  fi
  chmod 777 userdata

#
# copy echopath and symbolically link startup.grnuc to /usr/bin. This is done
# unconditionally to support remote installation of the base product. echopath
# is copied because it is also delivered by MDS.
#
  rm -f /usr/bin/startup.grnuc /usr/bin/echopath
  chmod ugo+x $UNIXDIR/bin/echopath
  cp $UNIXDIR/bin/echopath /usr/bin
  ln -s $UNIXDIR/bin/startup.grnuc /usr/bin

fi

#
# install DSO's in $GRNUC/shlib for SGI
#

if [ "${SUFF}" = "sgi" ]
then
  getfile grshlib.sgi | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi
  ln -s ${UNIXDIR}/shlib/*.so ${INGRHOME}/lib/
fi

#
# install the Archive Libraries
#
if [ "${LIBS}" = "y" ]
then
  Check_Space $UNIXDIR $Archlib_Size "GRNUCDP Archive Libraries"
  echo "Installing GRNUCDP Archive Libraries"
  echo "Installing GRNUCDP Archive Libraries" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grarchlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${tarcpu}" = "BOTH" ]
  then
    getfile grarchlib.${OTHERSUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  fi
  
fi


#
# install Raster
#

if [ "${RASTER}" = "y" ]
then
  Check_Space $UNIXDIR $Raster_Size "Raster Component"
  echo "Installing GRNUCDP Raster Component"
  echo "Installing GRNUCDP Raster Component" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile cmdraster2.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "${SUFF}" = "zx" ]
  then
    getfile cmdraster2.ssl | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi

    getfile grraster.ssl | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  else
    getfile cmdraster2.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1;AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi

    getfile grraster.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  fi

  date >>$LOGFILE 2>&1
  grep cmdraster2.cmd ${UNIXDIR}/config/cmd_tbl_list >/dev/null 2>&1
  if [ $? != 0 ]
  then
    echo "cmdraster2.cmd" >> ${UNIXDIR}/config/cmd_tbl_list
  fi
  grep raster ${UNIXDIR}/config/english/message_file >/dev/null 2>&1
  if [ $? != 0 ]
  then
    cat <<- EOF >> ${UNIXDIR}/config/english/message_file
messages/rasterm2.msg,in_mem
messages/rasterp2.msg,in_mem
messages/rasters2.msg,in_mem
EOF
  fi

  if [ "${RASTERINCSPC}" = "y" ]
  then
    echo "Installing GRNUCDP Raster Specs and Includes"
    echo "Installing GRNUCDP Raster Specs and Includes" >>$LOGFILE 2>&1
    echo
    getfile rastincspc.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
  fi
fi


#
# install ppl examples
#
if [ "${EXAMPLES}" = "y" ]
then
  Check_Space $UNIXDIR $Examples_Size "PPL Examples"
  echo "Installing GRNUCDP PPL Examples"
  echo "Installing GRNUCDP PPL Examples" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grpplex.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

fi

#
# install integration utilities
#
if [ "${INTEG}" = "y" ]
then
  Check_Space $UNIXDIR $Integ_Size "Integration Utilities"
  echo "Installing GRNUCDP Integration Utilities"
  echo "Installing GRNUCDP Integration Utilities" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grinteg.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi

  if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
  then
    rm -f /usr/bin/newsymbols
    rm -f /usr/bin/newsymbols.awk
    ln -s $UNIXDIR/bin/newsymbols /usr/bin
    ln -s $UNIXDIR/bin/newsymbols.awk /usr/bin
  else
    rm -f $INGRHOME/bin/newsymbols
    rm -f $INGRHOME/bin/newsymbols.awk
    ln -s $UNIXDIR/bin/newsymbols $INGRHOME/bin
    ln -s $UNIXDIR/bin/newsymbols.awk $INGRHOME/bin
  fi
fi


#
# install Font Library
#
if [ "${FONTLIB}" = "y" ]
then
  Check_Space $UNIXDIR $Fontlib_Size "GRNUC Font Library"
  echo "Installing GRNUCDP Font Library"
  echo "Installing GRNUCDP Font Library" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grfontlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi
fi

#
# install NT Font Resource Library
#
if [ "${NTPLOT}" = "y" ]
then
  Check_Space $UNIXDIR $NTplot_Size "NT Font Resource Library"
  echo "Installing NT Font Resource Library"
  echo "Installing NT Font Resource Library" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile ntplotlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi
fi

#
# install IGDS Cell Files
#
if [ "${IGDSCL}" = "y" ]
then
  Check_Space $UNIXDIR $IGDScl_Size "GRNUC IGDS Cell Files"
  echo "Installing GRNUCDP IGDS Cell Files"
  echo "Installing GRNUCDP IGDS Cell Files" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grigdscl.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi
fi

#

#
# Load the messages/src stuff
#
if [ "${MSGSRC}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Msgsrc_Size} "GRNUC Message Source Files"

  echo Installing GRNUCDP Message Source Files
  echo Installing GRNUCDP Message Source Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grmsgsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# install ATPs
#
if [ "${ATPS}" = "y" ]
then
    echo "Installing GRNUCDP ATPs"
    echo "Installing GRNUCDP ATPs" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile gratp.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
    getfile gratp.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
fi

if [ "${CVRT}" = "y" ]
then

  Check_Space ${UNIXDIR} ${Cvrt_Size} "Converter"

  echo Installing GRNUCDP Converter
  echo Installing GRNUCDP Converter >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile cvrt.p | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  cd ${UNIXDIR}/cvrt
  getfile precvrt.p | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
  cd ${UNIXDIR}
 
  echo > $pdtmp
  if [ -f $pd ]; then sed '/\"Arp\"/d' $pd > $pdtmp; fi
  echo "\"Arp\" I/ARP GRmodule Arp ${UNIXDIR}/cvrt" >> $pdtmp
  mv $pdtmp $pd

fi


find $UNIXDIR -print | xargs chown $LOGNAME
find $UNIXDIR -print | xargs chmod ugo+rw
find $UNIXDIR -type d -print | xargs chmod ugo+x
find $UNIXDIR/userdata -print | xargs chmod ugo+wx
find $UNIXDIR/bin -print | xargs chmod ugo+x
if [ "$CVRT" = "y" ]
then
  find $UNIXDIR/cvrt/bin -print | xargs chmod ugo+x
fi


date >>$LOGFILE 2>&1

if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
 then
if inqlgexist
then
  cat << EO > /usr/tmp/agrnuc.ftc
#include <ftdefs.h>
DEFINE TYPE NUC_OBJECT_SPACE
  ICON               NUC_OBJECT_SPACE
  FILE_DESCRIPTION   "Design File (Object Based)"
 BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  OR
  BINARY_DATA
  AND CONTENT 0 SHORT 0x4d4f
  AND CONTENT 2 SHORT 0x0002
COMMAND:COPY "${UNIXDIR}/bin/cpOS"
COMMAND CdEx(${UNIXDIR}/bin/.lglastprod #c/#f)
COMMAND_DESCRIPTION "Run MDEM last saved"
COMMAND CdEx(${UNIXDIR}/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....)
COMMAND_DESCRIPTION "Run MDEM Product"
END
EO
  lgappcmds /usr/tmp/agrnuc.ftc
fi
fi
