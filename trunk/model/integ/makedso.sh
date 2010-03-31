
######################################################################
#
# makedso.sh
#
# This script will take all of the .o files in the $MDTARG/src_lib,
# $MDTARG/ve/lib, and $MDTARG/hsurf/lib directories and create a 
# dynamically shared object (dso) named model.so which resides in 
# the $MDTARG/src_shlib directory and is symbolically linked to the 
# $INGRHOME/lib directory at installation.  This script also 
# generates a stub file which is linked into the image as fixes.so.
# This dso is a dummy so that the fixes product has a hook into the 
# linkable image.  This script will also make the necessary changes 
# to the modelmakelib and Makefile.
# 
#  jsd  11/01/93  Genesis
#  scw  11/16/93  Added fixes.so code
#  scw  12/08/93  Added code for making mdsp_proc.so
#  scw  12/20/93  When finished copy move so_locations file back
#                 to the $MDTARG/src_shlib directory.
#  scw  08/02/94  Upgraded to version 3.1
#  sam  08/31/94  Added PDUnsl.so
#  scw  12/22/94  Upgraded to version 3.2
#  pvr  07/31/95  Edit new Makefile and rm unnecessary lines
#  scw  04/17/96  Broke up the make arguments to work around Solaris 2.5 bug
#  scw  03/12/97  Reconfigured the libraries as in what goes into the 
#                 dynamic library and what get linked into the executable.
#  scw  11/14/97  Added Grnuc Target locator
#
######################################################################

#
# NOTE: ris.o moved from $MDTARG/src_lib/ris to $MDTARG/src_lib
#

if [ "$SGI" = "n" ]
then
  echo
  echo "This script is only (currently) valid on the SGI box."
  echo "          Have a nice day!"
  echo
  exit 255
fi


TMPFILE=/usr2/tmp/mdedrules

for DIRECT in ve/lib/sgi hsurf/lib/sgi
do
    DOTOLIST="$DOTOLIST `ls $MDTARG/$DIRECT/*.o`"
    DOTALIST="$DOTALIST `ls $MDTARG/$DIRECT/*.a`"
done

DOTOLIST="$DOTOLIST `ls $MDTARG/src_lib/sgi/E*.o`"
DOTOLIST="$DOTOLIST `ls $MDTARG/src_lib/sgi/r*.o`"

cd $MDTARG/src_lib/sgi

rm PWlib.o
ld -r -o PWlib.o $(ls PW*.o RF*.o)

cd $MDTARG/src_shlib

cp /usr2/ip32/grnuc34/shlib/so_locations .

echo Making $MDTARG/src_shlib/model.so
ld -shared -o model.so $DOTOLIST -all $DOTALIST

#
# create a useless stub file and use it to load fixes.so
#
cat <<- EOF >> $MDTARG/src_shlib/stupidstub.c

#include <stdio.h>

UselessStub()
{
  /*
   * This is a stub file used to generate an (somewhat) empty
   * fixes.so so that we can link fixes.so into the image.
   */
  printf( "This stub will never be hit\n" );
}
EOF

cat <<- EOF >> $MDTARG/src_shlib/PDUnslstub.c

#include <stdio.h>

UselessPDUnslStub()
{
  /*
   * This is a stub file used to generate an (somewhat) empty
   * fixes.so so that we can link fixes.so into the image.
   */
  printf( "This stub will never be hit\n" );
}
EOF

#
# compile and load our useless stub file
#
grmake -kr -f $MDTARG/src_surf/imp/makefile stupidstub.o
grmake -kr -f $MDTARG/src_surf/imp/makefile PDUnslstub.o
ld -shared -o fixes.so stupidstub.o
ld -shared -o PDUnsl.so PDUnslstub.o
rm stupidstub.[co]
rm PDUnslstub.[co]


#
# modify Makefile and modelmakelib
#

cd $MDTARG

#
# Create modelmakelib for the SGI
#
cat <<- EOF >> $MDTARG/modelmakelib
MODELLIBRARIES = \
    \$(MDTARG)/src_shlib/fixes.so \
    \$(MDTARG)/src_shlib/model.so \
    \$(MDTARG)/src_shlib/PDUnsl.so \
    \$(MDTARG)/src_lib/sgi/PWlib.o
EOF

cp $MODEL/Makefile .

cat <<- EOF >> $TMPFILE
/rismakelib
d
/vemakelib
d
/hsurfmakelib
d
/modelmakelib
d
i
include \$(MDTARG)/modelmakelib
.
/grnucmakelib
d
i
include \$(GRTARG)/grnucmakelib
.
/APP_PRE_ACTION
d
i
APP_PRE_ACTION = 
.
/APP_POST_ACTION
d
i
APP_POST_ACTION = 
.
/GRSTUBS
d
/libGRstub
d
/MODELLIBRARIES
d
d
d
w
q
EOF

ed Makefile < $TMPFILE

rm $TMPFILE

#
#  Temporary kludge until Exnuc stops changing between .o's and .so's
#
echo Making $MDTARG/config/dload/port/mdsp_proc.so
cd $MDTARG/config/dload/port
cp $MDTARG/src_shlib/so_locations $MDTARG/config/dload/port/
ld -shared -o mdsp_proc.so mdsp_proc.o

#
# Move the so_locations file back to the src_shlib directory
#
mv $MDTARG/config/dload/port/so_locations $MDTARG/src_shlib/
