#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SNS00MS
	export PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
echo "$PRODUCT_FL -- $PRODUCT_ID"

export INGRHOME=${INGRHOME:-/usr/ip32}
if [ "$INGRHOME" = "/dev/null" ]
then
  INGRHOME="/usr/ip32"
fi

pd=${INGRHOME}/product_data
pdtmp=${INGRHOME}/pdtmp

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

Bspmath_Location=`echopath BSPMATH`

Exnuc_Location=`echopath EXNUC`

Grnuc_Location=`echopath GRNUC`

Model_Location=`echopath MODEL`

if [ "$justdoit" = "y" ]
then
  RemoveMODEL=y
  RemoveGRNUC=y
  RemoveEXNUC=y
  RemoveBSPMATH=y
else
  echo "Remove MODEL (y/n)? [y] \c"
  read RemoveMODEL; : ${RemoveMODEL:=y}

  echo "Remove GRNUC (y/n)? [y] \c"
  read RemoveGRNUC; : ${RemoveGRNUC:=y}

  echo "Remove EXNUC (y/n)? [y] \c"
  read RemoveEXNUC; : ${RemoveEXNUC:=y}

  echo "Remove BSPMATH (y/n)? [y] \c"
  read RemoveBSPMATH; : ${RemoveBSPMATH:=y}
fi

if [ "$RemoveMODEL" = "y" ]
then
  sed '/\"Model\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  cd /tmp
  rm -rf $Model_Location
  if [ "$0" = "./remove.sgi" ]
  then
     rm -f ${INGRHOME}/lib/model.so
     rm -f ${INGRHOME}/lib/fixes.so
     rm -f ${INGRHOME}/lib/PDUnsl.so
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
  cd /tmp
  rm -rf $Grnuc_Location
fi

if [ "$RemoveEXNUC" = "y" ]
then
  sed '/\"Exnuc\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  cd /tmp
  rm -rf $Exnuc_Location
fi

if [ "$RemoveBSPMATH" = "y" ]
then
  sed '/\"Bspmath\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  cd /tmp
  rm -rf $Bspmath_Location
fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."
