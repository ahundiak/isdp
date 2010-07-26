#	Script to make a log file.
if [ -n "$LOGFILE" ]
then
 echo $LOGFILE
 echo "(set -e;date; time $*) 2>&1 | tee -a $LOGFILE\n" | tee -a $LOGFILE
 (set -e;date; time $*) 2>&1 | tee -a $LOGFILE
else
 echo LOGFILE is empty.
 echo "(set -e;date; time $*) 2>&1\n"
 (set -e;date; time $*) 2>&1
fi
