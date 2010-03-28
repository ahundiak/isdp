# rmdote.sh - Removes all PPL ".e" files before compilation
#
#
#    Usage       : rmdote.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: rmdote.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:35  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/10/09  15:44:21  grnuc33
# COMMENT : Removed UNIT_TEST stuff
#
# Revision 330.0  1996/01/11  20:23:13  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:40  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:44:43  tim
# COMMENT : corrected Log keyword for RCS history
#


# verify that all environment variables used in this script are defined

verifyenv LOGFILE TARGETDIR WORKDIR

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined"
  exit 1
fi

echo 'Removing ppl .e files'

echo 'Removing ppl .e files' >> $LOGFILE

cd $TARGETDIR

find . -name '*.e' -print > /tmp/dote.$$

for file in `cat /tmp/dote.$$`
do 
  if [ "$UNIT_TEST" = "on" ]
   then 
    mv $file old.`basename $file`
    cp old.`basename $file` $file
  fi
  nrm $file  # "nrm" verifies the removal of files
  if [ "$UNIT_TEST" = "on" ]
   then 
    mv old.`basename $file` $file 
  fi
done
rm /tmp/dote.$$



