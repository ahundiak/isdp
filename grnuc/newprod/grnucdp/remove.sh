#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SNS0091
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

Grnuc_Location=`echopath GRNUC`

if [ "$justdoit" = "y" ]
then
  RemoveGRNUC=y
else
  echo "Remove GRNUC (y/n)? [y] \c"
  read RemoveGRNUC; : ${RemoveGRNUC:=y}
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
  if [ "$0" = "./remove.sgi" ]
  then
    rm -f ${INGRHOME}/lib/grnuc.so
  fi
  if [ "$0" != "./remove.sgi" ]
  then
    if inqlgexist; then lgrmcmds /usr/tmp/agrnuc.ftc; fi
  fi
fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."
