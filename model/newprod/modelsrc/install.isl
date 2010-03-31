#
# Copyright Intergraph Corporation	14-DEC-1986
#
# MODEL SRC Product Installation
# scw 09/30/93  added INGRHOME support
# scw 10/28/93  removed modelhelp.{SUFF}
# scw 11/04/93  added change ownership code
# scw 12/29/93  removed config/lock directory generation code
# scw 01/03/94  removed the setting of the setuid/setgid bit
# scw 01/05/94  added extra prompting for invalid responses
# scw 01/05/94  removed all references to SunOS 4.X
# scw 02/24/94  changed Check_Space() to use Free for Solaris
# scw 03/08/94  changed protection once loaded
# scw 03/09/94  changed chmod to use ugo
# scw 08/19/94  added isl processor type
# sam 13/01/95  Changes made for Pathway source
# scw 03/07/95  added XGL prompting
# sam 16/05/95  Made changes for delivering miniems
# scw 07/12/95  added advanced math lib installation
# scw 07/13/95  changed Check_Space() to use Free for all platforms
# scw 07/19/95  changed XGL prompting for 2.4 or higher OS
# scw 04/17/96  corrected bad cpio switches
# scw 06/04/96  added advanced ppl math support to XGL platforms
# hari 11/01/96 deleted miniems entries, as it is being delivered seperately.
# hari 11/25/96 undid the above change to restore miniEMS back.
# scw 01/15/97  removed EMS Ultra-lite product_data entry
# scw 12/12/97  corrected OS checking on Solaris
# scw 12/19/97  modified hsplot installation of third party platforms
# scw 01/21/98  changed hsplot prompt default to "y"
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
} # end Check_Space function

if [ -d $DEFDIR ]; then LOGFILE=$DEFDIR/log; else LOGFILE=/dev/null; fi>$LOGFILE

UNIXDIR=`getanswer "Enter directory for MODELSRC" "$DEFDIR"`

if [ -z ${UNIXDIR} ]
then
  echo "MUST ENTER A DIRECTORY FOR MODELSRC"
  exit
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

while true
do
  baseanswer=`getanswer "Install base MODEL Source Platform (y/p/n) ?" "y"`
  case "$baseanswer" in
    y|n|p ) break;;
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
  CPUTYPE=c100
  tarcpu=`getanswer "Install Libraries for C100 or C400 ?" "C100"`
  tarcpu=`echo ${tarcpu} | tr "[a-z]" "[A-Z]"`
  if [ "$tarcpu" = "C400" ]
  then
    SUFF=p4
    CPUTYPE=c400
  fi
  echo "\nDownloading $tarcpu libraries . . . \n"
else
  tarcpu=""
fi


while true
do
  mathlb=`getanswer "Install the Advanced PPL Math Libraries locally (y/n)?" "n"`
  case "$mathlb" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

#
# Begin baseanswer = "p" prompts
#

if [ "$baseanswer" = "p" ]
then 

  while true
  do
    shlib=`getanswer "Install shlib (y/n) ? " "n"`
    case "$shlib" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    assem=`getanswer "Install assem (y/n) ? " "n"`
    case "$assem" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    assoc=`getanswer "Install assoc (y/n) ? " "n"`
    case "$assoc" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    bound=`getanswer "Install bound (y/n) ? " "n"`
    case "$bound" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    cnstr=`getanswer "Install cnstr (y/n) ? " "n"`
    case "$cnstr" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    co=`getanswer "Install co (y/n) ? " "n"`
    case "$co" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    co_mass=`getanswer "Install co_mass (y/n) ? " "n"`
    case "$co_mass" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    comp=`getanswer "Install comp (y/n) ? " "n"`
    case "$comp" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    compcv=`getanswer "Install compcv (y/n) ? " "n"`
    case "$compcv" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    compsf=`getanswer "Install compsf (y/n) ? " "n"`
    case "$compsf" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    curve=`getanswer "Install curve (y/n) ? " "n"`
    case "$curve" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    dpb=`getanswer "Install dpb (y/n) ? " "n"`
    case "$dpb" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    dpr=`getanswer "Install dpr (y/n) ? " "n"`
    case "$dpr" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    ff=`getanswer "Install freeform (y/n) ? " "n"`
    case "$ff" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    funk=`getanswer "Install funk (y/n) ? " "n"`
    case "$funk" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    gradat=`getanswer "Install gradat (y/n) ? " "n"`
    case "$gradat" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    listen=`getanswer "Install listen (y/n) ? " "n"`
    case "$listen" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    mass=`getanswer "Install mass (y/n) ? " "n"`
    case "$mass" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    param=`getanswer "Install param (y/n) ? " "n"`
    case "$param" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    place=`getanswer "Install place (y/n) ? " "n"`
    case "$place" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    serim=`getanswer "Install serim (y/n) ? " "n"`
    case "$serim" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    shell=`getanswer "Install shell (y/n) ? " "n"`
    case "$shell" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    sketch=`getanswer "Install sketch (y/n) ? " "n"`
    case "$sketch" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    solid=`getanswer "Install solid (y/n) ? " "n"`
    case "$solid" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    surf=`getanswer "Install surf (y/n) ? " "n"`
    case "$surf" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    testco=`getanswer "Install testco (y/n) ? " "n"`
    case "$testco" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    util=`getanswer "Install util (y/n) ? " "n"`
    case "$util" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    xsec=`getanswer "Install xsec (y/n) ? " "n"`
    case "$xsec" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    datum=`getanswer "Install datum (y/n) ? " "n"`
    case "$datum" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    tol=`getanswer "Install tol (y/n) ? " "n"`
    case "$tol" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    nm=`getanswer "Install nm (y/n) ? " "n"`
    case "$nm" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    drawvw=`getanswer "Install drawvw (y/n) ? " "n"`
    case "$drawvw" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    gralp=`getanswer "Install gralp (y/n) ? " "n"`
    case "$gralp" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    vesrc=`getanswer "Install ve src (y/n) ? " "n"`
    case "$vesrc" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    hsurfsrc=`getanswer "Install hsurf src (y/n) ? " "n"`
    case "$hsurfsrc" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    hplotsrc=`getanswer "Install hplot src (y/n) ? " "n"`
    case "$hplotsrc" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    pathsrc=`getanswer "Install path way src (y/n) ? " "n"`
    case "$pathsrc" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    ref=`getanswer "Install ref src (y/n) ? " "n"`
    case "$ref" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    miniems=`getanswer "Install miniems src (y/n) ? " "n"`
    case "$miniems" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

