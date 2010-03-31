#
#	INTERGRAPH/VAX Delivery Procedures
#
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#

ROOT=
DSERV=n
DISKLESS=n
Ems_Location=
Model_Location=
Grnuc_Location=
Dignuc_Location=
Exnuc_Location=
Bspmath_Location=

PNAME=$1
PLOC=$2

if [ "$PLOC" = "" ]
then
  echo "^G"
  echo "You must use deltools/remove to remove Mechanical Products"
  exit 1
fi


echo "REMOVE -- $PNAME"

if [ -d /export/template ]
then
  DISKLESS=y
  echo "\nRemove from client systems <y/n> [y]\b\b\c"
  read ANS; : ${ANS:=y}
  if [ $ANS = y ]
  then
    echo "\ntemplates available"
    echo "------------------"
    cd /export/template
    ls
    echo "------------------"
    echo "                    Enter template to remove from -> \c"
    read TEMPLATE
    ROOT=/export/template/${TEMPLATE}
    if [ ! -d $ROOT ]
    then
      echo "**ERROR** template not found, no products removed"
      echo
      echo "** WARNING ** Do not answer yes to the following remove question, unless"
      echo "              this is the last copy of EMS on the diskless system"
      exit 9
    fi
  else
    echo "\nRemoving from server . . ."
    DSERV=y
  fi
fi

export INGRHOME=${INGRHOME:-/usr/ip32}
if [ "$INGRHOME" = "/dev/null" ]
then
  INGRHOME="/usr/ip32"
fi

pd=${ROOT}${INGRHOME}/product_data
pdtmp=${ROOT}${INGRHOME}/pdtmp

if [ ! -r $pd ]
then
  if [ -f $pd ]
  then
    echo $0: $pd not readable. 1>&2
    exit 1
  else
    echo $0: $pd not found. 1>&2
    exit 2
  fi
fi

Bspmath_Location=`echopath BSPMATH ${ROOT}${INGRHOME}/product_data`

Exnuc_Location=`echopath EXNUC ${ROOT}${INGRHOME}/product_data`

if [ "$0" = "./remove.sh" ]
then
  Dignuc_Location=`echopath DIGNUC ${ROOT}${INGRHOME}/product_data`
fi

Grnuc_Location=`echopath GRNUC ${ROOT}${INGRHOME}/product_data`

Model_Location=`echopath MODEL ${ROOT}${INGRHOME}/product_data`

Ems_Location=`echopath EMSUI02 ${ROOT}${INGRHOME}/product_data`

if [ "$justdoit" = "y" ]
then
  RemovePACK=y

  if [ $Ems_Location ]
  then
    RemoveEMS=y
  fi

  if [ $Model_Location ]
  then
    RemoveMODEL=y
  fi

  if [ $Grnuc_Location ]
  then
    RemoveGRNUC=y
  fi

  if [ $Dignuc_Location ]
  then
    RemoveDIGNUC=y
  fi

  if [ $Exnuc_Location ]
  then
    RemoveEXNUC=y
  fi

  if [ $Bspmath_Location ]
  then
    RemoveBSPMATH=y
  fi
else
  echo "Remove $PNAME (y/n)? [y] \c"
  read RemovePACK; : ${RemovePACK:=y}

  if [ $Ems_Location ]
  then
    echo "Remove EMSNUC (y/n)? [y] \c"
    read RemoveEMS; : ${RemoveEMS:=y}
  fi

  if [ $Model_Location ]
  then
    echo "Remove MODEL (y/n)? [y] \c"
    read RemoveMODEL; : ${RemoveMODEL:=y}
  fi

  if [ $Grnuc_Location ]
  then
    echo "Remove GRNUC (y/n)? [y] \c"
    read RemoveGRNUC; : ${RemoveGRNUC:=y}
  fi

  if [ $Dignuc_Location ]
  then
    echo "Remove DIGNUC (y/n)? [y] \c"
    read RemoveDIGNUC; : ${RemoveDIGNUC:=y}
  fi

  if [ $Exnuc_Location ]
  then
    echo "Remove EXNUC (y/n)? [y] \c"
    read RemoveEXNUC; : ${RemoveEXNUC:=y}
  fi

  if [ $Bspmath_Location ]
  then
    echo "Remove BSPMATH (y/n)? [y] \c"
    read RemoveBSPMATH; : ${RemoveBSPMATH:=y}
  fi
fi

if [ "$RemovePACK" = "y" ]
then
  PNAMEL=`echo $PNAME | tr "[A-Z]" "[a-z]" | sed 's/ems/Ems/' | sed 's/mds/Mds/' | tr -d '-' | tr -d 'i_'`
  sed "/\"$PNAMEL\"/d" $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/ems/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/ems/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$PLOC
    mv /tmp/tremove.sh ${INGRHOME}/ems/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/ems/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$PLOC
  fi

  if [ "$0" = "./remove.sh" ]
  then
    if inqlgexist; then lgrmcmds /usr/tmp/ems.ftc; fi
  fi
fi

