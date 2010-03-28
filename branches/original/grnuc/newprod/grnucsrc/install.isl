#
# Copyright Intergraph Corporation	14-DEC-1986
#
# GRNUC SRC Product Installation
#
# Synopsis
#
#    install.sh -[VTF] <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#
# History
#
#	27 MAR 1991	PCW	Initial mods for 2.0.1
#	05 APR 1991	PCW	Removed src/co/dtlco and src/go/dtl
#       29 SEP 1993     SCW     Added INGRHOME Support
#       27 OCT 1993     SCW     Added INGRHOME dso link Support
#       15 DEC 1993     SCW     Fixed syntax error in test
#       04 JAN 1994     SCW     Changed refco to rfsup variable
#       05 JAN 1994     SCW     Removed all references to SunOS 4.X
#       05 JAN 1994     SCW     Added extra prompts for invalid responses
#       08 MAR 1994     SCW     Changed protections once loaded
#       09 MAR 1994     SCW     Changed chmod to use ugo
#       18 AUG 1994     SCW     Added ISL processor type
#       30 SEP 1994     SCW     Added ntplotlib package
#       05 OCT 1994     KBR     Removed raster install for isl CR# 119422937
#       05 OCT 1994     KBR     Cleaned up raster prompting for Pload
#       12 JAN 1995     SCW     Corrected newsymbols placement
#       14 MAR 1995     SCW     Added XGL prompting
#       21 MAR 1995     SCW     Corrected syntax error from XGL prompt
#       19 JUL 1995     SCW     Changed XGL prompting for 2.4 or higher OS
#

PROMPTXGL=n
DEFDIR=$4

if [ "$0" = "install.isl" ]
then
  SUFF="isl"
  CPUTYPE="isl"
  export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "install.ssl" ]
then
  SUFF="ssl"
  CPUTYPE="sun5"
  export INGRHOME=${INGRHOME:-/opt/ingr}

  OSver="$(uname -r | cut -c1-3)"
  if [ "${OSver}" -ge "5.4" ]  # Solaris 2.4 or higher
  then
    PROMPTXGL="y"
  fi
fi

if [ "$0" = "install.sgi" ]
then
  SUFF="sgi"
  CPUTYPE="sgi"
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

if [ -d $DEFDIR ]; then LOGFILE=$DEFDIR/log; else LOGFILE=/dev/null; fi>$LOGFILE

UNIXDIR=`getanswer "Enter directory for GRNUCSRC" "$DEFDIR"`

while true
do
  BASE=`getanswer "Install the base GRNUC Source Platform (y/n) ?" "y"`
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

if [ "${SUFF}" = "p" ]
then
  tarcpu=`getanswer "Install GRNUCSRC Libraries for C100 or C400 ?" "C100"`
  tarcpu=`echo ${tarcpu} | tr "[a-z]" "[A-Z]"`
  echo "\nDownloading $tarcpu libraries . . . "
  if [ "$tarcpu" = "C400" ]
  then
    SUFF="p4"
    CPUTYPE="c400"
  else
    CPUTYPE="c100"
  fi
else
  tarcpu=""
fi

while true
do
  LIBS=`getanswer "Install GRNUCSRC Archive Libraries (y/n) ?" "y"`
  case "$LIBS" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  INTEG=`getanswer "Install GRNUCSRC Integration Utilities (y/n) ?" "y"`
  case "$INTEG" in
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
  while true
  do
    RASTER=`getanswer "Install GRNUCSRC Raster Component (y/n) ?" "y"`
    case "$RASTER" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    RASTERINCSPC=`getanswer "Install GRNUCSRC Raster Specs and Includes (y/n) ?" "n"`
    case "$RASTERINCSPC" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

while true
do
  EXAMPLES=`getanswer "Install GRNUCSRC PPL Examples (y/n) ?" "n"`
  case "$EXAMPLES" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  FONTLIB=`getanswer "Install GRNUCSRC Font Library (y/n) ?" "n"`
  case "$FONTLIB" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  NTPLOT=`getanswer "Install NT Plotting Font Resource Library (y/n) ?" "n"`
  case "$NTPLOT" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  IGDSCL=`getanswer "Install GRNUCSRC IGDS Cell Files (y/n) ?" "n"`
  case "$IGDSCL" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  MSGSRC=`getanswer "Install GRNUCSRC Message Source Files (y/n) ?" "n"`
  case "$MSGSRC" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

