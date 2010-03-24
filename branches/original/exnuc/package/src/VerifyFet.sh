# Joe Wagner 7-Sep-1990 Revised: 09-Apr-1991
# This script verifies the files and directories
# HISTORY:
#   05-Sep-91  jww  Written.
#INPUTS:
# A list of file names with relative paths & SCCS id number in the form:
#  $DIR/$FILE    $SID
# Example:
#  config/english/forms/new.form	2.1.2.1
#
#set -x
#alias -x sfetch="echo sfetch"
#set -- `getopt k: $@` || { echo $USAGE; exit 1; }
# Set response to the full version with "."
  response=$LOGVSTR.$BLDNUMB
# Process the Version to remove the "."
  echo $response>${TMPDIR}/VERS.tmp
  VERS=$(awk '{FS=".";print $1$2$3$4}' ${TMPDIR}/VERS.tmp)
  rm -f ${TMPDIR}/VERS.tmp
# Set the logfile name.
  VERIFYLOG="$BLD/fetch${VERS}.ver"
# Check for existance of log file, if not there make it.
if [ ! -a ${VERIFYLOG} ]
then
      > $VERIFYLOG
fi
IFS="	"
cd $REL
while read FSPEC SID
do
	DIR=$(dirname $FSPEC)
	FILE=$(basename $FSPEC)
	if [ ! -d $DIR ]
	then
		echo "ERROR: $DIR directory does not exsist." | tee -a ${VERIFYLOG}
	else
		if [ ! -f $FSPEC ]
		then
			echo "ERROR: $FILE file does not exsist." | tee -a ${VERIFYLOG}
		else
			ls -lst $FSPEC | tee -a ${VERIFYLOG}
		fi
	fi

done
cd -
echo " File Verify Complete on $(date)\n" | tee -a ${VERIFYLOG}
echo " Verify information saved in ${VERIFYLOG}\n"
