#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SMU0051
	export PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
echo "$PRODUCT_FL -- $PRODUCT_ID"

#
# Remove product directory
#
igr_conf=${INGRHOME}/ingrconfig
TPDM=`cat $igr_conf | grep I_PDM# | awk -F# '{print $6}' | awk -F/  '{print $2}'`
PDMdir=`echo /$TPDM/ip32/pdm`
  if [ -d $PDMdir ]
  then
     echo "Remove I/PDM from $PDMdir [y]: \c"
     read RM; : ${RM:=y}
     if [ "$RM" = "y" ]
     then
         echo
         rm -r $PDMdir
         cd ../
         rm -fr $PDMdir
         if [ -d "/usr/ip32/pdm" ]
         then
           unlink /usr/ip32/pdm
         fi
         if [ -d "/usr/pdm" ]
         then
           unlink /usr/pdm
         fi
     fi
   else
      echo "$PDMdir not found!"
      exit 1
   fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."
