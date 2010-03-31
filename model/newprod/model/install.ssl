#
# Copyright Intergraph Corporation  14-DEC-1986
#
# MODEL Product Installation
#
#  DLB 10/09/90 removed option includes in runtime
#  DLB 07/02/90 removed the option to download weld
#  DLB 06/28/90 added support for more .p files
#  TGM 02/25/91 removed modelweld.p, now in grnuc
#  TGM 06/26/91 removed modelgde.p, now in grnuc
#  TGM 11/07/91 added BOM support                                  
#  SCW 09/15/93 added solaris support
#  SCW 09/30/93 added INGRHOME support
#  SCW 10/22/93 added mdshlib.sgi package
#  SCW 12/29/93 removed config/lock directory generation code
#  SCW 01/03/94 removed the setting of the setuid/setgid bit
#  SCW 01/03/94 added extra prompting for invalid responses
#  SCW 01/05/94 removed references to SunOS 4.X
#  SCW 02/24/94 changed Check_Space() to use Free for Solaris
#  SCW 03/08/94 changed protections once loaded
#  SCW 03/09/94 changed chmod to use ugo
#  SCW 08/19/94 added isl processor type
#  SCW 03/07/95 added XGL prompting
#  SCW 07/12/95 added advanced math lib installation
#  SCW 07/13/95 changed Check_Space() to use Free for all platforms
#  SCW 07/19/95 changed XGL prompting for 2.4 or higher OS
#  SCW 11/02/95 Added extra logic for automated FB sensing
#  SCW 11/06/95 Changed logic for automated FB sensing
#  SCW 06/04/96 Added advanced ppl support for XGL
#  SCW 12/31/96 Added EMS ultra-lite entry in product_data
#  SCW 01/15/97 Removed EMS Ultra-lite product_data entry 
#  SCW 12/11/97 Added package support for x86 Solaris 2.6
#  SCW 12/12/97 Corrected OS checking on Solaris
#  SCW 12/19/97 Modified SNUC dependency check to CLIPPER only
#  SCW 01/21/98 Changed HSPLOT prompt default to "y"
#

PROMPTXGL="n"     # Prompting for Solaris XGL build
EMSPATH=/usr/tmp
DEFDIR=$4
LoadOptional="n"

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  export INGRHOME=${INGRHOME:-/opt/ingr}

  OSver="$(uname -r | cut -c3)"
  if [ "${OSver}" -ge "6" ]  # Solaris 2.6 or higher
  then
    LoadOptional="y"
  fi
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="ssl"
  export INGRHOME=${INGRHOME:-/opt/ingr}

  OSver="$(uname -r | cut -c3)"
  if [ "${OSver}" -ge "4" ]  # Solaris 2.4 or higher
  then
    PROMPTXGL="y"
  fi
fi

if [ "$0" = "install.sgi" ]
then
  SUFF="sgi"
  export INGRHOME=${INGRHOME:-/opt/ingr}
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

getmsg ()  {
grep $1 $EMSPATH/prompts.eng | cut -d' ' -f2- | tr -d "\""
}

if [ -f /usr/tmp/BOM ]
then
  BOM=y
  SVPRODNAME=$PRODNAME
  PRODNAME=MDEMBOM
  DEFAULTS=y
fi

UNIXDIR=$DEFDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

#>${LOGFILE}

Model_Size=46300
Binc_Size=300
Mthlb_Size=1500
HSPlot_Size=3000
Msgsrc_Size=400
Cvrt_Size=6000

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  Disk_Space=`Free -f $checkDIR`

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

MODVERS=`echo $PRODVERSION | cut -d'.' -f1-3 | sed "s/^0//g" | sed "s/\.0/\./g"`
echo "Modeling Nucleus Version "$MODVERS

#
# Initialize all responses to an invalid type
#

answer="h"
meas="h"
BINC="h"
hsplotanswer="h"
rendanswer="h"
MSGSRC="h"
cnvanswer="h"
mathlb="h"

