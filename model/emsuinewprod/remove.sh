#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SN01090
	export PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
echo NOT READY
exit
echo "$PRODUCT_FL -- $PRODUCT_ID"
ROOT=
DSERV=n
DISKLESS=n
Model_Location=
Grnuc_Location=
Dignuc_Location=
Exnuc_Location=
Bspmath_Location=

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
      echo "              this is the last copy of MODEL on the diskless system"
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


Model_Location=`echopath MODEL ${ROOT}${INGRHOME}/product_data`

if [ $Model_Location ]
then
  if [ "$justdoit" = "y" ]
  then
    RemoveMODEL=y
  else
    echo "Remove MODEL (y/n)? [y] \c"
    read RemoveMODEL; : ${RemoveMODEL:=y}
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
    rm -rf ${ROOT}$Model_Location
    mv /tmp/tremove.sh ${INGRHOME}/model/remove.sh
    mv /tmp/tproduct.def ${INGRHOME}/model/product.def
  else
    rm -rf ${ROOT}$Model_Location
  fi
fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."

if [ $DISKLESS = y ]
 then
echo "** WARNING ** Do not answer yes to the following remove question, unless"
echo "              this is the last copy of MODEL on the diskless system"
fi


