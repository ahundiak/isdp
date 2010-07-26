#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SN01088
	export PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
echo "$PRODUCT_FL -- $PRODUCT_ID"
ROOT=
DSERV=n 
DISKLESS=n 
Grnuc_Location=
Dignuc_Location=
Exnuc_Location=
Bspmath_Location=

if [ "$1" = "" ]
then
  echo "^G"
  echo "You must use deltools/remove to remove MODEL"
  exit 1
fi

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
      echo "              this is the last copy of GRNUC on the diskless system"
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


Grnuc_Location=`echopath GRNUC ${ROOT}${INGRHOME}/product_data`

if [ $Grnuc_Location ]
then
  if [ "$justdoit" = "y" ]
  then
    RemoveGRNUC=y
  else
    echo "Remove GRNUC (y/n)? [y] \c"
    read RemoveGRNUC; : ${RemoveGRNUC:=y}
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
  if [ "$0" != "./remove.sgi" ]
  then
    if inqlgexist; then lgrmcmds /usr/tmp/grnuc.ftc; fi
  fi
fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."

if [ $DISKLESS = y ]
then
 echo "** WARNING ** Do not answer yes to the following remove question, unless"
 echo "              this is the last copy of GRNUC on the diskless system"
fi

