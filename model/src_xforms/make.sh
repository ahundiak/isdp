
###############################################################################
#
# This routine will build all appropriate FORMS patches into the MODEL
#   product until the time which a new FORMS is built including these
#   changes.  Builds both I_FORMS and XFORMS patches.
#   XFORMS patch source resides in $MODEL/src_xforms
#   I_FORMS patch source resides in $MODEL/src_iforms
#
# HISTORY:
#    SCW  03/12/97  Genesis
#
###############################################################################


necho "----------------- building src_xforms ---------------------"

START_POINT=$PWD

if [ "$SUN5" = "y" -o "$SUNZX" = "y" -o "$ISL" = "y" ]
then
  export COMPILER="$COMPILER -K PIC"
  export LDOPT="-z text -G"
fi

if [ "$SGI" = "y" ]
then
  export COMPILER="$COMPILER -common"
  export LDOPT="-shared"
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]         # I_FORMS
then
  cd $MODEL/src_iforms
  grmakemake spec.m $MDTARG/src_iforms/makefile
  cd $MDTARG/src_iforms/
  grmake -kr -f makefile
  cp *.o $MDTARG/config/dload/patch/
else                                             # X_FORMS
  cd $MODEL/src_xforms
  grmakemake spec.m $MDTARG/src_xforms/makefile
  cd $MDTARG/src_xforms/
  grmake -kr -f makefile

  ld $LDOPT -o xforms.so *.o
  necho ld $LDOPT -o xforms.so *.o
  ncp xforms.so $MDTARG/config/dload/patch/
fi

cd $START_POINT

