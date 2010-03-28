#
# This script will set up for the remote call to Ingrcert to flip the
# status of a list of TRs/CRs from 1H to 1I
#
# You must have all the TRs/CRs in a file before calling this script
#
# 3 Arguments for this script can be as follows
#	xx.xx.xx.xx	Version num
#	t or c		for TR or CR 
#	xxxx		QA id
# If no arguments are given this can run interactively but you shd have
# a file with list of tr/cr nums like TR 119412344

if [ "$1" = "" ]
then
  TMPVERS=
  while [ "$TMPVERS" = "" ]
  do
    if [ -f $WORKDIR/versinfo ]
    then
      TMPVERS2=$(cat $WORKDIR/versinfo)
      read -r TMPVERS?"Enter version number with fix > 03.04.00.$TMPVERS2"
      if [ "$TMPVERS" = "" ]
      then
        TMPVERS=$TMPVERS2
      else
        if [ "$TMPVERS" -lt "10" ]
        then
          TMPVERS=0$TMPVERS
          TMPVERS=$(echo $TMPVERS | tr -s "00" "0")
        fi
      fi
    else
      read -r TMPVERS?"Enter version number with fix > 03.04.00."
    fi
  done
  VERS="03.04.00.$TMPVERS"
else
  VERS=$1
fi

if [ ! -f $HOME/Mail/fixes340.$TMPVERS ]
then
  echo "\nThere are no TRs/CRs to flip from 1H to 1I for $VERS\n"
  read -r TRCRLIST?"Enter file name of tr/cr list > "
  mv $TRCRLIST ./.trcrlis
else
  read TRCRLIST?"Enter file name of tr/cr list or take the default > "
  if [ "$TRCRLIST" = "" ]
  then
    getfixfields REFERENCE $HOME/Mail/fixes340.$TMPVERS | grep 119 > ./.trcrlis
  else
    mv $TRCRLIST ./.trcrlis
  fi
fi

$EDITOR ./.trcrlis
rcp ./.trcrlis emsr@mdb:./integ/.trcrlis

if [ "$2" = "" ]
then
  read -r TRCR?"Enter TR(t) or CR(c) flag > [t] "
  if [ "$TRCR" = "c" ]
  then
    TRCR=c
  else
    TRCR=t
  fi
else
  TRCR=$2
fi

if [ "$3" = "" ]
then
  read -r QAID?"Enter QA analyst id number > [-219] "
  if [ "$QAID" = "" ]
  then
    QAID=-219
  fi
else
  QAID=$3
fi

#rcmd mdb -l emsr "./integ/flip1H1I.sh $TRCR $QAID $VERS"
rcmd mdb -l emsr "cd ./integ ; ./flip1H1I.sh $TRCR $QAID $VERS"