while true
do
  ATPS=`getanswer "Install GRNUCSRC ATPs (y/n) ?" "n"`
  case "$ATPS" in
    y|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
then
  while true
  do
    CVRT=`getanswer "Install GRNUCSRC Design File Converter (y/n) ?" "n"`
    case "$CVRT" in
      y|n ) break;;
         *) echo "\nInvalid. Try again\n" ;;
    esac
  done
else
  CVRT="n"
fi

while true
do
  PROMPS=`getanswer "Do you want all source (a), prompts for source (p), or none (n) ?" "p"`
  case "$PROMPS" in
    a )   allco="a" ;
          allgo="a" ;
          alloth="a" ;
          alldim="a" ;
          break;;
    p|n ) break;;
       *) echo "\nInvalid. Try again\n" ;;
  esac
done

if [ "${PROMPS}" = "p" ]
then
  while true
  do
    allco=`getanswer "Install all co files (a), prompt (p), or none (n) ?" "n"`
    case "$allco" in
      a|p|n ) break;;
           *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    allgo=`getanswer "Install all go files (a), prompt (p), or none (n) ?" "n"`
    case "$allgo" in
      a|p|n ) break;;
           *) echo "\nInvalid. Try again\n" ;;
    esac
  done

  while true
  do
    alloth=`getanswer "Install all misc. files (a), prompt (p), or none (n) ?" "n"`
    case "$alloth" in
      a|p|n ) break;;
           *) echo "\nInvalid. Try again\n" ;;
    esac
  done
fi

if [ "${PROMPS}" = "n" -o "${allco}" = "n" ]
then
   allco="n"
   arc="n"
   adpco="n"
   attrco="n"
   cct="n"
   cob="n"
   transco="n"
   cosup="n"
   cr="n"
   csco="n"
   detailco="n"
   displayco="n"
   dpbco="n"
   event="n"
   eventsco="n"
   fenceco="n"
   globalco="n"
   grgrpco="n"
   lineterm="n"
   ln="n"
   manipco="n"
   meas="n"
   misc="n"
   mod="n"
   palco="n"
   partco="n"
   smartco="n"
   plotco="n"
   poly="n"
   projco="n"
   pt="n"
   ptnco="n"
   rattrco="n"
   retco="n"
   rfco="n"
   sl="n"
   symbco="n"
   textco="n"
   toolco="n"
   coglobal="n"
   xhatch="n"
fi

if [ "${PROMPS}" = "n" -o "${allgo}" = "n" ]
then
   allgo="n"
   EMSstubs="n"
   comcv="n"
   csgo="n"
   detailgo="n" 
   dsgo="n" 
   fencego="n"
   go1="n"
   go3d="n"
   gosup="n"
   graphics="n"
   grdglobal="n"
   grgrpgo="n"
   grso="n"
   grsetgo="n"
   transgo="n"
   lcobjgo="n"
   ownergo="n"
   palgo="n"
   partgo="n"
   ptngo="n"
   ref="n"
   rfsup="n"
   so="n"
   supfungo="n"
   symbgo="n"
   tablego="n"
   textgo="n"
   undogo="n"
   vg="n"
   globalgo="n"
fi

if [ "${PROMPS}" = "n" -o "${alloth}" = "n" ]
then
   alloth="n"
   assocsrc="n"
   datum="n"
   dcob="n"
   dimsrc="n"
   grdpb="n"
   display="n"
   font="n"
   fontbuilder="n"
   gde="n"
   igecolor="n"
   igr="n"
   locate="n"
   grio="n"
   query="n"
   rap="n"
   rastsrc="n"
   transos="n"
   util="n"
   apis="n"
fi

