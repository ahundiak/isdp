#!/bin/ksh

RISTMP=/usr/tmp/version.h
VERFILE=$RISDEVDIR/riscom/internal/risver.h

#
# If the environment variable $1 (whose name is $2) is
# NOT defined, then remove the $VERFILE and error out !
# Thatway, compilation is not going to continue further !!!
#
# Surjit Sahoo (Feb.20, 1995)
#
check_env_var()
{
	if [ -z "$1" ]
	then
		print "\n\tERROR: Environment variable $2 is not defined."
		rm -f $VERFILE
		exit 1;
	fi
}

check_env_var "$RIS_MAJ" "RIS_MAJ"
check_env_var "$RIS_MIN" "RIS_MIN"
check_env_var "$RIS_REL" "RIS_REL"
check_env_var "$RIS_SEQ" "RIS_SEQ"

## Generate the new version file. this is now a perl script
if whence perl >/dev/null 2>&1
then
	if perl $RISDEVDIR/riscom/build/makevers.pl $RISTMP
	then
		cmp -s "$RISTMP" "$VERFILE" || cp $RISTMP $VERFILE
		print "\n\tUpdated $VERFILE\n"
		rm -f $RISTMP
	else
		print "\n\tERROR: The perl script 'makevers.pl' failed.\n"
		exit 1
	fi
else
	print "\n\tERROR: Cannot find 'perl' in current \$PATH.\n"
	exit 1
fi

