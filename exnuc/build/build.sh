#	Script for making EXNUC.

ARGV0=`basename $0`
set -e

###############################################################################

if test ! "$EXNUC" = "`pwd`"
then
	echo "ERROR: $ARGV0: EXNUC env variable must be the current working directory" >&2
	exit 2
fi

###############################################################################

echo "\n\tThe build environment needs to have EXNUC,BASE & TARGET defined."
echo "\tThe values should be:"
echo "\t\tEXNUC\tLocation of EXNUC source."
echo "\t\tBASE\tLocation of EXNUC basic executables."
echo "\t\tTARGET\tLocation of EXNUC target."
###############################################################################

echo "\nBuild Menu\n"

#	Kick off the makefile

PS3="
enter selection: "

OS=$(uname -s)

case $OS in
  "CLIX" )
     BUILD_LIST="c100 EXNUC	c100 EXNUCX	c400 EXNUC	c400 EXNUCX";
     break;;
  "IRIX" )
     REL=`uname -r | cut -c1`;
     case $REL in
          "4" ) BUILD_LIST="sgi4 EXNUC";;
          "5" ) BUILD_LIST="sgi5 EXNUC";;
          *   ) echo "Unsupported OS version";
                exit;;
     esac;
     break;;
  "SunOS" )
     REL=`uname -r`;
     case $REL in
          "4.1.2" )  BUILD_LIST="sun4 EXNUC";;
          "5.2"   )  BUILD_LIST="sun5 EXNUC";;
          "5.4"   )
                if test "`uname -m`" = "i86pc"
                then
                  BUILD_LIST="intel5 EXNUC"
                else
                  BUILD_LIST="sun6 EXNUC"
                fi;;
          "5.5" | "5.5.1" | "5.8" | "5.10" )
                ARCH=`uname -m`
                case $ARCH in
                     "i86pc" )  BUILD_LIST="intel5 EXNUC";;
                     "sun4c" | "sun4m" )
                                BUILD_LIST="sun5 EXNUC";;
                     "sun4u" )  BUILD_LIST="sun6 EXNUC";;
                     *        ) echo "Unsupported OS version";
                                exit;;
                esac;
     esac;
     break;;
  * )
     echo "$ARGV0: ERROR: unknown uname: $OS" >&2;
     exit 2;;
esac


OIFS=$IFS
IFS="	"
select BUILD in $BUILD_LIST	quit
do
	IFS=$OIFS
	case $BUILD
	in
	"c100 EXNUC")	export BUILD=c1EXNUC;;
	"c100 EXNUCX")	export BUILD=c1EXNUCX;;
	"c400 EXNUC")	export BUILD=c4EXNUC;;
	"c400 EXNUCX")	export BUILD=c4EXNUCX;;
	"sun4 EXNUC")	export BUILD=s4EXNUC;;
	"sun5 EXNUC")	export BUILD=s5EXNUC;;
	"sun6 EXNUC")	export BUILD=s6EXNUC;;
	"intel5 EXNUC")	export BUILD=i5EXNUC;;
	"sgi4 EXNUC")	export BUILD=m4EXNUC;;
	"sgi5 EXNUC")	export BUILD=m5EXNUC;;
	"quit"|*)	exit 0;;
	esac

	. $EXNUC/build/getBuildNum.sh
	. $EXNUC/build/exnucenv

###############################################################################
echo "\n\tThe values arc:"
echo "\t\tEXNUC\t$EXNUC"
echo "\t\tBASE\t$BASE"
echo "\t\tTARGET\t$TARGET"
###############################################################################

	echo
	echo "Starting makefile ..."

	make -e

	break
done

if [ "$OS" = "SunOS" ]
then
  cd $EXTARG/lib
  rm $EXTARG/lib/libfpstub.so
  make -f $EXTARG/lib/fpstub.mk
  cp $EXNUC/lib/link_stub.c $EXNUC/lib/fp_stub.c $EXTARG/lib/
fi

###############################################################################

echo "\nSUCCESS"
echo "Finished on `date`\n"
