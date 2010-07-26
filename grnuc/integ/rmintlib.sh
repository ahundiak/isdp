# rmintlib.sh - Removes all intermediate libraries that are used to make the
#               executable.
#
#
#    Usage       : rmintlib.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: rmintlib.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:36  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/10/09  15:44:20  grnuc33
# COMMENT : Removed UNIT_TEST stuff
#
# Revision 330.0  1996/01/11  20:23:15  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:41  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:44:40  tim
# COMMENT : corrected Log keyword for RCS history
#


#verify that all environment variables used in this script are defined

verifyenv TARGETDIR PROD LOGFILE WORKDIR

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined"
  exit 1
fi

cd $TARGETDIR


echo 'Removing intermediate libraries'
echo 'Removing intermediate libraries' >> $LOGFILE

if [ "$PROD" = "MODEL" ]
then
  for file in `\ls src_lib/*.o`
  do
    nrm $file    # "nrm" verifies the remove
  done
fi

if [ "$PROD" = "GRNUC" ]
then
  for file in `\ls lib/*.o`
  do
    nrm $file      # "nrm" verifies the remove
  done
  for file in `\ls lib/libGR*.a`
  do
    nrm $file
  done
  for file in `\ls archlib/*.a`
  do
    nrm $file
  done
fi
