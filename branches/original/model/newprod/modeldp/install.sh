#
# Copyright Intergraph Corporation	14-DEC-1986
#
# MODEL DP Product Installation
#
# DLB 07/02/90 removed weld option
# DLB 06/28/90 add support for more .p files
# SCW 09/30/93 add support for INGRHOME
# SCW 10/22/03 added dso file for SGI
# SCW 10/28/03 removed modelhelp.{SUFF}
# SCW 12/29/93 removed config/lock directory generation code
# SCW 01/03/94 removed the setting of the setuid/setgid bit
# SCW 01/05/94 added extra prompting for invalid responses
# SCW 01/05/94 removed references to SunOS 4.X
# SCW 02/24/94 changed Check_Space() to use Free for Solaris
# SCW 03/08/94 changed protections once loaded
# SCW 03/09/94 changed chmod to use ugo
# SCW 08/19/94 added isl processor type
# SCW 03/07/95 added XGL prompting
# SCW 07/12/95 added advanced math lib installation
# SCW 07/14/95 changed Check_Space() to use Free for all platforms
# SCW 07/19/95 changed XGL prompting for 2.4 or higher OS
# SCW 06/04/96 Added advanced ppl for XGL
# SCW 12/31/96 Added EMS ultra-lite entry in product_data
# SCW 01/15/97 Removed EMS Ultra-lite product_data entry
# SCW 12/12/97 Corrected OS checking on Solaris
# SCW 12/19/97 Modified hsplot installation of third party platforms
# SCW 01/21/98 Changed HSPLOT prompt default to "y"
#
PROMPTXGL="n"
DEFDIR=$4

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  export INGRHOME=${INGRHOME:-/opt/ingr}
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
  SUFF=sgi
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
} #end Check_Space function

if [ -d $DEFDIR ]; then LOGFILE=$DEFDIR/log; else LOGFILE=/dev/null; fi>$LOGFILE

UNIXDIR=`getanswer "Enter directory for MODELDP" "$DEFDIR"`

if [ -z ${UNIXDIR} ]
then
  echo "MUST ENTER A DIRECTORY FOR MODELDP"
  exit
fi

while true
do
  baseanswer=`getanswer "Install base MODEL Development Platform (y/n) ?" "y"`
  case "$baseanswer" in
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

if [ "${SUFF}" = "p" ]
then
  tarcpu=`getanswer "Install Libraries for C100, C400, or BOTH ?" "C100"` 
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
  echo "\nDownloading $tarcpu libraries . . . \n"
fi

if [ "${SUFF}" = "BOTH" ]
then
# Load C100/C400 with runtime files of the machine cpu type - no prompting
  tarcpu=`inqcpuid`
  if [ "$tarcpu" = "C100" ]
  then
     SUFF="p"
     OTHERSUFF="p4"
   else
     SUFF="p4"
     OTHERSUFF="p"
  fi
# Use tarcpu to flag when loading grlib and grarchlib for C100 and C400
  tarcpu=BOTH
fi

while true
do
  execanswer=`getanswer "Install MODEL  executable (y/n) ?" "n"`
  case "$execanswer" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  mathlb=`getanswer "Install the Advanced PPL Math Libraries locally (y/n)?" "n"`
  case "$mathlb" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  nmanswer=`getanswer "Install Modeling libraries for FEM (y/n) ?" "n"`
  case "$nmanswer" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  hsplotanswer=`getanswer "Install Shaded Plotting (y/n) ?" "y"`
  case "$hsplotanswer" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  cnvanswer=`getanswer "Install DEM Version Converter Components (y/n) ?" "n"`
  case "$cnvanswer" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  MSGSRC=`getanswer "Install the MODEL Message Source Files (y/n) ?" "n"`
  case "$MSGSRC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  chgown=`getanswer "Change file ownership to your uid at installation (y/n) ?" "y"`
  case "$chgown" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "$PREPROCESS" = "y" ]
then
  exit 0
fi

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

