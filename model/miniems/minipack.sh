
# This script updates the product definition file and README ( in that order )
# for the newly released product miniEMSsrc.

# This script also brings all the files relted to miniEMSsrc, a new product
# that can be downloaded by an UNIX user, to a single location.

# The Integrator is supposed run this script to get all the products to one
# location and package it onto ems130

# --- B.Harikrishna.

cd /usr2/tmp

# UPDATE THE PRODUCT DEFINITION FILE
upproduct.sh miniemssrc

# UPDATE README
upREADME.sh  miniemssrc

if [ -d /usr3/ip32/miniEMSsrc/bspmath ]
then
	echo
	echo "Removing BS related files"
	rm -rf /usr3/ip32/miniEMSsrc/bspmath
fi

echo
echo "Creating /usr3/ip32/miniEMSsrc/bspmath"
mkdir /usr3/ip32/miniEMSsrc/bspmath
if [ ! -d /usr3/ip32/miniEMSsrc/bspmath ]
then
	echo
	echo "Failed to create directory /usr3/ip32/miniEMSsrc/bspmath"
	exit
fi

if [ -d /usr3/ip32/miniEMSsrc/om ]
then
	echo
	echo "Removing OM related files"
	rm -rf /usr3/ip32/miniEMSsrc/om
fi

echo
echo "Creating /usr3/ip32/miniEMSsrc/om"
mkdir /usr3/ip32/miniEMSsrc/om
if [ ! -d /usr3/ip32/miniEMSsrc/om ]
then
	echo
	echo "Failed to create directory /usr3/ip32/miniEMSsrc/om"
	exit
fi

cp $MINIEMSTARG/miniEMS/OM*.C $MINIEMSSRC/miniEMS
cp $MINIEMS/*.m $MINIEMSSRC
cp $MINIEMS/list* $MINIEMSSRC

echo
echo Copying bspmath related files.

rcp -r grnuc34@grdev:/usr2/ip32/bspmathdp/include /usr3/ip32/miniEMSsrc/bspmath

echo
echo BS IS DONE

echo
echo Copying OM related files.

rcp S340exnuc@grdev:/usr4/exnuc34/src/makefile.nt /usr3/ip32/miniEMSsrc/om
rcp S340exnuc@grdev:/usr4/exnuc34/src/makefile /usr3/ip32/miniEMSsrc/om

rcp -r S340exnuc@grdev:/usr4/exnuc34/src/bin /usr3/ip32/miniEMSsrc/om
echo
echo rcp of bin is over

rcp -r S340exnuc@grdev:/usr4/exnuc34/src/build /usr3/ip32/miniEMSsrc/om
echo
echo rcp of build is over

rcp -r S340exnuc@grdev:/usr4/exnuc34/src/include /usr3/ip32/miniEMSsrc/om
echo
echo rcp of include is over

rcp -r S340exnuc@grdev:/usr4/exnuc34/src/om /usr3/ip32/miniEMSsrc/om
echo
echo rcp of om is over

rcp -r S340exnuc@grdev:/usr4/exnuc34/src/spec /usr3/ip32/miniEMSsrc/om
echo
echo rcp of spec is over

echo
echo OMSRC IS DONE

rootsetuid /etc/mount -f NFS ems130:/usr5/v34/ws_priv/miniEMSsrc /usr3/ip32/ems130

echo
echo "Removing miniEMSsrc.cpio from ems130"
rm /usr3/ip32/ems130/miniems.cpio
if [ -f /usr3/ip32/ems130/miniems.cpio ]
then
	echo
	echo "Failed to remove the cpio from ems130"
fi
	
cd /usr3/ip32/miniEMSsrc

find ./om ./miniems ./bspmath -print|cpio -ocv | compress > /usr3/ip32/ems130/miniems.cpio

rootsetuid /etc/umount /usr3/ip32/ems130