#
# End baseanswer = "p" prompts
#
  
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

if [ "$baseanswer" = "p" -o "$baseanswer" = "y" ]
then
  echo "Installing Base MODEL platform in $UNIXDIR"
  echo "Installing Base MODEL platform in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile modelsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile modelsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?

  if [ "${SUFF}" = "sgi" -o "${SUFF}" = "ssl" -o "${SUFF}" = "zx" ]
  then
    getfile transos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  fi

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

  getfile modelinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?


fi

#if [ "$shlib" = "y" -o "$baseanswer" = "y" ]
#then
#  echo "Installing MODEL src_shlib in $UNIXDIR"
#  echo "Installing MODEL src_shlib in $UNIXDIR" >$LOGFILE 2>&1
#  echo
#  date >>$LOGFILE 2>&1
#
#  getfile mdshlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
#  retstatus=$?
#fi


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

if [ "$ref" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_ref in $UNIXDIR"
  echo "Installing MODEL src_ref in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdref.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdref.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi


if [ "$assem" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_assem in $UNIXDIR"
  echo "Installing MODEL src_assem in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdassem.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdassem.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$assoc" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_assoc in $UNIXDIR"
  echo "Installing MODEL src_assoc in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdassoc.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdassoc.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$bound" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_bound in $UNIXDIR"
  echo "Installing MODEL src_bound in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdbound.com | compress -d | cpio -imud   >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdbound.${SUFF} | compress -d | cpio -imud   >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$cnstr" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_cnstr in $UNIXDIR"
  echo "Installing MODEL src_cnstr in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdcnstr.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdcnstr.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$co" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_co in $UNIXDIR"
  echo "Installing MODEL src_co in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdco.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdco.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$co_mass" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_co_mass in $UNIXDIR"
  echo "Installing MODEL src_co_mass in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdco_mass.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdco_mass.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$comp" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_comp in $UNIXDIR"
  echo "Installing MODEL src_comp in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdcomp.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdcomp.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$compcv" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_compcv in $UNIXDIR"
  echo "Installing MODEL src_compcv in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdcompcv.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdcompcv.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$compsf" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_compsf in $UNIXDIR"
  echo "Installing MODEL src_compsf in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdcompsf.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdcompsf.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$curve" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_curve in $UNIXDIR"
  echo "Installing MODEL src_curve in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdcurve.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdcurve.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$dpb" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_dpb in $UNIXDIR"
  echo "Installing MODEL src_dpb in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mddpb.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mddpb.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$dpr" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_dpr in $UNIXDIR"
  echo "Installing MODEL src_dpr in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mddpr.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mddpr.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$ff" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_freeform in $UNIXDIR"
  echo "Installing MODEL src_freeform in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdff.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdff.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$funk" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_funk in $UNIXDIR"
  echo "Installing MODEL src_funk in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdfunk.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdfunk.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$gradat" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_gradat in $UNIXDIR"
  echo "Installing MODEL src_gradat in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdgradat.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdgradat.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$listen" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_listen in $UNIXDIR"
  echo "Installing MODEL src_listen in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdlisten.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdlisten.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$mass" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_mass in $UNIXDIR"
  echo "Installing MODEL src_mass in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdmass.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdmass.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$param" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_param in $UNIXDIR"
  echo "Installing MODEL src_param in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdparam.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdparam.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$place" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_place in $UNIXDIR"
  echo "Installing MODEL src_place in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdplace.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdplace.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$serim" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_serim in $UNIXDIR"
  echo "Installing MODEL src_serim in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdserim.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdserim.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$shell" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_shell in $UNIXDIR"
  echo "Installing MODEL src_shell in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdshell.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdshell.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$sketch" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_sketch in $UNIXDIR"
  echo "Installing MODEL src_sketch in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdsketch.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdsketch.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$solid" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_solid in $UNIXDIR"
  echo "Installing MODEL src_solid in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdsolid.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdsolid.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$surf" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_surf in $UNIXDIR"
  echo "Installing MODEL src_surf in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdsurf.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdsurf.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$testco" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_testco in $UNIXDIR"
  echo "Installing MODEL src_testco in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdtestco.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdtestco.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$util" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_util in $UNIXDIR"
  echo "Installing MODEL src_util in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdutil.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdutil.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$xsec" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_xsec in $UNIXDIR"
  echo "Installing MODEL src_xsec in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdxsec.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdxsec.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$datum" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_datum in $UNIXDIR"
  echo "Installing MODEL src_datum in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mddatum.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mddatum.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$tol" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_tol in $UNIXDIR"
  echo "Installing MODEL src_tol in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdtol.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdtol.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$nm" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_nm in $UNIXDIR"
  echo "Installing MODEL src_nm in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdnm.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdnm.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$drawvw" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_drawvw in $UNIXDIR"
  echo "Installing MODEL src_drawvw in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mddrawvw.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mddrawvw.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$gralp" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing MODEL src_gralp in $UNIXDIR"
  echo "Installing MODEL src_gralp in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdgralp.com | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdgralp.${SUFF} | compress -d | cpio -imud  >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$hsurfsrc" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing HSURF source in $UNIXDIR"
  echo "Installing HSURF source in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdhsurfsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdhsurfsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$vesrc" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing VE source in $UNIXDIR"
  echo "Installing VE source in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdvesrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdvesrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$hplotsrc" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing Hplot source in $UNIXDIR"
  echo "Installing Hplot source in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdhplotsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdhplotsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$pathsrc" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing Path Way source in $UNIXDIR"
  echo "Installing Path Way source in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile mdpw.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile mdpw.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

if [ "$miniems" = "y" -o "$baseanswer" = "y" ]
then
  echo "Installing miniems source in $UNIXDIR"
  echo "Installing miniems source in $UNIXDIR" >$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile miniems.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile miniems.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

rm -f /usr/bin/startup.model
ln -s $UNIXDIR/bin/startup.model /usr/bin

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
    /usr/tmp/hsplot.assign  $UNIXDIR/bin/HSplot
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

date >>$LOGFILE 2>&1

if [ -f $UNIXDIR/hsurf/lib/skystub.o ]
then
ln $UNIXDIR/hsurf/lib/skystub.o $UNIXDIR
fi

mv $UNIXDIR/lib/$CPUTYPE/* $UNIXDIR/lib
rmdir $UNIXDIR/lib/$CPUTYPE
ln -s $UNIXDIR/lib $UNIXDIR/lib/$CPUTYPE

mv $UNIXDIR/src_lib/$CPUTYPE/* $UNIXDIR/src_lib
rmdir $UNIXDIR/src_lib/$CPUTYPE
ln -s $UNIXDIR/src_lib $UNIXDIR/src_lib/$CPUTYPE

mv $UNIXDIR/ve/lib/$CPUTYPE/* $UNIXDIR/ve/lib
rmdir $UNIXDIR/ve/lib/$CPUTYPE
ln -s $UNIXDIR/ve/lib $UNIXDIR/ve/lib/$CPUTYPE

mv $UNIXDIR/hsurf/lib/$CPUTYPE/* $UNIXDIR/hsurf/lib
rmdir $UNIXDIR/hsurf/lib/$CPUTYPE
ln -s $UNIXDIR/hsurf/lib $UNIXDIR/hsurf/lib/$CPUTYPE

echo "Linking spec files .  .  ."
find ${UNIXDIR}/src_* -name '*.S' -exec ln {} ${UNIXDIR}/spec \;
rm -f ${UNIXDIR}/spec/global_class.S

touch $UNIXDIR/.download

if [ "$chgown" = "y" ]
then
  find $UNIXDIR -print | xargs chown $LOGNAME
  find $UNIXDIR -print | xargs chmod ugo+rw
  find $UNIXDIR -type d -print | xargs chmod ugo+x
  find $UNIXDIR/bin -print | xargs chmod ugo+x
fi

exit $retstatus