#
# fix the product data file
#
echo > $pdtmp
if [ -f $pd ]; then sed '/\"Model\"/d' $pd > $pdtmp; fi
echo "\"Model\" I/MODEL GRmodule Model:Dignuc:Grnuc $UNIXDIR" >> $pdtmp
mv $pdtmp $pd

#
# Load XGL/ZX display if positive response to XGL prompt
#
if [ "$xgl" = "y" ]
then
  SUFF="zx"
fi


if [ "${baseanswer}" = "y" ]
then
  echo "Installing MODEL Development Platform in $UNIXDIR"
  echo "Installing MODEL Development Platform in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  echo Installing MODEL basic files
  getfile modeldp.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile modeldp.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  if [ "${tarcpu}" = "BOTH" ]
  then
    getfile modeldp.${OTHERSUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  fi

  echo Installing MODEL config files
  getfile modelconf.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile modelconf.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1


  echo Installing MODEL dloaded files
  getfile modversno.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1


  #
  # install DSO's and Makefiles in $MODEL/src_shlib for SGI & Solaris
  #

  if [ "${SUFF}" = "sgi" -o "${SUFF}" = "ssl" -o "${SUFF}" = "zx" -o "${SUFF}" = "isl" ]
  then
    getfile mdshlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
    if [ ${AOK} != 0 ] ; then exit $AOK; fi
    if [ "${SUFF}" = "sgi" ]
    then
      ln -s ${UNIXDIR}/src_shlib/*.so ${INGRHOME}/lib/
    fi
  fi

  if [ "${SUFF}" = "ssl" -o "${SUFF}" = "zx" -o "${SUFF}" = "sgi" ]
   then
    getfile transos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
  fi

  echo Installing MODEL include files
  getfile modelbinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile modelinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1

fi

rm -f /usr/bin/startup.model
ln -s $UNIXDIR/bin/startup.model /usr/bin

if [ "${execanswer}" = "y" ]
then

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

  echo
  date >>$LOGFILE 2>&1
  getfile modelexec.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
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
# Load the FEM Modeling libraries
#
if [ "$nmanswer" = "y" ]
then
  echo 
  echo Installing Modeling libraries for FEM in $UNIXDIR
  echo Installing Modeling libraries for FEM in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile modelnm.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
  getfile modelnm.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "${tarcpu}" = "BOTH" ]
  then
    getfile modelnm.${OTHERSUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ]; then exit $AOK; fi
  fi
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

if [ "${cnvanswer}" = "y" ]
then
    echo "Installing MODEL Version Converter Components in $UNIXDIR"
    echo "Installing MODEL Version Converter Components in $UNIXDIR" >$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile cvrt.p | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$? 

    #
    # fix the product data file
    #
    echo > $pdtmp
    if [ -f $pd ]
    then
        sed '/\"Cvrt\"/d' $pd > $pdtmp
    fi
    echo "\"Cvrt\" I/CVRT module Cvrt:exnuc $UNIXDIR" >> $pdtmp
    mv $pdtmp $pd

    cd $UNIXDIR
fi

#
# Load the messages/src files
#
if [ "$MSGSRC" = "y" ]
then
  echo 
  echo Installing MODEL Message Source Files in $UNIXDIR
  echo Installing MODEL Message Source Files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile modelmsg.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

#
# Load Render Texturing
#
if [ "$rendanswer" = "y" ]
then
  Check_Space $UNIXDIR $Render_Size "Rendering"

  echo
  echo Installing Rendering Texture files in $UNIXDIR
  echo Installing Rendering Texture files in $UNIXDIR >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile render.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ]; then exit $AOK; fi
fi

date >>$LOGFILE 2>&1

if [ -f $UNIXDIR/hsurf/lib/skystub.o ]
then 
  ln $UNIXDIR/hsurf/lib/skystub.o $UNIXDIR
fi

if [ "$chgown" = "y" ]
then
  find $UNIXDIR -print | xargs chown $LOGNAME
  find $UNIXDIR -print | xargs chmod ugo+rw
  find $UNIXDIR -type d -print | xargs chmod ugo+x
  find $UNIXDIR/bin -print | xargs chmod ugo+x
fi

exit $retstatus