if [ "${allgo}" = "p" ] 
then
  EMSstubs=`getanswer "Install src/go/EMSstubs (y/n) ?" "n"`
  csgo=`getanswer "Install src/go/csgo (y/n) ?" "n"`
  detailgo=`getanswer "Install src/go/detailgo (y/n) ?" "n"`
  dsgo=`getanswer "Install src/go/dsgo (y/n) ?" "n"`
  fencego=`getanswer "Install src/go/fencego (y/n) ?" "n"`
  go1=`getanswer "Install src/go/go1 (y/n) ?" "n"`
  go3d=`getanswer "Install src/go/go3d (y/n) ?" "n"`
  gosup=`getanswer "Install src/go/gosup (y/n) ?" "n"`
  graphics=`getanswer "Install src/go/graphics (y/n) ?" "n"`
  grdglobal=`getanswer "Install src/go/grdglobal (y/n) ?" "n"`
  grgrpgo=`getanswer "Install src/go/grgrpgo (y/n) ?" "n"`
  grso=`getanswer "Install src/go/so (y/n) ?" "n"`
  grsetgo=`getanswer "Install src/go/grsetgo (y/n) ?" "n"`
  transgo=`getanswer "Install src/go/transgo (y/n) ?" "n"`
  lcobjgo=`getanswer "Install src/go/lcobjgo (y/n) ?" "n"`
  ownergo=`getanswer "Install src/go/ownergo (y/n) ?" "n"`
  palgo=`getanswer "Install src/go/palgo (y/n) ?" "n"`
  partgo=`getanswer "Install src/go/partgo (y/n) ?" "n"`
  ptngo=`getanswer "Install src/go/ptngo (y/n) ?" "n"`
  ref=`getanswer "Install src/go/ref (y/n) ?" "n"`
  rfsup=`getanswer "Install src/go/rfsup (y/n) ?" "n"`
  supfungo=`getanswer "Install src/go/supfungo (y/n) ?" "n"`
  symbgo=`getanswer "Install src/go/symbgo (y/n) ?" "n"`
  tablego=`getanswer "Install src/go/tablego (y/n) ?" "n"`
  textgo=`getanswer "Install src/go/textgo (y/n) ?" "n"`
  undogo=`getanswer "Install src/go/undogo (y/n) ?" "n"`
  vg=`getanswer "Install src/go/vg (y/n) ?" "n"`
  globalgo=`getanswer "Install src/go/globalgo (y/n) ?" "n"`
fi

if [ "${allco}" = "p" ]
then
  arc=`getanswer "Install src/co/arc (y/n) ?" "n"`
  adpco=`getanswer "Install src/co/adpco (y/n) ?" "n"`
  attrco=`getanswer "Install src/co/attrco (y/n) ?" "n"`
  cob=`getanswer "Install src/co/cob (y/n) ?" "n"`
  cct=`getanswer "Install src/co/cct (y/n) ?" "n"`
  transco=`getanswer "Install src/co/transco (y/n) ?" "n"`
  cosup=`getanswer "Install src/co/cosup (y/n) ?" "n"`
  cr=`getanswer "Install src/co/cr (y/n) ?" "n"`
  csco=`getanswer "Install src/co/csco (y/n) ?" "n"`
  detailco=`getanswer "Install src/co/detailco (y/n) ?" "n"`
  displayco=`getanswer "Install src/co/displayco (y/n) ?" "n"`
  dpbco=`getanswer "Install src/co/dpbco (y/n) ?" "n"`
  event=`getanswer "Install src/co/event (y/n) ?" "n"`
  eventsco=`getanswer "Install src/co/eventsco (y/n) ?" "n"`
  fenceco=`getanswer "Install src/co/fenceco (y/n) ?" "n"`
  globalco=`getanswer "Install src/co/globalco (y/n) ?" "n"`
  grgrpco=`getanswer "Install src/co/grgrpgo (y/n) ?" "n"`
  lineterm=`getanswer "Install src/co/lineterm (y/n) ?" "n"`
  ln=`getanswer "Install src/co/ln (y/n) ?" "n"`
  manipco=`getanswer "Install src/co/manipco (y/n) ?" "n"`
  meas=`getanswer "Install src/co/meas (y/n) ?" "n"`
  misc=`getanswer "Install src/co/misc (y/n) ?" "n"`
  mod=`getanswer "Install src/co/mod (y/n) ?" "n"`
  palco=`getanswer "Install src/co/palco (y/n) ?" "n"`
  partco=`getanswer "Install src/co/partco (y/n) ?" "n"`
  plotco=`getanswer "Install src/co/plotco (y/n) ?" "n"`
  poly=`getanswer "Install src/co/poly (y/n) ?" "n"`
  projco=`getanswer "Install src/co/projco (y/n) ?" "n"`
  pt=`getanswer "Install src/co/pt (y/n) ?" "n"`
  ptnco=`getanswer "Install src/co/ptnco (y/n) ?" "n"`
  rattrco=`getanswer "Install src/co/rattrco (y/n) ?" "n"`
  retco=`getanswer "Install src/co/retco (y/n) ?" "n"`
  rfco=`getanswer "Install src/co/rfco (y/n) ?" "n"`
  sl=`getanswer "Install src/co/sl (y/n) ?" "n"`
  smartco=`getanswer "Install src/co/smartco (y/n) ?" "n"`
  symbco=`getanswer "Install src/co/symbco (y/n) ?" "n"`
  textco=`getanswer "Install src/co/textco (y/n) ?" "n"`
  toolco=`getanswer "Install src/co/toolco (y/n) ?" "n"`
  coglobal=`getanswer "Install src/co/coglobal (y/n) ?" "n"`
  xhatch=`getanswer "Install src/co/xhatch (y/n) ?" "n"`
