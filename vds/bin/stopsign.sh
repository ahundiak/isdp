#! /bin/ksh

###############################################################################
# The PPL cmd: "ci=stopsign" executes the following script, in order to 
# generate a new stopsign process (in case the original one seems to have
# stopped responding).
###############################################################################

OS=`uname -s`
MODELID=`ps -a | grep Model | awk '{print $1}'`
# echo "MODELID = "$MODELID

GRNUC=`echopath GRNUC`
GRSYM=$GRNUC/config/english/icons/GRfrm.sym

COLOR=""
if [ "$OS" == SunOS ]
then
    COLOR=`ps -ef| grep "bin\/stopsign " | awk '{ print  $10 }' `
    COLOR=`echo $COLOR | awk '{ print  $1 }' `
fi

###############################################################################
# Find ALL stopsign processes & kill them (except the one started from "drive")
###############################################################################

TMP_FILE=tmp$RANDOM.tmp
ps -ef | grep "bin\/stopsign "|sort -n -r +3 -2  > $TMP_FILE

while ` read -r DUM1 STOP_ID PARENT_ID LEFTOVERS `
do

#    echo "PARENT_ID = $PARENT_ID"
#    exit

    if [ "$PARENT_ID" == 1 ]
    then
#	echo $STOP_ID

	if [ "$STOP_ID" != "" ]
	then
	    kill -9 $STOP_ID
	    echo "Killed stopsign pid=$STOP_ID"
	fi
    fi
done < $TMP_FILE 

rm $TMP_FILE

# echo "COLOR = "$COLOR
# echo "GRSYM = "$GRSYM

###############################################################################
# Now start a new stopsign process, but only if "$MODEL/bin/Model" is active
###############################################################################

if [ "$MODELID" = "" ]
then
    exit
fi

if [ "$COLOR" == "" ]
then
    STOP="$GRNUC/bin/stopsign $MODELID $GRSYM"
else
    STOP="$GRNUC/bin/stopsign -c $COLOR $MODELID $GRSYM"
fi

# echo $STOP

$STOP &