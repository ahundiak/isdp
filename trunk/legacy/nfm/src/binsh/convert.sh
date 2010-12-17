PLTWRKDIR=/usr/dmpltwrk
FILE=`/usr/dmpltwrap/tolower $1`
/bin/rm $PLTWRKDIR/$FILE.cit $PLTWRKDIR/$1.cit
qpr -t script -q dmtg4 /usr/tmp/$FILE.ps -d PLT_FILE=$FILE
if [ $? != 0 ]
then
	echo qpr error $?
	exit
fi
while ( test ! -r $PLTWRKDIR/$FILE.cit )
do
	sleep 3
done
/bin/mv $PLTWRKDIR/$FILE.cit $PLTWRKDIR/$1.cit
	