if [ "$RemoveEMS" = "y" ]
then
  TEms_Location=`echo $Ems_Location | sed 's/\/emsui02//'`

  # Remove high resolution menu entries
  sed '/\"Emsui02/d'  $pd > $pdtmp  # Ems Nucleus
  mv $pdtmp $pd
  sed '/\"Emsuilt/d'  $pd > $pdtmp  # Ems Lite
  mv $pdtmp $pd
  sed '/\"Emsuiu/d'   $pd > $pdtmp  # Ems Ultra Lite
  mv $pdtmp $pd

  # Remove low resolution menus entries
  sed '/\"Emsui02l/d' $pd > $pdtmp  # Ems Nucleus
  mv $pdtmp $pd
  sed '/\"Emsuiltl/d' $pd > $pdtmp  # Ems Lite
  mv $pdtmp $pd
  sed '/\"Emsuiul/d'  $pd > $pdtmp  # Ems Ultra Lite
  mv $pdtmp $pd

  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/ems/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/ems/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$TEms_Location
    mv /tmp/tremove.sh ${INGRHOME}/ems/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/ems/product.def
  else
    if [ -f /usr/lib/IHdocdir.tbl ]
    then
      if [ -f ${Ems_Location}/emsui02/config/english/HELPFILE ]
      then
        rmhdoc.sh ${Ems_Location}/emsui02/config/english/HELPFILE
      fi
    fi
    cd /tmp
    rm -rf ${ROOT}$TEms_Location
  fi
  TEms_Location=`echo $Ems_Location | sed 's/\/emsui02//'`
  sed '/\"Emsui02/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/ems/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/ems/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$TEms_Location
    mv /tmp/tremove.sh ${INGRHOME}/ems/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/ems/product.def
  else
    if [ -f /usr/lib/IHdocdir.tbl ]
    then
      if [ -f ${Ems_Location}/emsui02/config/english/HELPFILE ]
      then
        rmhdoc.sh ${Ems_Location}/emsui02/config/english/HELPFILE
      fi
    fi
    cd /tmp
    rm -rf ${ROOT}$TEms_Location
  fi

  if [ "$0" = "./remove.sh" ]
  then
    if inqlgexist; then lgrmcmds /usr/tmp/ems.ftc; fi
  fi
fi

if [ "$RemoveMODEL" = "y" ]
then
  sed '/\"Model\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/model/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/model/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$Model_Location
    if [ "$0" = "./remove.sgi" ]
    then
      rm -f ${INGRHOME}/lib/model.so
      rm -f ${INGRHOME}/lib/fixes.so
      rm -f ${INGRHOME}/lib/PDUnsl.so
    fi
    mv /tmp/tremove.sh ${INGRHOME}/model/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/model/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$Model_Location
    if [ "$0" = "./remove.sgi" ]
    then
      rm -f ${INGRHOME}/lib/model.so
      rm -f ${INGRHOME}/lib/fixes.so
      rm -f ${INGRHOME}/lib/PDUnsl.so
    fi
  fi
fi

if [ "$RemoveGRNUC" = "y" ]
then
  sed '/\"Grnuc\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if `grep \"Arp\" ${INGRHOME}/product_data > /dev/null`
  then
    sed '/\"Arp\"/d' $pd > $pdtmp
    mv $pdtmp $pd
  fi
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/grnuc/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/grnuc/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$Grnuc_Location
    if [ "$0" = "./remove.sgi" ]
    then
      rm -f ${INGRHOME}/lib/grnuc.so
    fi
    mv /tmp/tremove.sh ${INGRHOME}/grnuc/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/grnuc/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$Grnuc_Location
    if [ "$0" = "./remove.sgi" ]
    then
      rm -f ${INGRHOME}/lib/grnuc.so
    fi
  fi
  if [ "$0" = "./remove.sh" ]
  then
    if inqlgexist; then lgrmcmds /usr/tmp/grnuc.ftc; fi
  fi
fi

if [ "$RemoveDIGNUC" = "y" ]
then
  sed '/\"Dignuc\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/dignuc/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/dignuc/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$Dignuc_Location
    mv /tmp/tremove.sh ${INGRHOME}/dignuc/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/dignuc/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$Dignuc_Location
  fi
fi

if [ "$RemoveEXNUC" = "y" ]
then
  sed '/\"Exnuc\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/exnuc/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/exnuc/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$Exnuc_Location
    mv /tmp/tremove.sh ${INGRHOME}/exnuc/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/exnuc/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$Exnuc_Location
  fi
fi

if [ "$RemoveBSPMATH" = "y" ]
then
  sed '/\"Bspmath\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
  then
    cp ${INGRHOME}/bspmath/remove.sh /tmp/tremove.sh
    cp ${INGRHOME}/bspmath/product.def /tmp/tproduct.def
    cd /tmp
    rm -rf ${ROOT}$Bspmath_Location
    mv /tmp/tremove.sh ${INGRHOME}/bspmath/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/bspmath/product.def
  else
    cd /tmp
    rm -rf ${ROOT}$Bspmath_Location
  fi
fi

echo "$PNAME -- operation complete."

if [ $DISKLESS = y ]
then
  echo "** WARNING ** Do not answer yes to the following remove question, unless"
  echo "              this is the last copy of EMS on the diskless system"
fi
