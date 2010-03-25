# remove procedure for the DELTOOLS product

if [ -d $2/node ]
then
	echo "\nDelivery node files are a collection of programs that facilitate"
	echo "setting up a workstation/server up as a newprod delivery node (instead of"
	echo "using a VAX, tape, or floppy set). These files are not required for"
	echo "workstations/servers that do not intend to be used as a delivery node."
	echo "\nDo you want to remove the delivery node files? (y/n) [y]: \c"
	read ans

	case ${ans:=y} in
	[Yy*])
		rm -rf $2/node
		;;
	esac
else
	echo "Delivery node files are not loaded."
fi

if [ -d $2/vprod ]
then
    echo "Removing XVPROD files."
    rm -rf $2/vprod
fi

echo "No other DELTOOLS files may be removed.  These files are necessary"
echo "for the proper operation of your workstation."

exit 255