fi

if [ "${alloth}" = "p" ]
then
  assocsrc=`getanswer "Install src/assoc (y/n) ?" "n"`
  datum=`getanswer "Install src/datum (y/n) ?" "n"`
  dcob=`getanswer "Install src/dcob (y/n) ?" "n"`
  dimsrc=`getanswer "Install src/dim (y/n) ?" "n"`
  display=`getanswer "Install src/display (y/n) ?" "n"`
  grdpb=`getanswer "Install src/grdpb (y/n) ?" "n"`
  font=`getanswer "Install src/font (y/n) ?" "n"`
  fontbuilder=`getanswer "Install src/fontbuilder (y/n) ?" "n"`
  gde=`getanswer "Install src/gde (y/n) ?" "n"`
  igr=`getanswer "Install src/IGRdir (y/n) ?" "n"`
  locate=`getanswer "Install src/locate (y/n) ?" "n"`
  grio=`getanswer "Install src/grio (y/n) ?" "n"`
  pplsrc=`getanswer "Install src/ppl (y/n) ?" "n"`
  query=`getanswer "Install src/query (y/n) ?" "n"`
  rap=`getanswer "Install src/rap (y/n) ?" "n"`
  apis=`getanswer "Install src/apis (y/n) ?" "n"`

  if [ "$SUFF" != "isl" ]
  then
    rastsrc=`getanswer "Install src/raster (y/n) ?" "n"`
  fi

  transos=`getanswer "Install src/transos (y/n) ?" "n"`
  util=`getanswer "Install src/util (y/n) ?" "n"`
fi

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
touch .download
retstatus=0

date >$LOGFILE 2>&1

#
# fix the product data file.
#
echo > $pdtmp
if [ -f $pd ]; then sed '/\"Grnuc\"/d' $pd > $pdtmp; fi
echo "\"Grnuc\" I/GRNUC GRmodule Grnuc:Brow:Pdu:Exnuc $UNIXDIR" >> $pdtmp
mv $pdtmp $pd

#
# Load XGL/ZX display if positive response to XGL prompt
#
if [ "$xgl" = "y" ]
then
  SUFF="zx"
fi

