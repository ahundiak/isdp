#
# Copyright Intergraph Corporation    14-DEC-1986
#
# EMSNUC Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <DEFDIR> <-y>
#
# History
#
#       08-AUG-1991    BOM prototype
#  scw  15-SEP-1993    SOLARIS support
#  scw  30-SEP-1993    INGRHOME support
#  scw  20-OCT-1993    Modified help installation
#  scw  04-NOV-1993    Changed copy of echopath to go to INGRHOME
#  scw  29-DEC-1993    Modified inqlgexist for clipper only
#  scw  04-JAN-1994    Added extra prompting for invalid responses
#  scw  10-JAN-1994    Changed location of man pages
#  scw  12-JAN-1994    Added Raster Viewing to review list for all boxes
#  scw  13-JAN-1994    Added Machine coding numbers in SN's
#  scw  18-JAN-1994    Backed out man pages location change
#  scw  22-JAN-1994    Changed location of echopath on Clipper machines
#  scw  24-JAN-1994    Corrected man page location due to 7.5 DELTOOLS
#  scw  16-FEB-1994    Added new helpinfo.com code
#  scw  24-FEB-1994    Changed Check_Space() to use Free for Solaris
#  scw  08-MAR-1994    Changed protection once loaded
#  scw  08-MAR-1994    Added TRems.com readme package
#  scw  09-MAR-1994    Changed chmod to use ugo
#  scw  19-AUG-1994    Added isl processor type
#  sam  23-SEP-1994    Removed man pages install. on foreign boxes TR119422725
#  scw  30-SEP-1994    Added prompting for NT plot font resource libraries
#  kbr  03-OCT-1994    Changed to not prompt for raster component on isl -
#		       CR# 119422937
#  scw  03-OCT-1994    Added low resolution menus for isl platform
#  scw  05-OCT-1994    Cleaned up raster prompting for Pload
#  scw  10-OCT-1994    Changed prod_data entry for menus
#  scw  18-OCT-1994    Corrected prod_data entry for low res
#  scw  07-MAR-1995    Added XGL prompting for Sparc boxes
#  scw  06-JUL-1995    Changed obj_ot to deliver in model
#  scw  13-JUL-1995    Changed Check_Space() to use Free for all platforms
#  scw  19-JUL-1995    Changed XGL prompt for 2.4 or higher OS
#  scw  22-SEP-1995    Added automated ZX fb checking
#  scw  06-NOV-1995    Changed automated ZX fb checking
#  scw  29-NOV-1995    Removed all references to loading man pages (all boxes)
#  scw  14-DEC-1995    Added loading of Ems-Lite menus and prod_data entry
#  scw  11-NOV-1996    Changed the auto sensor of Sparc graphics cards
#  scw  04-DEC-1996    Modified Solaris OS validation
#  scw  15-JAN-1997    Added EMS Ultra-lite entry to the product_data file
#  scw  20-FEB-1997    Added EMS Ultra-lite help info
#  scw  03-DEC-1997    Modified SNUC dependency check to CLIPPER only
#

PROMPTXGL="n"
DEFDIR=$4

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  BOX="0S"
  export INGRHOME=${INGRHOME:-/opt/ingr}
  OS=`uname -r | cut -d'-' -f1 | cut -d'.' -f1,2`
  if [ "${OS}" -lt "5.4" ]
  then
    echo "***** WARNING ******* "
    echo "    You must have SunOS 5.1 or greater in order to run I/Ems"
  fi
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="ssl"
  BOX="05"
  export INGRHOME=${INGRHOME:-/opt/ingr}
  OS=`uname -r | cut -d'-' -f1 | cut -d'.' -f1,2`
  if [ "${OS}" -lt "5.4" ]
  then
    echo "***** WARNING ******* "
    echo "    You must have SunOS 5.2 or greater in order to run I/Ems"
  fi

  if [ "${OS}" -ge "5.4" ]  # Solaris 2.4 or higher
  then
    PROMPTXGL="y"
  fi
fi

if [ "$0" = "install.sgi" ]
then
  SUFF="sgi"
  BOX="0H"
  export INGRHOME=${INGRHOME:-/var/opt/ingr}
