#
# Copyright Intergraph Corporation	14-DEC-1986
#
# I/EMS PACKAGE Product Installation
#
#  scw  13-jan-1994  added machine code in product numbers
#  scw  24-feb-1994  changed Check_Space() to use Free for Solaris
#  scw  08-mar-1994  changed protections once loaded
#  scw  09-mar-1994  changed chmod to use ugo
#  scw  26-aug-1994  added isl processor type
#  scw  03-oct-1994  added low resolution menu interface for isl
#  scw  18-oct-1994  changed low res to insert both interface (pick up icons)
#  scw  02-feb-1995  added mds support
#  scw  02-feb-1995  added mds execute priv
#  scw  13-jul-1995  changed Check_Space() to use Free for all platforms
#  scw  31-jul-1995  allowed execute priv on ems drive products
#  scw  14-nov-1995  created link Mds to Model, if in mds product
#  scw  28-nov-1995  added auto-removal of products
#  scw  13-dec-1995  added installation of EMS Lite menus
#  scw  14-dec-1995  changed the product_data line for EMS Lite
#  scw  15-dec-1995  added no remove hidden option
#  scw  15-jan-1997  added ultra lite component to product_data
#  scw  22-jan-1997  changed SunOS version requirement to >= 5.4
#

DEFDIR=$4

IDTITLE=`grep IDtitle product.def | cut -d'=' -f2 | tr -d '"'`
PRODNM=`echo $PRODNAME | cut -d'_' -f2`
PRODFLE=`echo $PRODNM | tr "[A-Z]" "[a-z]"`
UI02PRODNM=SM01UI2

if [ "$PRODNM" = "EMS-LT" ]
then
  UI=Emsuilt:Emsui02
else
  UI=Emsui02
fi

#
# User Interface for Ultra-Lite
#
UIU=Emsuiu

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  BOX="0S"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="ssl"
  BOX="05"
  export INGRHOME=${INGRHOME:-/opt/ingr}
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

#
# Check to see if product is currently installed
#
if [ "$PREPROCESS" = "y" ]
then
  RmProd=""
  if [ -n "$(proddata $PRODNAME)" ]
  then
    RmProd=$PRODNAME
  elif [ -n "$(proddata EMSNUC)" ]
  then
    RmProd=EMSNUC
  fi
  
  if [ -n "$RmProd" ]
  then
    removeprod="h"
    while [ "$removeprod" = "h" ]
    do
      echo
      echo "$RmProd is currently installed on this machine.  Preparing to"
      echo "remove existing product before continuing.  To preserve existing"
      echo "installation, exit now by entering \"n\". Enter \"y\" to continue."
      removeprod=`getanswer "Remove $RmProd                (y/n/h)? " "y"`
      if [ "$removeprod" = "h" ]
      then
        echo
        echo "Remove existing $RmProd product before installing $PRODNAME."
        echo
      fi
      case "$removeprod" in
        y|n|h|e ) ;;
             *) echo "\nInvalid. Try again\n" ;
                removeprod="h";;
      esac
    done
  
    case "$removeprod" in
      "n" )
            exit 1
            ;;
      "y" )
            echo
            if [ "$SUFF" = "p" -o "$SUFF" = "p4" ]
            then
              $INGRHOME/deltools/remove -y $RmProd
            else
              $INGRHOME/bin/remove -y $RmProd
            fi    # if $SUFF
            echo
            ;;
      "e" )
            ;;
    esac    # case $removeprod
  fi        # if -n $RmProd
fi          # if $PREPROCESS


#
#  Add the ip32 (if missing) on clix boxes
#
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

UNIXDIR=$DEFDIR

#
#  Added symbolic of Mds for Higher Apps not Ploading since reconfig of mds
#
if [ "$PREPROCESS" = "n" ]
then
  if [ -f $UNIXDIR/bin/mds ]
  then
    Model_Location=`echopath MODEL ${INGRHOME}/product_data`
    ln -s $Model_Location/bin/Model $UNIXDIR/bin/Mds
  fi
  export DEFAULTS="n"
  exit 0
fi

if [ ${SUFF} = "ssl" ]
then
   OS=`uname -r | cut -c1-3`
   if [ "${OS}" -lt "5.4" ]
   then
     echo "***** WARNING ******* "
     echo "    You must have SunOS 5.4 or greater in order to run I/$PRODNM"
   fi
fi

#getmsg ()  {
#grep $1 $UNIXDIR/prompts.eng | cut -d' ' -f2- | tr -d "\""
#}

BOM=y

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

LOGFILE=${UNIXDIR}/log

