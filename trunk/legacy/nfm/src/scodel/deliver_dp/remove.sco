#
#	INTERGRAPH/VAX Delivery Procedures
#
#	Changed for the Sun by Vasu - 29.11.93
	PRODUCT_ID=SN0L157
	PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#

echo "$PRODUCT_FL -- $PRODUCT_ID\n"
if [ -z "$IDname" ]
then
        echo ""
        echo ""
        echo "Please use the remove program in the deltools directory"
        echo "to remove this product (i.e. /usr/ip32/deltools/remove)"
        echo "The remove.sh in each directory was intended to be called"
        echo "from the remove program in the deltools directory."
        echo ""
        echo ""
        exit 255
fi

#
# Display information about the product.
#


NFDATA=`grep $PRODUCT_ID /usr/ip32/ingrconfig`
NFNAME=`echo $NFDATA | cut -f2 -d"#"`
NFVER=`echo $NFDATA | cut -f4 -d"#"`
NFDATE=`echo $NFDATA | cut -f5 -d"#"`
NFDIR=`echo $NFDATA | cut -f6 -d"#"`

echo "\nThis is the product $NFNAME, $PRODUCT_ID, \c"
echo "the Intergraph Network File Manager Development Platform,"
echo "Version $NFVER, dated $NFDATE.\n"

incans=n
libans=n

#
# Prompt for confirmation on parts of the product.
#

if [ -d $2/lib ]
then
echo "Remove the $IDname Libraries (y/n) ? [y] \c"
read libans; : ${libans:=y}
fi

if [ -d $2/include ] 
then
echo "Remove the $IDname Include Files (y/n) ? [y] \c"
read incans; : ${incans:=y}
fi

#
# Do the removing...
#

case $libans in
y*|Y*)
    echo "\nRemoving $IDname Libraries"
    /bin/rm -r lib                               >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $incans in
y*|Y*)
    echo "\nRemoving $IDname Include Files"
    /bin/rm -r include                               >/dev/null 2>&1
    ;;
*)
    ;;
esac

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete.\n"
exit 0