fi

if [ "$0" = "install.sh" ]
then
  SUFF="p"
  BOX="01"
  export INGRHOME=${INGRHOME:-/usr/ip32}
  if [ "$INGRHOME" = "/dev/null" ]
  then
    INGRHOME="/usr/ip32"
  fi
fi

INGRHOME="$(echo $INGRHOME | cut -f1 -d:)"

if [ "$SUFF" = "p" ]
then
  ProDir="`basename $DEFDIR`"
  Df3="`echo $DEFDIR | cut -d'/' -f3`"
  if [ "$Df3" = "$ProDir" ]
  then
    Df2="`echo $DEFDIR | cut -d'/' -f2`"
    DEFDIR="/${Df2}/ip32/${Df3}"
  fi
fi

UNIXDIR=$DEFDIR

if [ "$PREPROCESS" = "n" ]
then

  if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
  then
    if inqlgexist
    then  
      cat << EO > /usr/tmp/ems.ftc
#include <ftdefs.h>
APPEND_COMMANDS TAIL DEM_EMS
COMMAND  CdEx(/bin/ksh -c #c/.lgshell; lg_pause)
COMMAND_DESCRIPTION "Run EMSNUC product"
END
REDEFINE TYPE DEM_EMS_OS
COMMAND:COPY "`echopath GRNUC`/bin/cpOS"
COMMAND "/bin/ksh -c '${UNIXDIR}/bin/.lgshell -f #c/#f' ; lg_pause"
COMMAND_DESCRIPTION "Run EMSNUC product"
END
APPEND_COMMANDS TAIL DEM_EMS_OS
COMMAND "/bin/ksh -c '\`echopath GRNUC\`/bin/.lgsetoptions MDEM_PRODUCTS #c/#f SELECT.DEM....' ; lg_pause"
COMMAND_DESCRIPTION "Run MDEM Product"
END
EO
      lgappcmds /usr/tmp/ems.ftc
      cp /usr/tmp/ems.ftc ${UNIXDIR}
    fi
  fi

  rm -f /usr/tmp/BOM
  export DEFAULTS="n"
  exit 0
fi

getmsg ()  {
grep $1 prompts.eng | cut -d' ' -f2- | tr -d "\""
}

touch /usr/tmp/BOM
BOM=y

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

if [ "${SUFF}" = "isl" ]
then
   getfile components.isl > components
fi

if [ "${SUFF}" = "ssl" ]
then
   getfile components.ssl > components
fi

if [ "${SUFF}" = "sgi" ]
then
    getfile components.sgi > components
fi

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
    getfile components > components
fi

LOGFILE=${UNIXDIR}/log

#>$LOGFILE

getfile embom.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
AOK=$?
if [ "$AOK" != "0" ] ; then exit $AOK; fi

chmod ugo+x echopath

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  cp echopath /usr/bin/echopath
else
  cp echopath ${INGRHOME}/bin/echopath
fi
cp prompts.eng /usr/tmp


Ems_Size=1450
EHelp_Size=10075
Pmenu_Size=3700
Train_Size=7800

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

#
# EMS menus
#
echo > $pdtmp
if [ -f $pd ]; then sed "/\"Emsui02/d" $pd > $pdtmp; fi
echo "\"Emsui02\" EMS-UI02 GRmodule Emsui02 ${UNIXDIR}/emsui02" >> $pdtmp
if [ "$SUFF" = "isl" ]
then
  echo "\"Emsui02l\" EMS-UI02L GRmodule Emsui02l ${UNIXDIR}/emsui02l" >> $pdtmp
fi
mv $pdtmp $pd

#
# Damn EMS-Lite menus
#
echo > $pdtmp
if [ -f $pd ]; then sed "/\"Emsuilt/d" $pd > $pdtmp; fi
echo "\"Emsuilt\" EMS-UILT GRmodule Emsuilt ${UNIXDIR}/emsuilt" >> $pdtmp
if [ "$SUFF" = "isl" ]
then
  echo "\"Emsuiltl\" EMS-UILTL GRmodule Emsuiltl ${UNIXDIR}/emsuiltl" >> $pdtmp
fi
mv $pdtmp $pd

#
# EMS Ultra-Lite menus
#
echo > $pdtmp
if [ -f $pd ]; then sed "/\"Emsuiu/d" $pd > $pdtmp; fi
echo "\"Emsuiu\" EMS-UIU GRmodule Emsuiu ${UNIXDIR}/emsuiu" >> $pdtmp
if [ "$SUFF" = "isl" ]
then
  echo "\"Emsuiul\" EMS-UIUL GRmodule Emsuiul ${UNIXDIR}/emsuiul" >> $pdtmp
fi
mv $pdtmp $pd

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
#EMSVERS=`echo $PRODVERSION | cut -d'.' -f1-3 | sed "s/^0//g" | sed "s/\.0/\./g"`
EMSVERS=`echo $PRODVERSION | cut -d'.' -f1-3`
echo "Installing: EMSNUC"
echo
echo "Engineering Modeling System Nucleus Version $EMSVERS"
echo
echo "Use newprod's -b /usrX option to load to a device other than /usr"
echo
echo "CAUTION:"
echo "Any previous version of EMSNUC should be removed from the workstation, before"
echo "loading EMSNUC $EMSVERS. Please read your Delivery Letter. To remove EMSNUC use"
echo "deltools/remove."
echo
echo "This product will also install : BSPMATH (SN${BOX}089), EXNUC (SN${BOX}094),"
if [ "${SUFF}" = "ssl" -o "${SUFF}" = "sgi" -o "${SUFF}" = "isl" ]
then
  echo "GRNUC (SN${BOX}088), and MODEL (SN${BOX}090)"
else
  echo "DIGNUC (SN${BOX}127), GRNUC (SN${BOX}088), and MODEL (SN${BOX}090)"
fi
echo
echo
if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  echo "Local plotting files are now loaded with the base platform."
  echo "See README file for more information."
fi
echo 

EMBASE=`getmsg EMBASE`
if [ "${PROMPTXGL}" = "y" ]
then
  EMXGL=`getmsg EMXGL`
fi
EMMEAS=`getmsg EMMEAS`
EMOPTS=`getmsg EMOPTS`
EMHELP=`getmsg EMHELP`
if [ "${SUFF}" = "ssl" -o "${SUFF}" = "sgi" -o "${SUFF}" = "isl" ]
then
  EMHEL2=`getmsg EMHEL2`
fi
EMPPLCOMP=`getmsg EMPPLCOMP`
EMPPLEX=`getmsg EMPPLEX`
EMADVPPL=`getmsg EMADVPPL`
EMMTHPPL=`getmsg EMMTHPPL`
EMLOCPLOT=`getmsg EMLOCPLOT`
#EMPLOT=`getmsg EMPLOT`
EMFONT=`getmsg EMFONT`
EMNTPLOT=`getmsg EMNTPLOT`
EMIGDSCL=`getmsg EMIGDSCL`
EMSHDPLOT=`getmsg EMSHDPLOT`
if [ "$SUFF" != "isl" ]
then
  EMRASTER=`getmsg EMRASTER`
fi
EMMSGSRC=`getmsg EMMSGSRC`
#EMASAPII=`getmsg EMASAPII`
EMGDEUTI=`getmsg EMGDEUTI`
EMPMENU=`getmsg EMPMENU`
EMCVRT=`getmsg EMCVRT`
EMEXTOOL=`getmsg EMEXTOOL`
EMDIGNUC=`getmsg EMDIGNUC`
EMTRAIN=`getmsg EMTRAIN`

echo "$EMBASE"
echo "$EMMEAS"
echo "$EMOPTS"
echo "$EMHELP"
if [ "${SUFF}" = "ssl" -o "${SUFF}" = "sgi" -o "${SUFF}" = "isl" ]
then
  echo "$EMHEL2"
fi
echo "$EMPPLCOMP"
echo "$EMPPLEX"
echo "$EMADVPPL"
echo "$EMMTHPPL"
echo "$EMLOCPLOT"
#echo "$EMPLOT"
echo "$EMFONT"
echo "$EMNTPLOT"
echo "$EMIGDSCL"
echo "$EMSHDPLOT"

if [ "$SUFF" != "isl" ]
then
  echo "$EMRASTER"
fi

echo "$EMMSGSRC"
if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ] 
then
  echo "$EMGDEUTI"
  echo "$EMPMENU"
  echo "$EMCVRT"
