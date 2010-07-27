#	Script for making EXNUC.
cd $EXNUC

BUILD_LIST="intel5 EXNUC"

export BUILD=i5EXNUC

# OS = SunOS

build/exnuc_make_dirs.sh

make -e

exit 0
if [ "$OS" = "SunOS" ]
then
  cd $EXTARG/lib
  rm $EXTARG/lib/libfpstub.so
  make -f $EXTARG/lib/fpstub.mk
  cp $EXNUC/lib/link_stub.c $EXNUC/lib/fp_stub.c $EXTARG/lib/
fi

###############################################################################

echo "\nSUCCESS"
echo "Finished on `date`\n"
