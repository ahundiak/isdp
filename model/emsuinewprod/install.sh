#
# Copyright Intergraph Corporation	14-DEC-1986
#
# I/EMS UI Product Installation
#
#  scw  01/05/94  removed all references to SunOS 4.X
#  scw  01/05/94  added proper machine checking
#  scw  02/24/94  changed Check_space() to use Free for Solaris
#  scw  03/08/94  changed protections once loaded
#  scw  03/09/94  changed chmod to use ugo
#  scw  07/13/95  changed Check_Space to use Free for all platforms
#

if [ "$PREPROCESS" = "n" ]
 then

PRODNM=`echo $PRODNAME | cut -d'_' -f2`
PRODFLE=`echo $PRODNM | tr "[A-Z]" "[a-z]"`

DEFDIR=$4

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

cd ${UNIXDIR}

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

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

EMSUIVERS=`echo $PRODVERSION | cut -d'.' -f1-3`
echo "Installing: I_$PRODNM ($PRODNUMBER)"
echo
echo "Use newprod's -b /usrX option to load to a device other than /usr"
echo
echo "CAUTION:"
echo "Any previous version of I/$PRODNM should be removed from the workstation, before"
echo "loading I/$PRODNM $EMSVERS. Please read your Delivery Letter. To remove I/$PRODNM use"
echo "deltools/remove."
echo

echo > $pdtmp
if [ -f $pd ]; then sed "/\"$PRODNM\"/d" $pd > $pdtmp; fi
echo "\"$PRODNM\" I/$PRODNM GRmodule ${PRODNM}:Model ${UNIXDIR}" >> $pdtmp
mv $pdtmp $pd

  
#
# Load I/EMS UI
#
  Check_Space ${UNIXDIR} $PROD_Size "I/$PRODNM"

  echo
  echo Installing I/$PRODNM UI platform in ${UNIXDIR}
  echo Installing I/$PRODNM UI platform in ${UNIXDIR} >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ${PRODFLE}.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi

fi

find $UNIXDIR -print | xargs chown sys
find $UNIXDIR -print | xargs chgrp bin
find $UNIXDIR -print | xargs chmod ugo+r-wx
find $UNIXDIR -type d -print | xargs chmod ugo+x


# fi

