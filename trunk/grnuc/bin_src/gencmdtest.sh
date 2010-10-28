# 
# Name
#   gentest.sh
# 
# Usage
#   [ PLATFORM=<application directory> ] gentest.sh [-s] > testcmds.u
#   Option:  -s include calls to commands using the command name
# 
# Notes
#   Default PLATFORM is $MDS for historical reasons
# 
CALL_CMDS_BY_NAME=""
PLATFORM=${PLATFORM:-$MDS}
if [ ! -d "$PLATFORM/config" ] 
then
  echo "$0: $PLATFORM/config does not exist"  >&2
  exit 2
fi


while getopts s opt 2>/dev/null
do
  case $opt in

    s) CALL_CMDS_BY_NAME=yes ;;

  esac
done
shift `expr $OPTIND - 1`

cd $PLATFORM/config
CMD_LIST=$(ls *.cdef)

if [ ! -f "$CMD_LIST" ]
then
  echo "$0:  command definition file ($CMD_LIST) not found in $(pwd)" >&2
  exit 2
fi

echo '#include "ciminimum.h"'
echo '#include "cievent.h"'
echo
echo "main()"
echo "{"
echo

( while read CMD
  do
    if [ -n "$CMD" ]
    then
      cmd_key=$(echo $CMD | cut -d' ' -f1 )
      echo "\tprintf(\"Executing ${cmd_name} (${cmd_key})\\\n\");"
      echo "\tci\$put(cmd_key = \"${cmd_key}\" );"
      if [ -n "$CALL_CMDS_BY_NAME" ]
      then
        cmd_name=$(echo $CMD | cut -d' ' -f2- )
        echo "\tci\$put(cmd = \"${cmd_name}\");"
      fi
      echo
    fi
  
  done ) < $CMD_LIST

echo
echo "}"
