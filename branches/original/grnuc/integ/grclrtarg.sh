# grclrtarg.sh - Prepares TARGETDIR for a total recompile by
#                1) making a snapshot of TARGETDIR before the build begins
#                2) find the directories in TARGETDIR
#                2) removing *everything* from TARGETDIR
#                3) verify that TARGETDIR is empty
#                4) rebuild the directories in TARGETDIR
#                5) compare TARGETDIR directories with step 2
#                NOTE : This is ENABLE_RECOMPIE=on specific.
#                NOTE : Failure at any step will exit this script and should
#                       exit the build.
#
#
#    Usage       : grclrtarg.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grclrtarg.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:40  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:21  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:48  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/03/29  19:46:04  grnuc20
# COMMENT : Changing the find statements to properly find everything (default instead of using "*") - JSD
#
# Revision 220.4  1993/03/11  15:27:38  grnuc20
# COMMENT : Embellished the output for grclrtarg.sh and grvertarg.sh and sorted the differences between the builds to make the differences more easily noticable - JSD
#
# Revision 220.3  1993/03/10  14:12:33  grnuc20
# COMMENT : Fix that will stop the build if grclrtarg.sh fails when called from deliver20 - JSD
#
# Revision 220.2  1993/03/01  20:36:21  grnuc20
# COMMENT : The TARGETDIR is already in the list of directories to remake - JSD
#
# Revision 220.1  1993/02/27  01:46:29  model22
# COMMENT : fix problem of not removing targetdir if started in same directory
#


# verify that all environment variables used in this script are defined.

verifyenv TBLDLOG MASBLDLOG TARGETDIR LOGNAME
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

#   Make a snapshot of TARGETDIR before starting the recompile

if [ -f /usr2/tmp/$LOGNAME.bef ]
then
  nrm /usr2/tmp/$LOGNAME.bef
fi
find $TARGETDIR -print > /usr2/tmp/$LOGNAME.bef
nls /usr2/tmp/$LOGNAME.bef
if [ $? != 0 ]
then
  errrpt $0 "Could not make snapshot of $TARGETDIR in /usr2/tmp/$LOGNAME.bef"
  exit 1
fi

# Get a list of all the directories in TARGETDIR

if [ -f /usr2/tmp/$LOGNAME.dir1 ]
then
  nrm /usr2/tmp/$LOGNAME.dir1
fi
find $TARGETDIR -type d -print > /usr2/tmp/$LOGNAME.dir1
nls /usr2/tmp/$LOGNAME.dir1
if [ $? != 0 ]
then
  errrpt $0 "Could not list $TARGETDIR directories in /usr2/tmp/$LOGNAME.dir1"
  exit 1
fi

# Save a copy of lastpackage

mv $TARGETDIR/lastpackage /usr2/tmp/lastpackage

# Clear the TARGETDIR
 
cd $TARGETDIR/..
echo "Removing everything from $TARGETDIR"
rm -r $TARGETDIR

# Verify that TARGETDIR is EMPTY

ls $TARGETDIR >/dev/null 2>&1
if [ $? = 0 ]
then
  errrpt $0 "$TARGETDIR is NOT empty after clearing it"
  exit 1
else
  echo "\nSuccessfully cleared $TARGETDIR\n"
fi

echo "Rebuilding the directory structure for $TARGETDIR"
# Rebuild the directory structure from the old TARGETDIR
for file in `cat /usr2/tmp/$LOGNAME.dir1`
do
  mkdir $file
  if [ $? != 0 ]
  then
    errrpt $0 "Could not recreating TARGETDIR after clearing it"
    exit 1
  fi
done

# Get a list of all the directories in TARGETDIR

if [ -f /usr2/tmp/$LOGNAME.dir2 ]
then
  nrm /usr2/tmp/$LOGNAME.dir2
fi
find $TARGETDIR -type d -print > /usr2/tmp/$LOGNAME.dir2
nls /usr2/tmp/$LOGNAME.dir2
if [ $? != 0 ]
then
  errrpt $0 "Could not list $TARGETDIR directories in /usr2/tmp/$LOGNAME.dir2"
  exit 1
fi

# Verify that the directory structure of TARGETDIR is valid

diff /usr2/tmp/$LOGNAME.dir1 /usr2/tmp/$LOGNAME.dir2 >/dev/null 2>&1
if [ $? != 0 ]
then
  errrpt $0 "$TARGETDIR directory structure is not valid"
  ls -lst /usr2/tmp/$LOGNAME.dir1 /usr2/tmp/$LOGNAME.dir2
  exit 1
else
  echo "\nSuccessfully rebuilt the directories in $TARGETDIR\n"
fi

# Restore the saved copy of lastpackage

mv /usr2/tmp/lastpackage $TARGETDIR/lastpackage
