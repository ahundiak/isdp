# Joe Wagner 7-Sep-1990 Revised: 04-Jun-1992
# This script logs the comparison and move of files from the fetched
# area ($TMPDIR) to the Source area.  The log file is created based
# on the version of the build. (example: ~/BldHx/fetch20015.log)
# HISTORY:
#   25-Jan-91  jww  Added a check for file type of data, then dont do
#                   a diff of a binary file.
#   07-Feb-91  jww  Added code to check and set the version.
#   09-Apr-91  jww  Changed "/usr/tmp" to ${TMPDIR}.
#   03-Sep-91  jww  Combined (chk.sh,fetch.sh & batFet.sh).
#   16-Apr-92  jww  Fixed to use spc
#   01-May-92  jww  Fixed the set library to only change when needed.
#   12-May-92  jww  Fixed the product specific references
#   27-May-92  jww  Made the spc commands generic
#   04-Jun-92  jww  Added PRODUCT_VERSION to fetch comment & 
#
# The following line should already be executed before running this script
#sopen exnuc . -ver $LOGVSTR -emp 1054
#	Script to do batch fetches.
#
#INPUTS:
# A list of file names with relative paths & SCCS id number in the form:
#  $DIR/$FILE	$SID
# Example:
#  config/english/forms/new.form	2.1.2.1
#
#set -x

# Set response to the full version with "."
  response=$LOGVSTR.$BLDNUMB
# Process the Version to remove the "."
  echo $response>${TMPDIR}/VERS.tmp
  VERS=$(awk '{FS=".";print $1$2$3$4}' ${TMPDIR}/VERS.tmp)
  rm -f ${TMPDIR}/VERS.tmp
# Set the logfile name.
  FETCHLOG="$BLD/fetch${VERS}.log"
#echo "FETCHLOG = $FETCHLOG"

# Check for existance of log file, if not there make it.
if [ ! -a ${FETCHLOG} ]
then
      > $FETCHLOG
fi
# Insure that the spc is set to the proper location
spc set project $(echo $PRODUCT_NAME | tr "[A-Z]" "[a-z]") | tee -a ${FETCHLOG}
#spc set working set $(echo $PRODUCT_VERSION | cut -c1-8) | tee -a ${FETCHLOG}
spc set library . | tee -a ${FETCHLOG}
#spc show default | tee -a ${FETCHLOG}

#set -x
LASTDIR=
#echo "LASTDIR = $LASTDIR"
# For 2.0.1 use :
#IFS=":"
# For 2.1.0 use TAB
IFS="	"
while read FSPEC SID
do
	DIR=$(dirname $FSPEC)
	FILE=$(basename $FSPEC)
	echo "File: $FILE\tSID: $SID" | tee -a ${FETCHLOG}
	cd $DIR
	if [ "$LASTDIR" != "$DIR" ]
	then
	#echo "LASTDIR = $LASTDIR"
	#echo "DIR = $DIR"
	   spc set library . | tee -a ${FETCHLOG}
	   spc set library $DIR | tee -a ${FETCHLOG}
	   LASTDIR=$DIR
	fi
	cd $TMPDIR
	spc fetch -touch $FILE -revision $SID -com "fetch for $PRODUCT_VERSION build" | tee -a ${FETCHLOG}
	cd -
	ls -lst $FILE ${TMPDIR}/$FILE | tee -a ${FETCHLOG}
	rm -f ${TMPDIR}/FILE_TYPE.tmp
	echo "Move ${TMPDIR}/$FILE to $PWD\n" | tee -a ${FETCHLOG}
	mv ${TMPDIR}/$FILE .
	cd $REL
done

spc set library /usr2/spc/$(echo $PRODUCT_NAME | tr "[A-Z]" "[a-z]")

echo " File Moving Complete on $(date)\n" | tee -a ${FETCHLOG}
echo " Fetch information saved in ${FETCHLOG}\n"
