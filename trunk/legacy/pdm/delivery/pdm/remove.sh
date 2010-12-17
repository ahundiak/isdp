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
# Remove server.dat entry.
#

sd=/usr/ip32/inc/server.dat
sdtmp=/usr/ip32/inc/server.tmp
PDMd=`cat $sd | grep PDMserver | awk -F/  '{print $2}'`
#PDMdir=`echo /$PDMd/ip32/pdm`

sed '/PDMserver/d' $sd > $sdtmp
mv $sdtmp $sd

#
# Remove /etc/services,/etc/inetd.conf  entry
#

if [ -d /usr/ip32/tcpip ]
then
   ts=/etc/services
   ti=/etc/inetd.conf
   tstmp=/etc/services.tmp
   titmp=/etc/inetd.tmp
 
   sed '/PDMserver/d' $ts > $tstmp
   sed '/PDMserver/d' $ti > $titmp

   mv $tstmp $ts
   mv $titmp $ti
fi

#
# Remove product directory
#
igr_conf=/usr/ip32/ingrconfig
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
     fi
  else
     echo "$PDMdir not found!"
     exit 1
  fi

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."
