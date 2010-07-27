#
#	Script to get the build number.  Should be dotted into the
#	environment.
#
PV=$(echo $PRODUCT_VERSION | cut -c1-8)
export BLDNUMB=00
if test -f $EXNUC/build/exnucbuild
then
	BLDNUMB=`cat $EXNUC/build/exnucbuild`
fi
echo
echo "Enter the 2 character Build NUMBER $PV.[$BLDNUMB] : \c"
read TMP
if test -n "$TMP"
then
	BLDNUMB=$TMP
	echo $BLDNUMB >$EXNUC/build/exnucbuild
fi
