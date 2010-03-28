# rmmake.sh - Removes all makefiles
#
#
#    Usage       : rmmake.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: rmmake.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:38  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:23:16  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:42  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:44:45  tim
# COMMENT : corrected Log keyword for RCS history
#


#verify that all environment variables used in this script are defined

verifyenv TARGETDIR PROD LOGFILE

# we remove a makefile in the make makefiles unit test
if [ "$UNIT_TEST" = "on" ]
 then
   echo "no unit test for this module, removing makefile in a later test"
   exit 0
fi

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined"
  exit 1
fi

echo "Removing all makefiles"
echo "Removing all makefiles" >> $LOGFILE

cd $TARGETDIR 

#
# Remove MODEL makefiles
# ----------------------
#

if [ $PROD = MODEL ]
then
  find . -name 'makefile' -print > /tmp/mkfilelst.$$
  find . -name 'makefile.m' -print >> /tmp/mkfilelst.$$
  for file in `cat /tmp/mkfilelst.$$`
   do 
    nrm $file
  done
fi

#
# Remove GRNUC makefiles
# ----------------------
#

if [ $PROD = GRNUC ]
then
  find . -name 'makeimp' -print > /tmp/mkfilelst.$$
  find . -name 'makespec' -print >> /tmp/mkfilelst.$$
  for file in `cat /tmp/mkfilelst.$$`
   do
    nrm $file
  done
fi

rm /tmp/mkfilelst.$$
