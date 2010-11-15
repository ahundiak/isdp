# Do not alter this SPC information: $Revision: 1.1.59.1 $
#
# Script that extracts prototypes from intrface/prt and
# generates include/ris.prt file to be used by RIS applications.
#

PLATFORM=`uname -s`

#
#	Set up system calls
#
DIFF=/bin/diff
MV=/bin/mv
RM=/bin/rm
CP=/bin/cp
if [ $PLATFORM="CLIX" ]
then
	LS=/bin/ls
	GREP=/bin/grep
elif [ $PLATFORM="SunOS" ]
then
	LS=/usr/5bin/ls
	GREP=/usr/5bin/grep
fi

#
##	FUNCTIONS
#

#
#	mv file1 to file2 only if they are different
function mv_if_diff
{
	$DIFF -b $1 $2 >/dev/null 2>&1
	if [ $? != 0 ]
	then
		print "\n\tGenerating new $2 ..."
		$MV $1 $2
	else
		$RM $1
	fi
}

#
#	cp file1 to file2 only if they are different
function cp_if_diff
{
	$DIFF -b $1 $2 >/dev/null 2>&1
	if [ $? != 0 ]
	then
		print "\n\tGenerating new $2 ..."
		$CP $1 $2
	fi
}

#
##	Main routine
#

typeset -x DIR=$RISDEVDIR/risapp/dload/prt
typeset -x TEMPOUTFILE1=/usr/tmp/hrp1.prt 

# 	Write include files
print "#include \"rislimit.h\"" > $TEMPOUTFILE1
print "#include \"ris.h\"" >> $TEMPOUTFILE1
cat $DIR/dldint.prt >> $TEMPOUTFILE1

#	mv if different external prt file
mv_if_diff $TEMPOUTFILE1 $RISDEVDIR/risapp/include/ris.prt

#	cp if different rap prt file
mv_if_diff $DIR/dldrap.prt $RISDEVDIR/risapp/include/rap.prt

print ""
