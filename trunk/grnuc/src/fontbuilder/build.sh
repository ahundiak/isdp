#$Log: build.sh,v $
#Revision 1.1.1.1  2001/12/17 22:39:12  hans
#Initial import to CVS
#
# Revision 340.1  1997/07/17  15:38:15  grnuc34
# COMMENT : Modified to conform to the new integration configuration
#
# Revision 340.0  1997/05/27  23:14:56  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

# Set up environment
BSP=$BS
export FTBFLAGS=STUPID

# Make all subparts of FTB

#  FTBconverter
echo "--------------- making fconv ---------------\n"
cd $GRTARG/src/fontbuilder/fconv
$GRNUC/src/fontbuilder/fconv/make.sh

#  FTButil
echo "--------------- making ftbutil ---------------\n"
cd $GRTARG/src/fontbuilder/ftbutil
if [ ! -s makefile ]
then
    cd $GRNUC/src/fontbuilder/ftbutil
    $EXTARG/bin/makemake ${MKMKOPT} *.m $GRTARG/src/fontbuilder/ftbutil/makefile
fi
cd $GRTARG/src/fontbuilder/ftbutil
make -rk CC=${COMPILER} COPT="${COMPOPT}" DOPT1="${MKDOPT}"

#  FTBFlib
echo "--------------- making flib ---------------\n"
cd $GRNUC/src/fontbuilder/flib

if [ "$ISL" = "y" ]
then
  cp $GRNUC/src/fontbuilder/flib/Makefile.isl $GRTARG/src/fontbuilder/flib/Makefile
fi

if [ "$SUN5" = "y" ]
then
  cp $GRNUC/src/fontbuilder/flib/Makefile.sol $GRTARG/src/fontbuilder/flib/Makefile
fi

if [ "$SGI" = "y" ]
then
  cp $GRNUC/src/fontbuilder/flib/Makefile.sgi $GRTARG/src/fontbuilder/flib/Makefile
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  $EXTARG/bin/makemake ${MKMKOPT} *.m $GRTARG/src/fontbuilder/flib/makefile
fi

cd $GRTARG/src/fontbuilder/flib
make -rk CC=${COMPILER} COPT="${COMPOPT}" DOPT1="${MKDOPT}"

#  FTBppl
echo "--------------- making FTB ppl ---------------\n"
cd $GRTARG/src/fontbuilder/ppl/cisrc
for file in $GRLIB/src/fontbuilder/ppl/cisrc/GRCr*.u
do
  $GRNUC/src/fontbuilder/ppl/cisrc/make.ci $file
done

# Copy executables
echo "\nCopy FTB executables to $GRTARG/bin\n"
cp $GRTARG/src/fontbuilder/bin/* $GRTARG/bin 