if [ "$BOM" = "y" ] 
then
  answer=`getanswer "$(getmsg EMBASE)   (y/n/h)? " "y"`
  if [ "$PROMPTXGL" = "y" ]
  then
    xgl=`getanswer "$(getmsg EMXGL)   (y/n/h)? " "n"`
  fi
  meas=`getanswer "$(getmsg EMMEAS)   (e/m/h)? " "e"`
  BINC=`getanswer "$(getmsg EMADVPPL)   (y/n/h)? " "n"`
  mathlb=`getanswer "$(getmsg EMMTHPPL)   (y/n/h)? " "n"`
  hsplotanswer=`getanswer "$(getmsg EMSHDPLOT)   (y/n/h)? " "y"`
  rendanswer=`getanswer "$(getmsg EMRENDER)   (y/n/h)? " "n"`
  MSGSRC=`getanswer "$(getmsg EMMSGSRC)   (y/n/h)? " "n"`
  cnvanswer=`getanswer "$(getmsg EMCVRT)   (y/n/h)? " "n"`
  if [ "$hsplotanswer" = "y" ] && [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
  then
   if [ ! -d /usr/ip32/ip/snuc ]
   then
     echo "^G"
     echo "************************** WARNING *********************************"
     echo "   You must download IP_SNUC (SP01127) before shaded plotting will "
     echo "   install correctly.  Changing shaded plotting response to n"
     echo "************************** WARNING *********************************"
     hsplotanswer="n"
   fi
  fi

else

xgl="h"
echo
echo \
The standard MODEL platform requires approximately ${Model_Size} blocks.
while true
do
  answer=`getanswer \
  "Install the standard MODEL platform at ${UNIXDIR} (y/n) ?" "y"`
  case "$answer" in
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
    "Install MODEL platform which supports XGL display (y/n) ?" "n"`
    case "$xgl" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

echo
while true
do
  meas=`getanswer \
  "Use English or Metric units of measure (e/m) ?" "e"`
  case "$meas" in
    e|m ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo
echo \
The MODEL Basic Include Files for compiling I/NC ppl and other basic ppl
echo \
programs require approximately ${Binc_Size} blocks.
while true
do
  BINC=`getanswer "Install the MODEL Basic Include Files locally (y/n)?" "n"`
  case "$BINC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo
echo \
The Math Library Files for advanced ppl require \
approximately ${Mthlb_Size} blocks.
while true
do
  mathlb=`getanswer "Install the Advanced PPL Math Libraries locally (y/n)?" "n"`
  case "$mathlb" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

echo
echo \
Shaded Plotting requires about ${HSPlot_Size} blocks of disk space.
while true
do
  hsplotanswer=`getanswer "Install Shaded Plotting locally (y/n) ?" "y"`
  case "$hsplotanswer" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done
if [ "$hsplotanswer" = "y" ] && [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
then
  if [ ! -d /usr/ip32/ip/snuc ]
  then
    echo "^G"
    echo "************************** WARNING *********************************"
    echo "   You must download IP_SNUC (SP01127) before shaded plotting will "
    echo "   install correctly.  Changing shaded plotting response to n"
    echo "************************** WARNING *********************************"
    hsplotanswer="n"
  fi
fi

#echo
#echo \
#MODEL Rendering requires about ${Render_Size} blocks of disk space.
#while true
#do
#  rendanswer=`getanswer "Do you want the Model Rendering Texture files (y/n)?" "n"`
#  case "$rendanswer" in
#    y|n ) break;;
#       *) echo "\nInvalid. Try again\n" ;;
#  esac
#done

echo \
"\nThe MODEL Message Source Files require approximately ${Msgsrc_Size} blocks."
while true
do
  MSGSRC=`getanswer "Install the MODEL Message Source Files locally (y/n) ?" "n"`
  case "$MSGSRC" in
    y|n ) break ;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "${SUFF}" = "p" ]
then
  echo "\nThe MODEL Version Converter requires about ${Cvrt_Size} blocks."
  while true
  do
    cnvanswer=`getanswer "Install the MODEL Version Converter locally (y/n) ?" "n"`
    case "$cnvanswer" in
      y|n ) break ;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
else
  cnvanswer="n"
fi

fi

if [ "${SUFF}" = "p" ]
then
#
# determine if target machine in c100 or c300
#
tarcpu=`inqcpuid`

# tarcpu=C100

 if [ "$FORCEC400" != "" ]
 then
  tarcpu="C400"
 fi

 if [ "$FORCEC100" != "" ]
 then
  tarcpu="C100"
 fi
else
 tarcpu=""
fi

if [ "$tarcpu" = "C400" ]
then 
  SUFF="p4"
fi

#
# Load XGL/ZX display if positive response to XGL prompt
#
if [ "$xgl" = "y" ]
then
  SUFF="zx"
fi

#
# Load MODEL
#
if [ "$answer" = "y" ]
then
  Check_Space $UNIXDIR $Model_Size "MODEL"

  if [ "${SUFF}" = "isl" ]
  then
    echo Installing MODEL in $UNIXDIR for INTEL CPU
    echo Installing MODEL in $UNIXDIR for INTEL CPU >>$LOGFILE 2>&1
  fi

  if [ "${SUFF}" = "ssl" ]
  then
    echo Installing MODEL in $UNIXDIR for SPARC CPU
    echo Installing MODEL in $UNIXDIR for SPARC CPU >>$LOGFILE 2>&1
  fi

  if [ "${SUFF}" = "zx" ]
  then
    echo Installing MODEL in $UNIXDIR for SPARC XGL CPU
    echo Installing MODEL in $UNIXDIR for SPARC XGL CPU >>$LOGFILE 2>&1
  fi

  if [ "${SUFF}" = "sgi" ]
  then
    echo Installing MODEL in $UNIXDIR for MIPS CPU
    echo Installing MODEL in $UNIXDIR for MIPS CPU >>$LOGFILE 2>&1
  fi

  if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
  then
    echo Installing MODEL in $UNIXDIR for CLIPPER $tarcpu
    echo Installing MODEL in $UNIXDIR for CLIPPER $tarcpu >>$LOGFILE 2>&1
  fi

  date >>$LOGFILE 2>&1
  if [ "${SUFF}" = "isl" -a "$LoadOptional" = "y" ]
  then
    getfile model26.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
  else
    getfile model.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
  fi
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile modelconf.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
  getfile modelconf.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi


  #
  # install DSO's in $MODEL/src_shlib for SGI
  #

  if [ "${SUFF}" = "sgi" ]
  then
    getfile mdshlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
    ln -s ${UNIXDIR}/src_shlib/*.so ${INGRHOME}/lib/
  fi

  getfile modversno.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  if [ "${SUFF}" = "sgi" -o "${SUFF}" = "ssl" -o "${SUFF}" = "zx" ]
  then
    getfile transos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  #
  # fix the product data file
  #
  echo > $pdtmp
  if [ -f $pd ]; then sed '/\"Model\"/d' $pd > $pdtmp; fi
  echo "\"Model\" I/MODEL GRmodule Model:Dignuc:Grnuc $UNIXDIR" >> $pdtmp
  mv $pdtmp $pd
fi

if [ "$meas" = "m" ]
then
  echo
  echo "Changing Units of Measure to Metric"
  echo
  cp $UNIXDIR/config/seed_mod.met $UNIXDIR/config/seed_file
fi

#
# Load the basic include files
#
if [ "$BINC" = "y" ]
then
  Check_Space $UNIXDIR $Binc_Size "MODEL Basic Include Files"

  echo
  echo Installing MODEL Basic Include Files in $UNIXDIR
  echo Installing MODEL Basic Include Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile modelbinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# Load the math libraries
#
if [ "$mathlb" = "y" ]
then

  echo
  echo Installing Advanced Math Libraries in $UNIXDIR
  echo Installing Advanced Math Libraries in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  if [ "$SUFF" = "p" ]
  then 
    getfile obj_ot_c1.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

  if [ "$SUFF" = "p4" ]
  then
    getfile obj_ot_c4.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

  if [ "$SUFF" = "isl" ]
  then
    getfile obj_ot_is.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

  if [ "$SUFF" = "ssl" -o "$SUFF" = "zx" ]
  then
    getfile obj_ot_ss.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

  if [ "$SUFF" = "sgi" ] 
  then
    getfile obj_ot_sg.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi

fi

#
# Load the version converter
#
if [ "$cnvanswer" = "y" ]
then

  Check_Space $UNIXDIR $Cvrt_Size "MODEL version converter"

  echo
  echo Installing MODEL Version Converter in $UNIXDIR
  echo Installing MODEL Version Converter in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile cvrt.p | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi

fi

#
# Load shaded plotting
#
if [ "$hsplotanswer" = "y" ]
then

  Check_Space $UNIXDIR $HSPlot_Size "Shaded Plotting"

  echo
  echo Installing Shaded Plotting in $UNIXDIR
  echo Installing Shaded Plotting in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile hsplot.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi

  if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
  then
    getfile hsplot.install > /usr/tmp/hsplot.install
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi

    getfile hsplot.assign > /usr/tmp/hsplot.assign
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi

    getfile hsplot.mls> /usr/tmp/hsplot.mls
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi

    chmod ugo+x /usr/tmp/hsplot.install /usr/tmp/hsplot.assign /usr/tmp/hsplot.mls
    /usr/tmp/hsplot.install $UNIXDIR/bin
    /usr/tmp/hsplot.assign $UNIXDIR/bin/HSplot
    rm /usr/tmp/hsplot.install /usr/tmp/hsplot.assign /usr/tmp/hsplot.mls
  fi
fi

#
# Load the messages/src files
#
if [ "$MSGSRC" = "y" ]
then
  Check_Space $UNIXDIR $Msgsrc_Size "MODEL Message Source Files"

  echo
  echo Installing MODEL Message Source Files in $UNIXDIR
  echo Installing MODEL Message Source Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile modelmsg.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

if [ -f /usr/tmp/BOM ]
then
  rm /usr/tmp/BOM
fi

find $UNIXDIR -print | xargs chown sys
find $UNIXDIR -print | xargs chgrp bin
find $UNIXDIR -print | xargs chmod ugo+r-wx
find $UNIXDIR -type d -print | xargs chmod ugo+x
find $UNIXDIR/bin -print | xargs chmod ugo+x

exit 0