fi
echo "$EMEXTOOL"
if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  echo "$EMDIGNUC"
fi
echo "$EMTRAIN"
echo 

SVPRODNAME=$PRODNAME
PRODNAME=MDEMBOM
if [ "$DEFAULTS" != "y" ]
then
  echo "$B1"
fi
answer=h
while [ "$answer" = "h" ]
do
  answer=`getanswer "$EMBASE   (y/n/h)? " "y"`
  if [ "$answer" = "h" ]
  then
    echo
    echo "`getmsg HLBASE`"
    echo
  fi
  case "$answer" in
    y|n|e|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              answer="h";;
  esac
done

if [ "${PROMPTXGL}" = "y" ]
then
  fb_type=`./FBsensor`
  if [ "$fb_type" = "XGL" ]
  then
    xgl="y"
  else
    xgl="n"
  fi

  if [ -z "$(grep "$EMXGL" $INGRHOME/.defaults)" ]
  then
    echo "MDEMBOM#$EMXGL   (y/n/h)? #$xgl" >> $INGRHOME/.defaults
  else
    if [ "$(grep "$EMXGL" $INGRHOME/.defaults | cut -d"#" -f3 )" != "$xgl" ]
    then
      grep -v "$EMXGL" $INGRHOME/.defaults > /tmp/.defaults
      mv /tmp/.defaults $INGRHOME/.defaults
      echo "MDEMBOM#$EMXGL   (y/n/h)? #$xgl" >> $INGRHOME/.defaults
    fi
  fi
  rm ./FBsensor
fi

meas=h
while [ "$meas" = "h" ]
do
  meas=`getanswer "$EMMEAS   (e/m/h)? " "e"`
  if [ "$meas" = "h" ]
  then
    echo
    echo "`getmsg HLMEAS`"
    echo
  fi
  case "$meas" in
    e|m|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            meas="h";;
  esac
done

if [ "$DEFAULTS" != "y" ]
then 
  echo "$EMOPTS"
fi

help=h
while [ "$help" = "h" ]
do
  help=`getanswer "$EMHELP   (y/n/h)? " "y"`
  if [ "$help" = "h" ]
  then
    echo
    echo "`getmsg HLHELP`"
    echo
  fi
  case "$help" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            help="h";;
  esac
done


if [ "$DEFAULTS" != "y" ]
then 
  echo "$EMPPLCOMP"
fi

ppl_ex="h"
while [ "$ppl_ex" = "h" ]
do
  ppl_ex=`getanswer "$EMPPLEX   (y/n/h)? " "y"`
  if [ "$ppl_ex" = "h" ]
  then
    echo
    echo "`getmsg HLPPLEX1`"
    echo "`getmsg HLPPLEX2`"
    echo
  fi
  case "$ppl_ex" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            ppl_ex="h";;
  esac
done

basinc="h"
while [ "$basinc" = "h" ]
do
  basinc=`getanswer "$EMADVPPL   (y/n/h)? " "y"`
  if [ "$basinc" = "h" ]
  then
    echo
    echo "`getmsg HLADVPPL1`"
    echo "`getmsg HLADVPPL2`"
    echo
  fi
  case "$basinc" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            basinc="h";;
  esac
done

mathlb="h"
while [ "$mathlb" = "h" ]
do
  mathlb=`getanswer "$EMMTHPPL   (y/n/h)? " "n"`
  if [ "$mathlb" = "h" ]
  then
    echo
    echo "`getmsg HLMTHLB`"
    echo
  fi
  case "$mathlb" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            mathlb="h";;
  esac
done
 
if [ "$DEFAULTS" != "y" ]
then
  echo "$EMLOCPLOT"
fi

#grplot="h"
#while [ "$grplot" = "h" ]
#do
#  grplot=`getanswer "$EMPLOT   (y/n/h)? " "y"`
#  if [ "$grplot" = "h" ]
#  then
#    echo
#    echo "`getmsg HLPLOT`"
#    echo
#  fi
#  case "$grplot" in
#    y|n|h ) ;;
#         *) echo "\nInvalid. Try again\n" ;
#            grplot="h";;
#  esac
#done
grplot="n"

igdscl="h"
while [ "$igdscl" = "h" ]
do
  igdscl=`getanswer "$EMIGDSCL   (y/n/h)? " "y"`
  if [ "$igdscl" = "h" ]
  then
    echo
    echo "`getmsg HLIGDSCL`"
    echo
  fi
  case "$igdscl" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            igdscl="h";;
  esac
done

fontlb="h"
while [ "$fontlb" = "h" ]
do
  fontlb=`getanswer "$EMFONT   (y/n/h)? " "y"`
  if [ "$fontlb" = "h" ]
  then
    echo
    echo "`getmsg HLFONT`"
    echo
  fi
  case "$fontlb" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            fontlb="h";;
  esac
done

ntplotlb="h"
while [ "$ntplotlb" = "h" ]
do
  ntplotlb=`getanswer "$EMNTPLOT   (y/n/h)? " "n"`
  if [ "$ntplotlb" = "h" ]
  then
    echo
    echo "`getmsg HLNTPLOT`"
    echo
  fi
  case "$ntplotlb" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            ntplotlb="h";;
  esac
done

hsplot="h"
while [ "$hsplot" = "h" ]
do
  hsplot=`getanswer "$EMSHDPLOT   (y/n/h)? " "y"`
  if [ "$hsplot" = "h" ]
  then
    echo
    echo "`getmsg HLSHDPLOT`"
    echo
  fi
  case "$hsplot" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            hsplot="h";;
  esac

  if [ "$hsplot" = "y" ] && [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
  then
    if [ ! -d /usr/ip32/ip/snuc ]
    then
      echo ""
      echo "************************** WARNING *********************************"
      echo "   You must download IP_SNUC (SP01127) before shaded plotting will "
      echo "   install correctly.  Changing shaded plotting response to n"
      echo "************************** WARNING *********************************"
      hsplot="n"
    fi
  fi
done

if [ "$SUFF" = "isl" ]
then
  raster="n"
else
  raster="h"
  while [ "$raster" = "h" ]
  do
    raster=`getanswer "$EMRASTER   (y/n/h)? " "y"`
    if [ "$raster" = "h" ]
    then
      echo
      echo "`getmsg HLRASTER`"
      echo
    fi
    case "$raster" in
      y|n|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              raster="h";;
    esac
  done
fi

msgsrc="h"
while [ "$msgsrc" = "h" ]
do
  msgsrc=`getanswer "$EMMSGSRC   (y/n/h)? " "y"`
  if [ "$msgsrc" = "h" ]
  then
    echo
    echo "`getmsg HLMSGSRC`"
    echo
  fi
  case "$msgsrc" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            msgsrc="h";;
  esac
done
  

asapii="n"

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  gdeuti="h"
  while [ "$gdeuti" = "h" ]
  do
    gdeuti=`getanswer "$EMGDEUTI   (y/n/h)? " "y"`
    if [ "$gdeuti" = "h" ]
    then
      echo
      echo "`getmsg HLGDEUTI1`"
      echo "`getmsg HLGDEUTI2`"
      echo
    fi
    case "$gdeuti" in
      y|n|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              gdeuti="h";;
    esac
  done
else
  gdeuti="n"
fi
  

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  p_menu="h"
  while [ "$p_menu" = "h" ]
  do
    p_menu=`getanswer "$EMPMENU   (y/n/h)? " "y"`
    if [ "$p_menu" = "h" ]
    then
      echo
      echo "`getmsg HLPMENU`"
      echo
    fi
    case "$p_menu" in
      y|n|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              p_menu="h";;
    esac
  done
else
  p_menu="n"
fi

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  cvrt="h"
  while [ "$cvrt" = "h" ]
  do
    cvrt=`getanswer "$EMCVRT   (y/n/h)? " "y"`
    if [ "$cvrt" = "h" ]
    then
      echo
      echo "`getmsg HLCVRT`"
      echo
    fi
    case "$cvrt" in
      y|n|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              cvrt="h";;
    esac
  done
else
  cvrt="n"
fi

extool="h"
while [ "$extool" = "h" ]
do
  extool=`getanswer "$EMEXTOOL   (y/n/h)? " "y"`
  if [ "$extool" = "h" ]
  then
    echo
    echo "`getmsg HLEXTOOLS`"
    echo
  fi
  case "$extool" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            extool="h";;
  esac
done

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  dignuc="h"
  while [ "$dignuc" = "h" ]
  do
    dignuc=`getanswer "$EMDIGNUC   (y/n/h)? " "y"`
    if [ "$dignuc" = "h" ]
    then
      echo
      echo "`getmsg HLDIGNUC`"
      echo
    fi
    case "$dignuc" in
      y|n|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              dignuc="h";;
    esac
  done
else
  dignuc="n"
fi

train="h"
while [ "$train" = "h" ]
do
  train=`getanswer "$EMTRAIN   (y/n/h)? " "y"`
  if [ "$train" = "h" ]
  then
    echo
    echo "`getmsg HLTRAIN1`"
    echo "`getmsg HLTRAIN2`"
    echo
  fi
  case "$train" in
    y|n|h ) ;;
         *) echo "\nInvalid. Try again\n" ;
            train="h";;
  esac