PROD_Size=1450

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/Product_Data

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  Disk_Space=`Free -f $checkDIR`

  if [ "$Disk_Space" -lt "$checkSIZE" ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

#
# Get responses to prompts
#
EMSVERS=`echo $PRODVERSION | cut -d'.' -f1-3`
echo "Installing: $IDTITLE ($PRODNUMBER)"
echo
echo "Engineering Modeling System Version $EMSVERS"
echo
echo "Use newprod's -b /usrX option to load to a device other than /usr"
echo
echo "CAUTION:"
echo "Any previous version of $PRODNM should be removed from the workstation, before"
echo "loading $PRODNM $EMSVERS. Please read your Delivery Letter. To remove $PRODNM use"
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



baseprod="h"
while [ "$baseprod" = "h" ]
do
  baseprod=`getanswer "Install $PRODNM                (y/n/h)? " "y"`
  if [ "$baseprod" = "h" ]
  then
    echo
    echo "Install $PRODNM"
    echo
  fi
  case "$baseprod" in
    y|n|e|h ) ;;
           *) echo "\nInvalid. Try again\n" ;
              baseprod="h";;
  esac
done

if [ "$baseprod" = "n" ]
then
   exit
fi

menu="h"
if [ "$SUFF" = "isl" ]
then
  while [ "$menu" = "h" ]
  do
    menu=`getanswer "High resolution menu display   (y/n/h)? " "y"`
    if [ "$menu" = "h" ]
    then
      echo
      echo "High resolution display (1280x1025) / Lower resolution (1024x678)"
      echo
    fi
    case "$menu" in
      y|n|h ) ;;
             *) echo "\nInvalid. Try again\n" ;
                menu="h";;
    esac
  done
fi

if [ "$menu" = "n" ]
then
  if [ "$PRODNM" = "EMS-LT" ]
  then
    UI="Emsuiltl:Emsuilt:Emsui02l:Emsui02"
  else
    UI="Emsui02l:Emsui02"
  fi

  #
  # User Interface for Ultra-Lite
  #
  UIU="Emsuiul:Emsuiu"

fi

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

PRODNMNDSH=`echo $PRODNM | tr "[A-Z]" "[a-z]" | sed "s/mds/Mds/" | sed "s/ems/Ems/" | tr -d '-'` 
PRODTITLE=`echo $IDTITLE | tr " " "_"`
echo > $pdtmp
if [ -f $pd ] 
then 
  sed "/\"$PRODNMNDSH\"/d" $pd > $pdtmp
fi
echo "\"$PRODNMNDSH\" $PRODTITLE GRmodule ${PRODNMNDSH}:${UI}:RENDER:Model ${UNIXDIR}" >> $pdtmp
mv $pdtmp $pd


if [ "$PRODNM" != "MDS" ]
then
#
# add ultra-lite to product_data entry list
#
  echo > $pdtmp
  if [ -f $pd ]; then sed '/\"Emsultra\"/d' $pd > $pdtmp; fi
  echo "\"Emsultra\" I/ULTRALITE GRmodule Emsultra:${UIU}:Model:Noswitch $UNIXDIR/emsult" >> $pdtmp
  mv $pdtmp $pd
fi
  
#
# Load EMSPACKAGE
#
if [ "$baseprod" = "y" ] || [ "$baseprod" = "e" ]
then

  Check_Space ${UNIXDIR} $PROD_Size "$PRODNM"

  echo
  echo Installing $PRODNM base platform in ${UNIXDIR}
  echo Installing $PRODNM base platform in ${UNIXDIR} >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  cd $UNIXDIR
  getfile ${PRODFLE}.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
  getfile ${PRODFLE}.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

  if [ "$PRODNM" != "MDS" ]
  then
    #
    # Load EMS Ultra-Lite components
    #
    mkdir $UNIXDIR/emsult
    cd $UNIXDIR/emsult

    getfile ems-ul.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    getfile ems-ul.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    cd $UNIXDIR
  fi

fi

find $UNIXDIR -print | xargs chown sys
find $UNIXDIR -print | xargs chgrp bin
find $UNIXDIR -print | xargs chmod ugo+r-wx
find $UNIXDIR -type d -print | xargs chmod ugo+x

if [ -f $UNIXDIR/bin/mds ]
then
  chmod ugo+x $UNIXDIR/bin/mds 
fi

if [ -f $UNIXDIR/bin/ems* ]
then
  chmod ugo+x $UNIXDIR/bin/ems*
fi

if [ "$baseprod" != "e" ]
then
  exit 255
fi

