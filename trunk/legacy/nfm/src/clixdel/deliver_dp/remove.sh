#
#	INTERGRAPH/VAX Delivery Procedures
#
	PRODUCT_ID=SNAM157
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
libc100ans=n
libc400ans=n

#
# Prompt for confirmation on parts of the product.
#

if [ -d $2/libc100 ]
then
echo "Remove the $IDname C100 Libraries (y/n) ? [y] \c"
read libc100ans; : ${libc100ans:=y}
fi

if [ -d $2/libc400 ] 
then
echo "Remove the $IDname C400 Libraries (y/n) ? [y] \c"
read libc400ans; : ${libc400ans:=y}
fi

if [ -d $2/include ] 
then
echo "Remove the $IDname Include Files (y/n) ? [y] \c"
read incans; : ${incans:=y}
fi

#
# Do the removing...
#

case $libc100ans in
y*|Y*)
    echo "\nRemoving $IDname C100 Libraries"
    rm -r libc100                               >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $libc400ans in
y*|Y*)
    echo "\nRemoving $IDname C400 Libraries"
    rm -r libc400                               >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $incans in
y*|Y*)
    echo "\nRemoving $IDname Include Files"
    rm -r include                               >/dev/null 2>&1
    ;;
*)
    ;;
esac

echo "$PRODUCT_FL -- $PRODUCT_ID operation complete.\n"
exit 0
