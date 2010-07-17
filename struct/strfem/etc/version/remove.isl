#
#	INTERGRAPH/VAX Delivery Procedures
#
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
if [ "$0" = "./remove.sh" ]
then
        export PRODUCT_ID=SNS00XX
        export PRODUCT_FL=REMOVE
        export PRODSYS=/usr
        export INGRHOME=${INGRHOME:-/usr/ip32}
        if [ "$INGRHOME" = "/dev/null" ] ; then
                INGRHOME="/usr/ip32"
        fi
fi

if [ "$0" = "./remove.isl" ]
then
        export PRODUCT_ID=SNS00XX
        export PRODUCT_FL=REMOVE
        export PRODSYS=/opt/ingr
        export INGRHOME=${INGRHOME:-/opt/ingr}
fi

if [ "$0" = "./remove.clip" ]
then
        export PRODUCT_ID=SNS00XX
        export PRODUCT_FL=REMOVE
        export PRODSYS=/usr
        export INGRHOME=${INGRHOME:-/usr/ip32}
        if [ "$INGRHOME" = "/dev/null" ] ; then
                INGRHOME="/usr/ip32"
        fi
fi

echo "$PRODUCT_FL -- $PRODUCT_ID"
ROOT=
DSERV=n
DISKLESS=n
Strfem_Location=

if [ -d /export/template ]
then
  DISKLESS=y
  echo "\nRemove from client system <y/n> [y]\b\b\c"
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
      echo "              this is the last copy of STRFEM on the diskless system"
      exit 9
    fi
   else
    echo "\nRemoving from server . . ."
    DSERV=y
   fi
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

Strfem_Location=`echopath STRFEM ${ROOT}${INGRHOME}/product_data`

if [ $Strfem_Location ]
then
  echo "Remove STRFEM (y/n)? [y] \c"
  read RemoveSTRFEM; : ${RemoveSTRFEM:=y}
fi

if [ "$RemoveSTRFEM" = "y" ]
then
  sed '/\"Strfem\"/d' $pd > $pdtmp
  mv $pdtmp $pd
  if [ $DSERV = y ]
   then
     cp ${INGRHOME}/strfem/remove.sh /tmp/tremove.sh
     cp ${INGRHOME}/strfem/product.def /tmp/tproduct.def
     cd /tmp
     rm -rf ${ROOT}$Strfem_Location
     mv /tmp/tremove.sh ${INGRHOME}/strfem/remove.sh
     mv /tmp/tproduct.def ${INGRHOME}/strfem/product.def
  else
     rm -rf ${ROOT}$Strfem_Location
  fi

#  if inqlgexist; then lgrmcmds /usr/tmp/strfem.ftc; fi

fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."

if [ $DISKLESS = y ]
 then
      echo "** WARNING ** Do not answer yes to the following remove question, unless"
      echo "              this is the last copy of STRFEM on the diskless system"
fi
