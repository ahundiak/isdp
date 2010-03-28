#
# Copyright Intergraph Corporation	14-DEC-1986
#
# GRNUC Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#
# History
#
#       09 Oct 1990     DLB     Removed option includes from runtime
#	14 Jan 1990	AIC	Converted to use getanswer.
#	14 Nov 1989	AIC
#	19 Jul 1991     TGM     created prompt for local plot files
#	07 Nov 1991     TGM     implemented BOM functionality
#       29 Sep 1993     SCW     added INGRHOME support
#       27 Oct 1993     SCW     added $INGRHOME ln for dso
#       05 Jan 1994     SCW     removed all references to SunOS 4.X
#       05 Jan 1994     SCW     added extra prompting for invalid responses
#       07 Jan 1994     JSD     added GDE installation
#       11 Jan 1994     SCW     fixed syntax error
#       24 Feb 1994     SCW     Changed Check_Space() for Solaris to use Free
#       08 Mar 1994     SCW     Changed protections once loaded
#       09 Mar 1994     SCW     Changed chmod to use ugo
#       18 Aug 1994     SCW     Added ISL processor type
#       23 Aug 1994     SCW     Corrected syntax error in isl code
#       30 Sep 1994     SCW     Added ntplotlib package
#       05 OCT 1994     KBR     Removed raster install for isl CR# 119422937
#       05 OCT 1994     SCW     Corrected syntax for CR above
#       05 OCT 1994     SCW     Cleaned up raster prompting for Pload
#       06 OCT 1994     KBR     fixed syntax error for isl
#       30 JAN 1995     sam     Fix for TR 119422370. Need  write permission
#				for in*list & mm*list - asci data files.
#       14 MAR 1995     SCW     Added XGL prompting
#       13 JUL 1995     SCW     Changed Check_Space() for all boxes to use Free
#       19 JUL 1995     SCW     Changed XGL prompting for 2.4 or higher OS
#       02 NOV 1995     SCW     Added deltools logic for auto FB sensing
#       06 NOV 1995     SCW     Changed logic for auto FB sensing
#       30 NOV 1995     SCW     Changed prompt for Font Library installation
#

QUESTPATH=/usr/tmp
DEFDIR=$4

if [ "$0" = "install.isl" ]
then
  SUFF=isl
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.sgi" ]
then
  SUFF=sgi
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
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

if [ "$SUFF" = "p" ]
then
  tarcpu=`inqcpuid`
  if [ "$tarcpu" = "C400" ]
  then
     SUFF="p4"
  fi
fi

getmsg ()  {
grep $1 $QUESTPATH/prompts.eng | cut -d' ' -f2- | tr -d "\""
}

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  Disk_Space=`Free -f $checkDIR`

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires approximately ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

if [ -f /usr/tmp/BOM ]
then
 BOM=y
 SVPRODNAME=$PRODNAME
 PRODNAME=MDEMBOM
 export DEFAULTS=y
fi

UNIXDIR=$DEFDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

Grnuc_Size=9500
LG_Size=250
Examples_Size=500
Basinc_Size=1600
Fontlib_Size=7000
NTplot_Size=14000
Pplcvrt_Size=100
Msgsrc_Size=700
Raster_Size=1700
Gde_Size=450
Cvrt_Size=47000
Plot_Size=2400
IGDScl_Size=2200

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data

if [ "$BOM" = "y" ] 
then
   PLOT="n"
   BASE=`getanswer "$(getmsg EMBASE)   (y/n/h)? " "y"`
   if [ "$PROMPTXGL" = "y" ]
   then
     xgl=`getanswer "$(getmsg EMXGL)   (y/n/h)? " "n"`
   fi
   meas=`getanswer "$(getmsg EMMEAS)   (e/m/h)? " "e"`
   EXAMPLES=`getanswer "$(getmsg EMPPLEX)   (y/n/h)? " "n"`
   BASINC=`getanswer "$(getmsg EMADVPPL)   (y/n/h)? " "n"`
   FONTLIB=`getanswer "$(getmsg EMFONT)   (y/n/h)? " "n"`
   NTPLOT=`getanswer "$(getmsg EMNTPLOT)   (y/n/h)? " "n"`
   IGDSCL=`getanswer "$(getmsg EMIGDSCL)   (y/n/h)? " "n"`

   if [ "$SUFF" = "isl" ]
   then
     RASTER="n"
   else
     RASTER=`getanswer "$(getmsg EMRASTER)   (y/n/h)? " "n"`
   fi

   MSGSRC=`getanswer "$(getmsg EMMSGSRC)   (y/n/h)? " "n"`
   GDE=`getanswer "$(getmsg EMGDEUTI)   (y/n/h)? " "n"`
   CVRT=`getanswer "$(getmsg EMCVRT)   (y/n/h)? " "n"`
   if [ "$SUFF" = "ssl" -o "$SUFF" = "zx" -o "$SUFF" = "isl" -o "$SUFF" = "sgi" ]
   then
     CVRT="n"
   fi


