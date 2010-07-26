# prefix.sh - This script does the following
#
#	puts integrator into elm to save the fixes forms to pending
#	gathers list of FILES from fixes forms in pending
#	puts integrator into editor to modify file list
#	splits out fixes when higher trunk numbers exist
#	gathers and pages SPECIFIC DIRECTIONS from fixes forms in pending
#	gathers and deletes DELETED FILES from fixes forms
#	fetches files with option for specifying version numbers
#
#    Usage  : prefix.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: prefix.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:31  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:23:09  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:36  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.6  1993/09/06  17:23:15  scott
# COMMENT : Added check to remake makefiles if spec.m has changed
#
# Revision 240.5  1993/06/22  14:32:27  grnuc20
# COMMENT : report number of files fetched to the buildlog
#
# Revision 240.4  1993/06/07  15:35:19  tim
# COMMENT : could not create grfllst since we moved grnuc and model integration platforms to the same machine
#
# Revision 240.3  1993/04/12  19:34:37  tim
# COMMENT : incorporating release 2.2.0 fix - added -f to mv  to /usr/tmp
#
# Revision 220.4  1993/04/01  19:18:58  model22
# COMMENT : fixed a bug where  was being checked instead of  for del files
#
# Revision 220.3  1993/03/29  21:06:57  dodd
# COMMENT : Changing to use mailless fixes forms (allfixforms) - JSD
#
# Revision 220.2  1993/02/19  18:34:56  grnuc20
# COMMENT : Fixing an nrm to occur only if the file exists
#
# Revision 220.1  1993/02/16  15:32:55  model22
# COMMENT : fixing problems in integration scripts due to modulizing them
#
# Revision 220.0  1993/02/14  15:19:59  tim
# COMMENT : report newfiles fetched/establish file to note the ownership of files in WORKDIR
#
#

verifyenv WORKDIR SUN

PENDING=$HOME/Mail/pending
FETCH=$HOME/Mail/fetch
CDATE=`date '+%M %D'`
ANS=n

if [ $# != 1 ]
then
 necho "usage : prefix.sh product_path"
 exit 9
else
 WORKDIR=$1
fi

cd $WORKDIR

# rm ${WORKDIR}/I_notifiles > /dev/null 2>&1
nrm ${WORKDIR}/filesandvers 
nrm ${WORKDIR}/files2fetch 

if [ "$CLIPPER" = "y" ]
 then
  elm -f $HOME/allfixforms
fi

necho "Getting filenames - Please delete any lines that are not filenames"
getfixfields FILES $FETCH | sort -u | awk '
  BEGIN  { lastone = "" 
           lastrec = "" }
         { if ($1 != lastone && lastrec != "") print lastrec }
         { lastone = $1 }
         { lastrec = $0 }
  END    { print lastrec }' > ${WORKDIR}/allfiles
memacs ${WORKDIR}/allfiles
ncp allfiles filesandvers

necho "Getting specific directions"
getfixfields -t FILES SPECIFIC $FETCH > ${WORKDIR}/specific
pg ${WORKDIR}/specific
necho "Getting deleted files"
getfixfields DELETED $FETCH | sort -u > ${WORKDIR}/delfiles
# Determine if model needs to run checkspec_all.sh due to new files added to a
# directory.
   getfixfields FILES $FETCH | grep $REVISION.0  > /tmp/newfiles.$$
   if [ -s /tmp/newfiles.$$ ]
    then
     cat /tmp/newfiles.$$ >> $WORKDIR/NEWFILES
     rm /tmp/newfiles.$$
     if [ "$PROD" = "MODEL" ]
      then
        echo > $WORKDIR/newdelfiles
        necho ""
        necho "MODEL will run checkspec_all.sh since new files were fetched"
     fi
   fi

# Determine if model needs to run checkspec_all.sh because of changes to spec.m
# files.
   getfixfields FILES $FETCH | grep spec.m  > /tmp/specfiles.$$
   if [ -s /tmp/specfiles.$$ ]
    then
     rm /tmp/specfiles.$$
     if [ "$PROD" = "MODEL" ]
      then
        echo > $WORKDIR/newdelfiles
        necho ""
        necho "MODEL will run checkspec_all.sh since spec.m files were changed"
     fi
   fi

# Determine if model needs to run checkspec_all.sh due to files being deleted
# from a directory.
if [ -s ${WORKDIR}/delfiles ]
then
   cat ${WORKDIR}/delfiles
   echo "Delete the following files from the integration platform <y/n> [n]\b\b\c"
   read DANS; : ${DANS:=n}
   if [ $DANS = y ] 
    then
     necho "Deleting requested files from clipper integration platform"
     for file in `cat ${WORKDIR}/delfiles`
     do 
        necho ${WORKDIR}/${file}
        nrm  ${WORKDIR}/${file}
     done
   fi
   if [ "$PROD" = "MODEL" ]
    then
      echo > $WORKDIR/newdelfiles
      necho ""
      necho "MODEL will run checkspec_all.sh since files were deleted"
   fi
else
   necho "No files to delete"
fi

awk '{ print $1 }' ${WORKDIR}/filesandvers > ${WORKDIR}/filenames

#echo "Fetch by version number? <y/n> [n]\b\b\c"
#read ANS; : ${ANS:=n}
ANS=n

if [ $ANS = y ]
then
   ncp ${WORKDIR}/filesandvers ${WORKDIR}/files2fetch
   fetchsrc -v -f ${WORKDIR}/files2fetch
else
   ncp ${WORKDIR}/filenames ${WORKDIR}/files2fetch
   fetchsrc -f ${WORKDIR}/files2fetch
fi
necho "\n\nVerify fetch"
if [ -f /tmp/grfllst.$$ ]
then
  nrm /tmp/grfllst.$$
fi
for file in `cat ${WORKDIR}/filenames`
do
   ls -al $file >> /tmp/grfllst.$$
done
echo
echo "NUMBER OF FILES FETCHED = \c"
wc -l /tmp/grfllst.$$ | tr -s " " | cut -d' ' -f2
rm /tmp/grfllst.$$

cat $FETCH >> $PENDING
mv -f $FETCH /usr/tmp
