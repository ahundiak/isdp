#!/bin/ksh
#	Script for packaging EXNUC products for newprod.
#

TMPDIR=${TMPDIR:-/usr2/tmp}
WRKDIR=$TMPDIR/$$package
ARGV0=`basename $0`
set -e

mkdir $WRKDIR
trap "rm -rf $WRKDIR" 15 0
trap "rm -rf $WRKDIR; exit 2" 2

################################################################################

if test ! "$EXNUC" = "`pwd`"
then
	echo "ERROR: $ARGV0: EXNUC env variable must be the current working directory" >&2
	exit 2
fi

################################################################################

UNAME=`uname -s`

################################################################################

echo
echo "Package Menu"
echo

PS3="
enter selection: "

PRODUCT_NAME_LIST="EXNUC EXNUCDP"
if test "$UNAME" = "CLIX"
then
	PRODUCT_NAME_LIST="$PRODUCT_NAME_LIST EXNUCX EXNUCXDP"
fi

select PRODUCT_NAME in $PRODUCT_NAME_LIST quit
do
	if test "$PRODUCT_NAME" = "quit"
	then
		break
	fi

	PATH=$PATH:$BASE/package/bin

	#
	#	Just use the "c100" version of the product to set up
	#	some common env variables.  Some of these values will
	#	be overriden later.  This env file keys off the variable
	#	"BUILD".

	export BUILD=c1$PRODUCT_NAME
	. $EXNUC/build/getBuildNum.sh
	. $EXNUC/build/exnucenv

	#
	#	Now get the environment for packaging.  It keys off the
	#	variable "PRODUCT_NAME".
	#

	. $EXNUC/package/env/env
	echo
	TMP_CPUTYPE_LIST=
	for CPUTYPE in $CPUTYPE_LIST
	do
		echo "Package $CPUTYPE code [y] ? \c"
		read
		if test -z "$REPLY" -o "$REPLY" = "Y" -o "$REPLY" = "y"
		then
		  TMP_CPUTYPE_LIST="$TMP_CPUTYPE_LIST $CPUTYPE"
		  if [ "$CPUTYPE" = "c1" -o "$CPUTYPE" = "c4" ]
		  then
			if test -z "$IDassoc"
			then
				TMP_IDassoc="01"
			else
				if [ "$IDassoc" != "01" ]
				then
					TMP_IDassoc="$IDassoc 01"
				fi
			fi
			export IDassoc="$TMP_IDassoc"
			if test -z "$DELarch"
			then
				TMP_DELarch="CLIPPER"
			else
				if [ "$DELarch" != "CLIPPER" ]
				then
					TMP_DELarch="$DELarch|CLIPPER"
				fi
			fi
			export DELarch="$TMP_DELarch"
		  fi   # if c1 or c4
		  if [ "$CPUTYPE" = "s4" ] # SUN
		  then
			if test -z "$IDassoc"
			then
				TMP_IDassoc="05"
			else
				TMP_IDassoc="$IDassoc 05"
			fi
			export IDassoc="$TMP_IDassoc"
			if test -z "$DELarch"
			then
				TMP_DELarch="SUN"
			else
				TMP_DELarch="$DELarch|SUN"
			fi
			export DELarch="$TMP_DELarch"
		  fi   #if SUN
		  if [ "$CPUTYPE" = "s5" -o "$CPUTYPE" = "s6" ] # SPARC_SOLARIS
		  then
			if test -z "$IDassoc"
			then
				TMP_IDassoc="05"
			else
				TMP_IDassoc="$IDassoc 05"
			fi
			export IDassoc="$TMP_IDassoc"
			if test -z "$DELarch"
			then
				TMP_DELarch="SPARC_SOLARIS"
			else
				TMP_DELarch="$DELarch|SPARC_SOLARIS"
			fi
			export DELarch="$TMP_DELarch"
		  fi   #if SPARC_SOLARIS
		  if [ "$CPUTYPE" = "i5" ] # INTEL_SOLARIS
		  then
			if test -z "$IDassoc"
			then
				TMP_IDassoc="0S"
			else
				TMP_IDassoc="$IDassoc 0S"
			fi
			export IDassoc="$TMP_IDassoc"
			if test -z "$DELarch"
			then
				TMP_DELarch="INTEL_SOLARIS"
			else
				TMP_DELarch="$DELarch|INTEL_SOLARIS"
			fi
			export DELarch="$TMP_DELarch"
		  fi   #if INTEL_SOLARIS
		  if [ "$CPUTYPE" = "m4" -o "$CPUTYPE" = "m5" ]
		  then
			if test -z "$IDassoc"
			then
				TMP_IDassoc="0H"
			else
				TMP_IDassoc="$IDassoc 0H"
			fi
			export IDassoc="$TMP_IDassoc"
			if test -z "$DELarch"
			then
				TMP_DELarch="MIPS_IRIX"
			else
				TMP_DELarch="$DELarch|MIPS_IRIX"
			fi
			export DELarch="$TMP_DELarch"
		  fi   # if MIPS (SGI)
		fi
	done
	CPUTYPE_LIST=$TMP_CPUTYPE_LIST

	if test -z "$CPUTYPE_LIST"
	then
		echo "$ARGV0: no cpu types specified" >&2
		exit 2
	fi

	########################################################################

	#
	#	Copy the post install scripts to the working directory
	#	so they can be bundled in with each pass through the
	#	processor list.
	#
	set +e
	if test -n "$(\ls $PRODUCT_DIR/*.ish 2>/dev/null)"
	then
		cp $PRODUCT_DIR/*.ish $WRKDIR
	fi
	set -e

	#
	#	Do the common components first.  These are not specific
	#	to any one cpu or platform.
	#
	#	Then pack all the processor specific parts.  These are
	#	prefixed by the cpu type.
	#
#set -x
	for CPUTYPE in common $CPUTYPE_LIST
	do
	(
		TARGET=
		PRODUCT_DIR=
		if test $CPUTYPE = common
		then
			CPUTYPE=
			PREFIX=
		else
			PREFIX="-p $CPUTYPE"
			#
			#	Get the TARGET env variable for this build
			#
			#BUILD=${CPUTYPE}$PRODUCT_NAME
			#. $EXNUC/build/exnucenv
			if [ "$CPUTYPE" = "s6" ]
			then
				export TARGET=/usr2/exnuc34/sun6
			elif [ "$CPUTYPE" = "s5" ]
			then
				export TARGET=/usr2/exnuc34/sun5
			elif [ "$CPUTYPE" = "m5" ]
			then
				export TARGET=/usr2/exnuc34/sgi5
			elif [ "$CPUTYPE" = "i5" ]
			then
				export TARGET=/usr2/exnuc34/intel5
			else
                        	BUILD=${CPUTYPE}$PRODUCT_NAME
                        	. $EXNUC/build/exnucenv
			fi
		fi

		echo
		echo "packing $CPUTYPE $PRODUCT_NAME $PRODUCT_VERSION"
		#
		#	Create the list(s) of files for cpio
		#
		ENVFILES=$(prepack -o $WRKDIR $PREFIX \
			-n ${CPUTYPE}$PRODUCT_NAME \
			$(find . -name directory.itb -print))

		#
		#	Create the cpio files for the product
		#
		packex.sh -o $WRKDIR $ENVFILES
		echo
		echo "SUCCESS packing $CPUTYPE $PRODUCT_NAME $PRODUCT_VERSION"
	)
	done
#set +x
	#
	#	Compute DELsize
	if [ "$VARIANT" = "rt" ]
	then
		echo "DELsize=8500" > $WRKDIR/DELsize
	fi
	if [ "$VARIANT" = "dp" ]
	then
		echo "DELsize=16500" > $WRKDIR/DELsize
	fi
	if [ "$VARIANT" = "src" ]
	then
		echo "DELsize=50000" > $WRKDIR/DELsize
	fi

	#
	# 	Finish making the support files (install.sh, share.sh,
	#	remove.sh, product.def, README)
	#
	echo
	echo "Creating support files"
	support.sh -o $WRKDIR -d $EXNUC/package/prodinfo $(\ls $WRKDIR/*.env)
	echo
	echo "SUCCESS creating support files"

	echo
	echo "Moving file(s) to PRODUCT_DIR: $PRODUCT_DIR"
	echo "WRKDIR = $WRKDIR"
	cd $WRKDIR
	find . -print | cpio -pvmud $PRODUCT_DIR
	cd -
	#mv $WRKDIR/* $PRODUCT_DIR

	break
done

echo
echo "SUCCESS"
echo "Finished on `date`"

exit 0