done

if [ "$dignuc" = "y" ]
then
  echo SN01127 >> components
fi
echo "Installing..."

cd ${UNIXDIR}

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ] 
then
  tarcpu=`inqcpuid`
else
  tarcpu=""
fi
  
#
# Load EMSNUC
#
if [ "$answer" = "y" ] || [ "$answer" = "e" ]
then

  Check_Space ${UNIXDIR} $Ems_Size "EMSNUC"

  echo
  echo Installing EMSNUC base platform in ${UNIXDIR}
  echo Installing EMSNUC base platform in ${UNIXDIR} >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ems.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile emsui02.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  getfile emsui02.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  #
  # install low resolution menus
  #
  if [ "$SUFF" = "isl" ]
  then
    getfile emsui02l.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  getfile TRems.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
  
  getfile helpinfo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  #
  # Help for Ultra-Lite
  #
  ln $UNIXDIR/emsui02/config/english/HELPINFO $UNIXDIR/emsuiu/config/english/
  
  chmod ugo+x $UNIXDIR/bin/ems

fi



#
# Load the help files
#
if [ "$help" = "y" ] 
then
  valid=`dates helprt` 
  if [ "${valid}" = "" ]
  then
    echo "You need to download helprt before downloading EMSNUC help"
    help=n
  fi
  
  if [ "${help}" = "y" ]
  then
    Check_Space ${UNIXDIR} $EHelp_Size "EMSNUC Help Files"

    echo
    echo Installing EMSNUC Help Files in ${UNIXDIR}
    echo Installing EMSNUC Help Files in ${UNIXDIR} >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1

    getfile emshelp.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  
    installhdoc.sh ${UNIXDIR}/emsui02/config/english/HELPFILE

  fi
fi


#
# Load the paper menus
#
if [ "$p_menu" = "y" ]
then

  Check_Space $UNIXDIR $Pmenu_Size "EMSNUC Paper Menu Design Files"

  echo
  echo Installing EMSNUC Paper Menu Design Files in $UNIXDIR
  echo Installing EMSNUC Paper Menu Design Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile pmenu.p | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# Load the training files
#
if [ "$train" = "y" ]
then

  Check_Space $UNIXDIR $Train_Size "EMSNUC Training Files"

  echo
  echo Installing EMSNUC Training Files in $UNIXDIR
  echo Installing EMSNUC Training Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile training.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi

fi

find $UNIXDIR -print | xargs chown sys
find $UNIXDIR -print | xargs chgrp bin
find $UNIXDIR -print | xargs chmod ugo+r-wx
find $UNIXDIR -type d -print | xargs chmod ugo+x
find $UNIXDIR/bin -print | xargs chmod ugo+x

if [ "$answer" != "e" ]
then
  exit 255
fi