else
#
# Get responses to prompts
#
GRVERS=`echo $PRODVERSION | cut -d'.' -f1-3 | sed "s/^0//g" | sed "s/\.0/\./g"`
echo "Graphics Nucleus Version ${GRVERS}"
echo "\nThe base GRNUC Runtime Platform requires approximately ${Grnuc_Size} blocks."
while true
do
  BASE=`getanswer \
  "Install the base GRNUC Runtime Platform in ${UNIXDIR} (y/n) ?" "y"`
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
    "Install GRNUC platform which supports XGL display (y/n) ?" "n"`
    case "$xgl" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

while true
do
  meas=`getanswer \
  "Use English or Metric unit of measurement         (e/m) ?" "e"`
  case "$meas" in
    e|m ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUC PPL Examples require approximately ${Examples_Size} blocks."
while true
do
  EXAMPLES=`getanswer "Install the GRNUC PPL Examples (y/n) ?" "n"`
  case "$EXAMPLES" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUC Basic Include Files require approximately ${Basinc_Size} blocks."
echo "They are required for compiling I/NC ppl and other basic ppl programs"
while true
do
  BASINC=`getanswer "Install the GRNUC Basic Include Files (y/n)?" "n"`
  case "$BASINC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "${SUFF}" = "isl" -o "${SUFF}" = "ssl" -o "$SUFF" = "zx" -o "${SUFF}" = "sgi" ]
then
   PLOT="n"
else
  echo "\nThe GRNUC Plotting Files require approximately ${Plot_Size} blocks."
  echo "They are required for local plotting."
  while true
  do
    PLOT=`getanswer "Install the GRNUC Plotting Files (y/n) ?" "n"`
    case "$PLOT" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi


echo "\nThe GRNUC Font Library requires approximately ${Fontlib_Size} blocks."
while true
do
  FONTLIB=`getanswer "Install the GRNUC Plotting Font Library (y/n) ?" "n"`
  case "$FONTLIB" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe NT Font Resource Library requires approximately ${NTplob_Size} blocks."
echo "It is required only for NT plot servers."
while true
do
  NTPLOT=`getanswer "Install the NT Plotting Font Resource Library (y/n) ?" "n"`
  case "$NTPLOT" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUC IGDS Cell Files require approximately ${IGDScl_Size} blocks."
echo "They are required for customizing fonts"
while true
do
  IGDSCL=`getanswer "Install the GRNUC IGDS Cell Files (y/n) ?" "n"`
  case "$IGDSCL" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "$SUFF" = "isl" ]
then
  RASTER="n"
else
  echo "\nThe GRNUC Raster Component requires approximately ${Raster_Size} blocks."
  while true
  do
    RASTER=`getanswer "Install the GRNUC Raster Component (y/n) ?" "y"`
    case "$RASTER" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

echo "\nThe GRNUC Message Source Files require approximately ${Msgsrc_Size} blocks."
while true
do
  MSGSRC=`getanswer "Install the GRNUC Message Source Files (y/n) ?" "n"`
  case "$MSGSRC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo "\nThe GRNUC GDE Utility requires approximately ${Gde_Size} blocks."
echo "It allows you to examine some information in a design file."
GDE=`getanswer "Install the GRNUC GDE Utility (y/n) ?" "n"`

if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
then
  echo "\nThe GRNUC Design File Converter requires approximately ${Cvrt_Size} blocks."
  while true
  do
    CVRT=`getanswer "Install the GRNUC Design File Converter (y/n) ?" "n"`
    case "$CVRT" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

fi

#
# fix the product data file
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
# Load GRNUC
#
if [ "$BASE" = "y" ]
then
  Check_Space $UNIXDIR $Grnuc_Size "GRNUC"

  rm -f config/dload/init/*.o

  echo
  echo Installing base GRNUC Runtime Platform in $UNIXDIR
  echo Installing base GRNUC Runtime Platform in $UNIXDIR >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grnuc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile grconfig.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile grversno.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi  

  if [ "${SUFF}" = "sgi" -o "${SUFF}" = "ssl" -o "$SUFF" = "zx" ]
  then
    getfile grtransos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  getfile grinclude.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile grppl.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  if [ ! -d userdata ]
  then
     mkdir userdata
  fi
  chmod 777 userdata

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

if [ "$meas" = "m" ]
then
  echo
  echo " Changing units of measurement to metric"
  echo 
  cp $UNIXDIR/config/uom_table.met $UNIXDIR/config/uom_table
  cp $UNIXDIR/config/seed3d.dgn.met $UNIXDIR/config/seed3d.dgn
fi

#
# copy echopath to /usr/bin. This is done unconditionally to support remote
# installation of the base product. Copy is used because MDS also delivers
# echopath.
#
# rm -f /usr/bin/echopath
if [ -f $UNIXDIR/bin/echopath ]
then 
  chmod ugo+x $UNIXDIR/bin/echopath
  cp $UNIXDIR/bin/echopath /usr/bin
fi


#
# Load the Looking Glass Interface Files
#
if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
then
  if inqlgexist
  then
    Check_Space $UNIXDIR $LG_Size "GRNUC Looking Glass Interface"

    echo Installing GRNUC Looking Glass Interface
    echo Installing GRNUC Looking Glass Interface >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile grnuclg.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi
fi

#
# Load the PPL examples
#
  if [ "$EXAMPLES" = "y" ]
  then
    Check_Space ${UNIXDIR} ${Examples_Size} "GRNUC PPL Examples"
  
    echo Installing GRNUC PPL Examples
    echo Installing GRNUC PPL Examples >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1
  
    getfile grpplex.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

#
# Load the basic include files
#
if [ "$BASINC" = "y" ]
then
  Check_Space ${UNIXDIR} ${Basinc_Size} "GRNUC Basic Include Files"

  echo Installing GRNUC Basic Include Files
  echo Installing GRNUC Basic Include Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grbasinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi


#
# Load the plot library
#
if [ "${PLOT}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Plot_Size} "GRNUC Plotting Files"

  echo Installing GRNUC Plotting Files
  echo Installing GRNUC Plotting Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grdplot.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi


#
# Load the font library
#
if [ "${FONTLIB}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Fontlib_Size} "GRNUC Font Library"

  echo Installing GRNUC Font Library
  echo Installing GRNUC Font Library >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grfontlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# Load the NT font resrc library
#
if [ "${NTPLOT}" = "y" ]
then
  Check_Space ${UNIXDIR} ${NTplot_Size} "NT Font Resource Library"

  echo Installing NT Font Resource Library
  echo Installing NT Font Resource Library >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile ntplotlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# Load the IGDS cell files
#
if [ "${IGDSCL}" = "y" ]
then
  Check_Space ${UNIXDIR} ${IGDScl_Size} "GRNUC IGDS Cell Files"

  echo Installing GRNUC IGDS Cell Files
  echo Installing GRNUC IGDS Cell Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grigdscl.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi



#
# install raster
#
if [ "${RASTER}" = "y" ]
then
  Check_Space $UNIXDIR $Raster_Size "Raster Component"
  echo Installing GRNUC Raster Component
  echo Installing GRNUC Raster Component >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile cmdraster2.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  if [ "${SUFF}" = "zx" ]
  then
    getfile cmdraster2.ssl | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    getfile grraster.ssl | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  else
    getfile cmdraster2.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1;AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    getfile grraster.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

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

  if [ ${AOK} != 0 ] ; then exit $AOK; fi
fi


#
# Load the messages/src stuff
#
if [ "${MSGSRC}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Msgsrc_Size} "GRNUC Message Source Files"

  echo Installing GRNUC Message Source Files
  echo Installing GRNUC Message Source Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grmsgsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi


#
# Load the GDE Utility
#
if [ "${GDE}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Gde_Size} "GDE Utility"

  echo Installing GDE Utility
  echo Installing GDE Utility >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grgde.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "${CVRT}" = "y" ]
then
  Check_Space ${UNIXDIR} ${Cvrt_Size} "Converter"

  echo Installing GRNUC Design File Converter
  echo Installing GRNUC Design File Converter >>$LOGFILE 2>&1
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
  chmod ugo-w ${UNIXDIR}/cvrt/bin/drive 

  echo > $pdtmp
  if [ -f $pd ]; then sed '/\"Arp\"/d' $pd > $pdtmp; fi
  echo "\"Arp\" I/ARP GRmodule Arp ${UNIXDIR}/cvrt" >> $pdtmp
  mv $pdtmp $pd

fi


if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
then
if inqlgexist
then
LG_APPL="mds cool flow design fold msm punch burn cmm mill maxmill nc turn wire nest fem femp"
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

if [ "${SUFF}" = "ssl" -o "${SUFF}" = "zx" ]
 then
cat << EO >> /usr/tmp/agrnuc.ftc
REDEFINE TYPE          DEM_FEMRASNA_OS
  ICON               DEM_FEMRASNA_OS
	FILE_DESCRIPTION "I/Fem-Rasna Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Femrasna"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Femrasna"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Femrasna"
END

REDEFINE TYPE          DEM_COOL_OS
  ICON               DEM_COOL_OS
	FILE_DESCRIPTION "I/Cool Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Cool"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Cool"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Cool"
END

REDEFINE TYPE          DEM_WARP_OS
  ICON               DEM_WARP_OS
	FILE_DESCRIPTION "I/Warp Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Warp"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Warp"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Warp"
END


REDEFINE TYPE          DEM_FLOW_OS
  ICON               DEM_FLOW_OS
	FILE_DESCRIPTION "I/Flow Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Flow"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Flow"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Flow"
END


REDEFINE TYPE          DEM_PROTOTYPE_OS
  ICON               DEM_PROTOTYPE_OS
	FILE_DESCRIPTION "I/Prototype Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Proto"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Proto"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Proto"
END

REDEFINE TYPE          DEM_FEM_OS
  ICON               DEM_FEM_OS
	FILE_DESCRIPTION "I/Fem Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Fem"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Fem"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Fem"
END

REDEFINE TYPE          DEM_RASNA_OS
  ICON               DEM_RASNA_OS
	FILE_DESCRIPTION "I/RASNA Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Rasna"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Rasna"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Rasna"
END


REDEFINE TYPE		DEM_DESIGN_OS
  ICON			DEM_DESIGN_OS
	FILE_DESCRIPTION "I/Design Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Design"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Design"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Design"
END


REDEFINE TYPE          DEM_FEMP_OS
  ICON               DEM_FEMP_OS
  FILE_DESCRIPTION   "I/Fem-p Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 414 STRING "Fem-p"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 414 STRING "Fem-p"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Fem-p"
END

REDEFINE TYPE          DEM_FOLD_OS
  ICON               DEM_FOLD_OS
  FILE_DESCRIPTION   "I/Fold Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 414 STRING "Fold"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 414 STRING "Fold"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Fold"
END


REDEFINE TYPE          DEM_DRAFT_OS
  ICON               DEM_DRAFT_OS
  FILE_DESCRIPTION   "I/Draft Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Draft"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Draft"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Draft"
END



REDEFINE TYPE          DEM_MDS_OS
  ICON               DEM_MDS_OS
  FILE_DESCRIPTION   "I/Mds Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Mds"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Mds"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Mds"
END


REDEFINE TYPE          DEM_EMS_OS
  ICON               DEM_EMS_OS
  FILE_DESCRIPTION   "I/Ems Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Ems"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Ems"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Ems"
END



REDEFINE TYPE          DEM_MSM_OS
  ICON               DEM_MSM_OS
  FILE_DESCRIPTION   "I/Msm Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Msm"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Msm"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 412 STRING "Msm"
END


REDEFINE TYPE          DEM_PUNCH_OS
  ICON               DEM_PUNCH_OS
  FILE_DESCRIPTION   "I/Punch Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Punch"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Punch"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Punch"
END

REDEFINE TYPE          DEM_BURN_OS
  ICON               DEM_BURN_OS
  FILE_DESCRIPTION   "I/Burn Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Burn"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Burn"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Burn"
END

REDEFINE TYPE          DEM_CMM_OS
  ICON               DEM_CMM_OS
  FILE_DESCRIPTION   "I/Cmm Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Cmm"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Cmm"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Cmm"
END

REDEFINE TYPE          DEM_MILL_OS
  ICON               DEM_MILL_OS
  FILE_DESCRIPTION   "I/Mill Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Mill"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Mill"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Mill"
END

REDEFINE TYPE          DEM_MAXMILL_OS
  ICON               DEM_MAXMILL_OS
  FILE_DESCRIPTION   "I/Maxmill Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Maxmill"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Maxmill"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Maxmill"
END

REDEFINE TYPE          DEM_NC_OS
  ICON               DEM_NC_OS
  FILE_DESCRIPTION   "I/Nc Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Nc"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Nc"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Nc"
END

REDEFINE TYPE          DEM_TURN_OS
  ICON               DEM_TURN_OS
  FILE_DESCRIPTION   "I/Turn Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Turn"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Turn"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Turn"
END

REDEFINE TYPE          DEM_WIRE_OS
  ICON               DEM_WIRE_OS
  FILE_DESCRIPTION   "I/Wire Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Wire"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Wire"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Wire"
END

REDEFINE TYPE          DEM_NEST_OS
  ICON               DEM_NEST_OS
  FILE_DESCRIPTION   "I/Nest Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 LONG 0x00040004
  AND CONTENT 412 STRING "Nest"
  OR
  BINARY_DATA
  AND CONTENT 0 LONG 0x00050004
  AND CONTENT 412 STRING "Nest"
  OR
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "Nest"
END

REDEFINE TYPE		DEM_RASMDS_OS
  ICON			DEM_RASMDS_OS
	FILE_DESCRIPTION "I/RasMDS Design File (Object Based)"
  BINARY_DATA
  AND CONTENT 0 BYTE 0x4f
  AND CONTENT 1 BYTE 0x4d
  AND CONTENT 2 BYTE 0x02
  AND CONTENT 3 BYTE 0x00
  AND CONTENT 414 STRING "RasMDS"
END

EO
fi

for lg_appl in $LG_APPL
do
if [ ! -f /usr/lib/lg/lg_ftc/app_ftc/${lg_appl}.ftc ]
then
    Lg_appl=`echo $lg_appl | tr "[a-z]" "[A-Z]"`
    cat << EOI >> /usr/tmp/agrnuc.ftc
REDEFINE TYPE DEM_${Lg_appl}_OS
COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EOI
 fi
done
if [ ! -f /usr/lib/lg/lg_ftc/app_ftc/proto.ftc ]
then
    cat << EOT >> /usr/tmp/agrnuc.ftc
REDEFINE TYPE DEM_PROTOTYPE_OS
COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EOT
fi
  
  lgappcmds /usr/tmp/agrnuc.ftc
  cp /usr/tmp/agrnuc.ftc ${UNIXDIR}/agrnuc.ftc
fi

if inqlgexist
then
  cat << EO > /usr/tmp/draft.ftc
#include <ftdefs.h>
APPEND_COMMANDS TAIL DEM_DRAFT
COMMAND  CdEx(/bin/ksh -c #c/.lgshell)
COMMAND_DESCRIPTION "Run I/DRAFT"
END
REDEFINE TYPE DEM_DRAFT_OS
COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '${UNIXDIR}/bin/.lgshell emscs -f #c/#f'"
COMMAND_DESCRIPTION "Run I/DRAFT"
END
APPEND_COMMANDS TAIL DEM_DRAFT_OS
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END

EO
  lgappcmds /usr/tmp/draft.ftc
fi

if inqlgexist
then
  cat << EO > /usr/tmp/ems.ftc
#include <ftdefs.h>
APPEND_COMMANDS TAIL DEM_EMS
COMMAND  CdEx(/bin/ksh -c #c/.lgshell)
COMMAND_DESCRIPTION "Run I/EMS"
END
REDEFINE TYPE DEM_EMS_OS
COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '${UNIXDIR}/bin/.lgshell -f #c/#f'"
COMMAND_DESCRIPTION "Run I/EMS"
END
APPEND_COMMANDS TAIL DEM_EMS_OS
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....'"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EO
  lgappcmds /usr/tmp/ems.ftc
fi
fi #endif not on sgi or solaris

#
# Set the protections
#

find $UNIXDIR -print | xargs chown sys
find $UNIXDIR -print | xargs chgrp bin
find $UNIXDIR -print | xargs chmod ugo+r-wx
find $UNIXDIR -type d -print | xargs chmod ugo+x
find $UNIXDIR/userdata -print | xargs chmod ugo+wx
find $UNIXDIR/bin -print | xargs chmod ugo+x
if [ "$CVRT" = "y" ]
then
  find $UNIXDIR/cvrt/bin -print | xargs chmod ugo+x
fi
chmod +w $UNIXDIR/ppl/bin/in*list
chmod +w $UNIXDIR/ppl/bin/mm*list
exit 0