#
# install the base product
#
if [ "${BASE}" = "y" ]
then
  echo "Installing base GRNUC Source Platform in $UNIXDIR"
  echo "Installing base GRNUC Source Platform in $UNIXDIR" >>$LOGFILE 2>&1
  echo
  date >> $LOGFILE 2>&1
  rm -f config/dload/init/*
  getfile grnucsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grnucsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grconfig.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  if [ "${SUFF}" = "sgi" ]
  then
     rm -f config/trhooks.cmd
  fi

  getfile grversno.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  if [ "${SUFF}" = "ssl" -o "${SUFF}" = "zx" -o "${SUFF}" = "sgi" ]
  then
    getfile grtransos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  fi
  getfile grinclude.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grbasinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile groptinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile protoinc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grppl.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
  then
     getfile grdplot.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  fi 
  if [ "${SUFF}" = "p" -o "${SUFF}" = "p4" ]
  then
    getfile grnuclg.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  fi

  if [ ! -d userdata ]
  then
    mkdir userdata
  fi
  chmod 777 userdata

fi
retstatus=$?

#
# copy echopath and symbolically link startup.grnuc to /usr/bin. This is done
# unconditionally to support remote installation of the base product. echopath
# is copied because it is also delivered by MDS.
#
rm -f /usr/bin/startup.grnuc /usr/bin/echopath
chmod ugo+x $UNIXDIR/bin/echopath 
cp $UNIXDIR/bin/echopath /usr/bin
ln -s $UNIXDIR/bin/startup.grnuc /usr/bin

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
# install the archive libraries
#
if [ "${LIBS}" = "y" ]
then
  echo "Installing GRNUCSRC Archive Libraries"
  echo "Installing GRNUCSRC Archive Libraries" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grarchlib.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
 
  if [ "${SUFF}" = "ssl" -o "${SUFF}" = "zx" ]
  then
     cd ${UNIXDIR}/lib
     ranlib libGR*a
     cd ${UNIXDIR}/archlib
     ranlib libGR*a
  fi
fi

cd $UNIXDIR

#
# install integration utilities
#
if [ "${INTEG}" = "y" ] 
then
  echo "Installing GRNUCSRC Integration Utilities"
  echo "Installing GRNUCSRC Integration Utilities" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grinteg.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?

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
# install Raster Component
#
if [ "${RASTER}" = "y" ] 
then
    echo "Installing GRNUCSRC Raster Component"
    echo "Installing GRNUCSRC Raster Component" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    if [ "${SUFF}" = "zx" ]
    then
      getfile grraster.ssl | compress -d | cpio -imud >>$LOGFILE 2>&1
      retstatus=$?
    else
      getfile grraster.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
      retstatus=$?
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

    if [ "${RASTERINCSPC}" = "y" ]
    then
      echo "Installing GRNUCSRC Raster Specs and Includes"
      echo "Installing GRNUCSRC Raster Specs and Includes" >>$LOGFILE 2>&1
      echo
      getfile rastincspc.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
      if [ ${AOK} != 0 ] ; then exit $AOK; fi
    fi
fi

#
# install PPL Examples
#
if [ "${EXAMPLES}" = "y" ]
then
  echo "Installing GRNUCSRC PPL Examples"
  echo "Installing GRNUCSRC PPL Examples" >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grpplex.com | compress -d | cpio -imud >>$LOGFILE 2>&1; AOK=$?
  if [ ${AOK} != 0 ] ; then exit $AOK; fi
fi

#
# install Font Library
#
if [ "${FONTLIB}" = "y" ] 
then
    echo "Installing GRNUCSRC Font Library"
    echo "Installing GRNUCSRC Font Library" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile grfontlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
fi

#
# install NT Font Resource Library
#
if [ "${NTPLOT}" = "y" ] 
then
    echo "Installing NT Font Resource Library"
    echo "Installing NT Font Resource Library" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile ntplotlib.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
fi

#
# install IGDS Cell Files
#
if [ "${IGDSCL}" = "y" ] 
then
    echo "Installing GRNUCSRC IGDS Cell Files"
    echo "Installing GRNUCSRC IGDS Cell Files" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile grigdscl.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
fi

#
# Load the messages/src stuff
#
if [ "${MSGSRC}" = "y" ] 
then
  echo Installing GRNUCSRC Message Source Files
  echo Installing GRNUCSRC Message Source Files >>$LOGFILE 2>&1
  echo
  date >>$LOGFILE 2>&1

  getfile grmsgsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install ATPs
#
if [ "${ATPS}" = "y" ] 
then
    echo "Installing GRNUCSRC ATPs"
    echo "Installing GRNUCSRC ATPs" >>$LOGFILE 2>&1
    echo
    date >>$LOGFILE 2>&1

    getfile gratp.com | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
    getfile gratp.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
    retstatus=$?
fi

if [ "${CVRT}" = "y" ]
then

  echo Installing GRNUCSRC Converter
  echo Installing GRNUCSRC Converter >>$LOGFILE 2>&1
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

#
# install xhatch
#
if [ "${xhatch}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing xhatch"
  echo "Installing xhatch" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile xhatch.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile xhatch.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install cct
#
if [ "${cct}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing cct"
  echo "Installing cct" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile cct.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile cct.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


# install raster

if [ "${rastsrc}" = "y" ] || [ "${alloth}" = "a" ]
then
  echo "Installing raster"
  echo "Installing raster" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile rastsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile rastsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install transos
#
if [ "${transos}" = "y" ] || [ "${alloth}" = "a" ]
then
  echo "Installing transos"
  echo "Installing transos" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile transos.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile transos.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install util
#
if [ "${util}" = "y" ] || [ "${alloth}" = "a" ]
then
  echo "Installing util"
  echo "Installing util" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile util.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile util.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# Load the ppl stuff
#
if [ "${pplsrc}" = "y" ] || [ "${alloth}" = "a" ]
then
  echo Installing ppl
  echo Installing ppl >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grpplsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grppl.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  getfile grpplsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# Load rap
#
if [ "${rap}" = "y" ] || [ "${alloth}" = "a" ]
then
  echo Installing rap
  echo Installing rap >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile rap.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile rap.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install attrco
#
if [ "${attrco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing attrco"
  echo "Installing attrco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile attrco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile attrco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install palco
#
if [ "${palco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing palco"
  echo "Installing palco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile palco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile palco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install smartco
#
if [ "${smartco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing smartco"
  echo "Installing smartco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile smartco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile smartco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install partco
#
if [ "${partco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing partco"
  echo "Installing partco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile partco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile partco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install detailco
#
if [ "${detailco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing detailco"
  echo "Installing detailco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile detailco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile detailco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install displayco
#
if [ "${displayco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing displayco"
  echo "Installing displayco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile displayco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile displayco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install dpbco
#
if [ "${dpbco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing dpbco"
  echo "Installing dpbco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile dpbco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile dpbco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install ref
#
if [ "${ref}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing ref"
  echo "Installing ref" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ref.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile ref.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install rfsup
#
if [ "${rfsup}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing rfsup"
  echo "Installing rfsup" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile rfsup.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile rfsup.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi
#
# install csgo
#
if [ "${csgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing csgo"
  echo "Installing csgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile csgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile csgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install fenceco
#
if [ "${fenceco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing fenceco"
  echo "Installing fenceco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile fenceco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile fenceco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install globalco
#
if [ "${globalco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing globalco"
  echo "Installing globalco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile globalco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile globalco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install grgrpco
#
if [ "${grgrpco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing grgrpco"
  echo "Installing grgrpco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grgrpco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grgrpco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi
#
# install cosup
#
if [ "${cosup}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing cosup"
  echo "Installing cosup" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile cosup.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile cosup.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install grso
#
if [ "${grso}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing grso"
  echo "Installing grso" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grso.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grso.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install grsetgo
#
if [ "${grsetgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing grsetgo"
  echo "Installing grsetgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grsetgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grsetgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install transgo
#
if [ "${transgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing transgo"
  echo "Installing transgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile transgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile transgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install lcobjgo
#
if [ "${lcobjgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing lcobjgo"
  echo "Installing lcobjgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile lcobjgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile lcobjgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install EMSstubs
#
if [ "${EMSstubs}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing EMSstubs"
  echo "Installing EMSstubs" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile EMSstubs.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile EMSstubs.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install grgrpgo
#
if [ "${grgrpgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing grgrpgo"
  echo "Installing grgrpgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grgrpgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grgrpgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install fencego
#
if [ "${fencego}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing fencego"
  echo "Installing fencego" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile fencego.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile fencego.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install go1
#
if [ "${go1}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing go1"
  echo "Installing go1" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile go1.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile go1.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install go3d
#
if [ "${go3d}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing go3d"
  echo "Installing go3d" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile go3d.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile go3d.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install detailgo
#
if [ "${detailgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing detailgo"
  echo "Installing detailgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile detailgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile detailgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install dsgo
#
if [ "${dsgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing dsgo"
  echo "Installing dsgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile dsgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile dsgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install gosup
#
if [ "${gosup}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing gosup"
  echo "Installing gosup" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile gosup.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile gosup.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install graphics
#
if [ "${graphics}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing graphics"
  echo "Installing graphics" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile graphics.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile graphics.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install grdglobal
#
if [ "${grdglobal}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing grdglobal"
  echo "Installing grdglobal" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grdglobal.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grdglobal.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install ownergo
#
if [ "${ownergo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing ownergo"
  echo "Installing ownergo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ownergo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile ownergo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install supfungo
#
if [ "${supfungo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing supfungo"
  echo "Installing supfungo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile supfungo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile supfungo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install symbgo
#
if [ "${symbgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing symbgo"
  echo "Installing symbgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile symbgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile symbgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install tablego
#
if [ "${tablego}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing tablego"
  echo "Installing tablego" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile tablego.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile tablego.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install textgo
#
if [ "${textgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing textgo"
  echo "Installing textgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile textgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile textgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install palgo
#
if [ "${palgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing palgo"
  echo "Installing palgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile palgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile palgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install partgo
#
if [ "${partgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing partgo"
  echo "Installing partgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile partgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile partgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install undogo
#
if [ "${undogo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing undogo"
  echo "Installing undogo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile undogo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile undogo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install vg
#
if [ "${vg}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing vg"
  echo "Installing vg" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile vg.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile vg.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install globalgo
#
if [ "${globalgo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing globalgo"
  echo "Installing globalgo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile globalgo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile globalgo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install ptngo
#
if [ "${ptngo}" = "y" -o "${allgo}" = "a" ]
then
  echo "Installing ptngo"
  echo "Installing ptngo" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ptngo.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile ptngo.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install dimsrc
#
if [ "${dimsrc}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing dimsrc"
  echo "Installing dimsrc" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grdimsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grdimsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install assocsrc
#
if [ "${assocsrc}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing assocsrc"
  echo "Installing assocsrc" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile assocsrc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile assocsrc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install gde
#
if [ "${gde}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing gde"
  echo "Installing gde" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile gde.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile gde.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grgde.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install query
#
if [ "${query}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing query"
  echo "Installing query" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile query.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile query.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install fontbuilder
#
if [ "${fontbuilder}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing fontbuilder"
  echo "Installing fontbuilder" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile fontbuilder.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile fontbuilder.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install grdpb
#
if [ "${grdpb}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing grdpb"
  echo "Installing grdpb" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grdpb.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grdpb.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install arc
#
if [ "${arc}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing arc"
  echo "Installing arc" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile arc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile arc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install adpco
#
if [ "${adpco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing adpco"
  echo "Installing adpco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile adpco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile adpco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install cob
#
if [ "${cob}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing cob"
  echo "Installing cob" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile cob.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile cob.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install transco
#
if [ "${transco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing transco"
  echo "Installing transco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile transco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile transco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install cr
#
if [ "${cr}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing cr"
  echo "Installing cr" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile cr.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile cr.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install csco
#
if [ "${csco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing csco"
  echo "Installing csco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile csco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile csco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install event
#
if [ "${event}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing event"
  echo "Installing event" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile event.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile event.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install eventsco
#
if [ "${event}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing eventsco"
  echo "Installing eventsco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile eventsco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile eventsco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install lineterm
#
if [ "${lineterm}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing lineterm"
  echo "Installing lineterm" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile lineterm.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile lineterm.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install ln
#
if [ "${ln}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing ln"
  echo "Installing ln" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ln.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile ln.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install meas
#
if [ "${meas}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing meas"
  echo "Installing meas" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile meas.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile meas.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install misc
#
if [ "${misc}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing misc"
  echo "Installing misc" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile misc.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile misc.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install manipco
#
if [ "${manipco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing manipco"
  echo "Installing manipco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile manipco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile manipco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install mod
#
if [ "${mod}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing mod"
  echo "Installing mod" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile mod.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile mod.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install plotco
#
if [ "${plotco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing plotco"
  echo "Installing plotco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile plotco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile plotco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install poly
#
if [ "${poly}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing poly"
  echo "Installing poly" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile poly.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile poly.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install projco
#
if [ "${projco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing projco"
  echo "Installing projco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile projco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile projco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install pt
#
if [ "${pt}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing pt"
  echo "Installing pt" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile pt.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile pt.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi
#
# install ptnco
#
if [ "${ptnco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing ptnco"
  echo "Installing ptnco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile ptnco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile ptnco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install rattrco
#
if [ "${rattrco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing rattrco"
  echo "Installing rattrco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile rattrco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile rattrco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install retco
#
if [ "${retco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing retco"
  echo "Installing retco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile retco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile retco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install rfco
#
if [ "${rfco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing rfco"
  echo "Installing rfco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile rfco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile rfco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install sl
#
if [ "${sl}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing sl"
  echo "Installing sl" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile sl.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile sl.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install symbco
#
if [ "${symbco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing symbco"
  echo "Installing symbco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile symbco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile symbco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install coglobal
#
if [ "${sl}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing coglobal"
  echo "Installing coglobal" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile coglobal.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile coglobal.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install textco
#
if [ "${textco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing textco"
  echo "Installing textco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile textco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile textco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install toolco
#
if [ "${toolco}" = "y" -o "${allco}" = "a" ]
then
  echo "Installing toolco"
  echo "Installing toolco" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile toolco.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile toolco.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi


#
# install dcob
#
if [ "${dcob}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing dcob"
  echo "Installing dcob" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile dcob.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile dcob.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi



#
# install display
#
if [ "${display}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing display"
  echo "Installing display" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile display.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile display.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install font
#
if [ "${font}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing font"
  echo "Installing font" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile font.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile font.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi
#
# install font
#
if [ "${igr}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing IGRdir"
  echo "Installing IGRdir" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile src.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile src.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install locate
#
if [ "${locate}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing locate"
  echo "Installing locate" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile locate.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile locate.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install grio
#
if [ "${grio}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing grio"
  echo "Installing grio" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grio.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grio.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

#
# install apis
#
if [ "${apis}" = "y" -o "${alloth}" = "a" ]
then
  echo "Installing apis"
  echo "Installing apis" >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1

  getfile grrefapi.com | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
  getfile grrefapi.${SUFF} | compress -d | cpio -imud >>$LOGFILE 2>&1
  retstatus=$?
fi

echo

if [ "$chgown" = "y" ]
then
  find $UNIXDIR -print | xargs chown $LOGNAME
  find $UNIXDIR -print | xargs chmod ugo+rw
  find $UNIXDIR -type d -print | xargs chmod ugo+x
  find $UNIXDIR/userdata -print | xargs chmod ugo+wx
  find $UNIXDIR/bin -print | xargs chmod ugo+x
  if [ "$CVRT" = "y" ]
  then
    find $UNIXDIR/cvrt/bin -print | xargs chmod ugo+x
  fi
fi

mv $UNIXDIR/lib/$CPUTYPE/* $UNIXDIR/lib
rmdir $UNIXDIR/lib/$CPUTYPE
ln -s $UNIXDIR/lib $UNIXDIR/lib/$CPUTYPE

mv $UNIXDIR/archlib/$CPUTYPE/* $UNIXDIR/archlib
rmdir $UNIXDIR/archlib/$CPUTYPE
ln -s $UNIXDIR/archlib $UNIXDIR/archlib/$CPUTYPE

find ${UNIXDIR}/src -type f -name "*.S" -exec ln {} ${UNIXDIR}/spec

date >>$LOGFILE 2>&1

exit $retstatus
