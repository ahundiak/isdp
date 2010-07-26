# grmkfntbld.sh - Makes the fontbuilder source
#                 NOTE: This is CLIPPER and SUN specific.
#                 NOTE: This uses a separate build script to do the compiles.
#
#
#    Usage       : grmkfntbld.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkfntbld.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:48  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:29  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:55  root
# *** empty log message ***
#
# Revision 240.3  1993/05/05  19:56:18  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC TBLDLOG MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

if [ "$UNIT_TEST" = "on" ]
then
  if [ ! -x $GRNUC/src/fontbuilder/build.sh ]
  then
    errrpt $0 "$GRNUC/src/fontbuilder/build.sh is not executable" >> /usr2/tmp/$MASBLDLOG
  else
    necho "$GRNUC/src/fontbuilder/build.sh is executable"
  fi
else
  necho "\n----------------$UNIT_MESS src/fontbuilder -------------------\n"
  $GRNUC/src/fontbuilder/build.sh  > /tmp/$TBLDLOG 2>&1
  ncat /tmp/$TBLDLOG 
fi
