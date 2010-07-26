#
#	checkEnv.sh
#
#	Script to check for NULL environment variables.
#
#	Usage: checkEnv.sh name value ...
#
#		expects a list of name value pair arguments:
#		checkEnv.sh EXNUC "$(EXNUC)" etc.

if test "$1" = "-p"
then
	PRINTONLY=1
	shift
else
	PRINTONLY=0
fi

echo "\n\tChecking environment variable(s) ..."
EXIT=0
while true
do
	if test -z "$1"
	then
		break
	fi
	echo "\t$1=$2"
	if test -z "$2"
	then
		EXIT=1
	fi
	shift 2
done

if test $PRINTONLY != 1
then
	exit $EXIT
else
	exit 0
fi
