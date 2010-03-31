
#
# gen_string.sh - make application command definition files using
#                 literal strings
#
#    Usage  : gen_string.sh $application_name
#    Inputs : application name (eg. emsppp)
#    Output : error messages
#    Return : none
#      Code
#


verifyenv MDTARG MODEL GRNUC EXNUC

if [ "$CLIPPER" = "y" ]
then

  MD_MESS=$MODEL/config/english/messages/src
  GR_MESS=$GRNUC/config/english/messages/src
  EX_MESS=$EXNUC/config/english/messages/src

  USAGE="Usage: $0 product_name
       eg.  $0 emsppp\n"

  if [ $# -eq 0 ]
  then
    echo
    echo "$USAGE"
    exit
  fi


  CMD_FILE=$MDTARG/$1/config/$1.cmd
  STR_FILE=$MODEL/$1/config/$1.str

  rm $STR_FILE

  grep -v \" $CMD_FILE |

  while read COMMAND
  do
    CMD_KEY=$(echo $COMMAND | cut -d"," -f1)
    CMD_STR=$(echo $(egrep "$CMD_KEY[ 	,]" $MD_MESS/*.mb $GR_MESS/*.mb \
              $EX_MESS/*.mb) | cut -d":" -f2- | cut -d" " -f2-)

    CMD_KEY=$(echo $CMD_KEY | sed "s@\^@@g")

    echo $COMMAND | sed "s@$CMD_KEY@\"$CMD_STR\"@g" >>$STR_FILE
  done 

fi
