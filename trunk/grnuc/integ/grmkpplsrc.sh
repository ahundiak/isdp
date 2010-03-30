# grmkpplsrc.sh - Makes the ppl source
#                 NOTE: This uses a separate build script to do the compiles.
#
#
#    Usage       : grmkpplsrc.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkpplsrc.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:52  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/10/09  15:44:19  grnuc33
# COMMENT : Removed UNIT_TEST stuff
#
# Revision 330.0  1996/01/11  20:22:33  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:59  root
# *** empty log message ***
#
# Revision 240.2  1993/05/05  19:56:11  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC TBLDLOG ERRNOTI MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

cd $GRNUC/src/pplsrc
necho "\n------------------$UNIT_MESS src/pplsrc ---------------------\n"
make.sh > /tmp/$TBLDLOG 2>&1
# make.sh
ncat /tmp/$TBLDLOG

# For some reason always seem to get error banner
#if [ "$ERRNOTI" = "on" ]
#then
#  make.sh > /tmp/$TBLDLOG 2>&1
#  errchk /tmp/$TBLDLOG src/pplsrc
#fi

echo /tmp/$TBLDLOG
