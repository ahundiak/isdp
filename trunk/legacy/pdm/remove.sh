#
#	INTERGRAPH/VAX Delivery Procedures
#
	export PRODUCT_ID=SMU0052
	export PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#
# Calling Seq:	remove.sh
# Change History:
#
echo "$PRODUCT_FL -- $PRODUCT_ID"

pd=/usr/ip32/product_data
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

function echopath {
    noerror=$1
    if [ $noerror = noerror ]
    then
        shift
    fi
    item=$1
    pdata=$2
    me=$3

    path=`awk '/ '$item' / {print $5}' $pdata`

    if [ -d "$path" ]
    then
        echo $path
        exit 0
    else
        if [ $noerror != noerror ]
        then
            echo $me: $path no path for $item 1>&2
        fi
        exit 1
    fi
}

ems_path=`echopath I\\\/EMS $pd $0`

pdu_path=`echopath I\\\/PDU $pd $0`

Test_id=`id | cut -c5`
if [ $Test_id -eq 0 ]
then
   if (test ! -d $pdu_path)
   then
      echo "\n   %Error - Invalid Directory - $pdu_path\n"
   else
      echo "Remove I_PDU Product in '$pdu_path' [y]? \c"
      read answer
      if [ "$answer" = "" ]
      then
         Answer="y"
      else
         Answer=`echo $answer | cut -c1-1`
      fi
      if [ "$Answer" = "y" -o "$Answer" = "Y" ]
      then
         cd /usr/ip32
         sed '/\"Pdu\"/d' product_data > Product_T1
         mv Product_T1 product_data
         rm -rf $pdu_path
         unlink /usr/ip32/pdu
      fi
   fi
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
else
   echo ""
   echo "   Must be Super-User to run Remove"
   echo ""
fi
echo "$PRODUCT_FL -- $PRODUCT_ID operation complete."
