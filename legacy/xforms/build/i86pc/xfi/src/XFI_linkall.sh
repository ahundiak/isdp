### This file automatically generates the file 'XFI_link_all.c' from ###
### the X/Forms shared library '../lib/libXFI_s'. XFI_link_all.c     ###
### contains the names of all of the functions in the shared library ###
### which can be referenced from executables that link in the file   ###
### '/usr/lib/libXFI_s.a'.  These function names are then put into a ###
### big array structure in this .c file so that these function names ###
### are definitely referenced by code within the executable.  This   ###
### enables PPL files to call any of these functions.                ###

#set -x

#. $IFORMS/release/util/version.sh


TARGSTR="$1"
if [ "$TARGSTR" = "" ]
then
  TARGSTR=c100
fi

###########################
DFLT_OS_KEY=`uname -s | tr '[a-z]' '[A-Z]'`
case $DFLT_OS_KEY
in
  CLIX )
    DFLT_OS_KEY=$DFLT_OS_KEY
    ;;
  IRIX )
    DFLT_OS_KEY=$DFLT_OS_KEY
    ;;
  SUNOS )
    SUNOS_VERSION=`uname -r`
    case $SUNOS_VERSION
    in
      4.* )
        DFLT_OS_KEY=SUNOS4
        SUNOS_VERSION=SUNOS4
        ;;
      5.* )
        DFLT_OS_KEY=SUNOS5
        SUNOS_VERSION=SUNOS5
        ;;
      * )
        echo "Unknown SUNOS_VERSION $SUNOS_VERSION: Cannot set DFLT_OS_KEY"
        ;;
    esac
    ;;
  SUNOS4 )
    DFLT_OS_KEY=SUNOS4
    SUNOS_VERSION=SUNOS4
    ;;
  SUNOS5 )
    DFLT_OS_KEY=SUNOS5
    SUNOS_VERSION=SUNOS5
    ;;
  * )
    echo "Unknown DFLT_OS_KEY $DFLT_OS_KEY: Cannot set OS_KEY"
    ;;
esac

OS_KEY=${OS_KEY:-$DFLT_OS_KEY}

#########################

LIB_DIR=${XFI}/lib/${CURRENT_PROC_TYPE}

TMPFILE="/usr/tmp/libXFI$$"
REF_FILE=XFI_link_all.c
REF_FILE_O=XFI_link_all.o

if [ $OS_KEY = "CLIX" ]
then

  CC=${CC:-acc}
  COPT=${COPT:-"-ga -knr -O3 -Atarg=$TARGSTR -Abss=0"}

  FORMS_TARGET_SHLIB="${FORMS_TARGET_SHLIB:-$LIB_DIR/libXFI_s}"
  #FORMS_TARGET_SHLIB="../lib/$TARGSTR/libXFI_s"

elif [ $OS_KEY = "IRIX" ]
then

  CC=${CC:-cc}
# dmb:09/29/92:Opt level?
  COPT=${COPT:-"-ga -knr -O2 -Atarg=$TARGSTR -Abss=0"}

  FORMS_TARGET_SHLIB="${FORMS_TARGET_SHLIB:-$LIB_DIR/libXFI_s}"
  #FORMS_TARGET_SHLIB="../lib/$TARGSTR/libXFI_s"

elif [ $OS_KEY = "SUNOS4" ]
then

  CC=${CC:-"cc"}

  FORMS_TARGET_SHLIB="${FORMS_TARGET_SHLIB:-$LIB_DIR/libXFI.so.1.0}"

elif [ $OS_KEY = "SUNOS5" ]
then

  CC=${CC:-"acc"}

  FORMS_TARGET_SHLIB="${FORMS_TARGET_SHLIB:-$LIB_DIR/libXFI.so.2}"

else

  echo "Unknown OS_KEY $OS_KEY"

fi

rm -rf $TMPFILE

if [ ! -r "$FORMS_TARGET_SHLIB" ]
then
  echo
  echo "$0:  ERROR:  $FORMS_TARGET_SHLIB not found."
  echo
  echo
  exit 2
fi

if [ $OS_KEY = "CLIX" ]
then

  nm $FORMS_TARGET_SHLIB | fgrep "extern"		 |	\
			    grep "^_[FM]"	 |	\
			   fgrep ".text"	 |	\
			 awk -f\| '{ print $1 }' |
				sort		 > $TMPFILE

elif [ $OS_KEY = "IRIX" ]
then

  nm $FORMS_TARGET_SHLIB | fgrep "extern"		 |	\
			    grep "^_[FM]"	 |	\
			   fgrep ".text"	 |	\
			 awk -f\| '{ print $1 }' |
				sort		 > $TMPFILE
elif [ $OS_KEY = "SUNOS4" ]
then

  nm $FORMS_TARGET_SHLIB | fgrep " T _" | awk '{ print $3 }' |
		  grep "^_[FM]" |  sort		 > $TMPFILE

elif [ $OS_KEY = "SUNOS5" ]
then

  nm $FORMS_TARGET_SHLIB | fgrep " T _" | awk '{ print $3 }' |
		  grep "^_[FM]" |  sort		 > $TMPFILE

else

  echo "Unknown OS_KEY $OS_KEY"

fi

DATE=`date`

# dmb:03/10/92:Replaced block of echos with single cat.

cat <<!end_comment_header!	>> $REF_FILE

/*** $REF_FILE - $DATE         ***/
/*** This file is automatically generated from the X/Forms ***/
/*** shared library 'libXFI_s'.  It contains  all the      ***/
/*** function names in the shared library that are         ***/
/*** able to be referenced from executables that link in   ***/
/*** the file '/usr/lib/libXFI_s.a'.                       ***/
/*** These function names are                              ***/
/*** then put in a big array structure in this .c file so  ***/
/*** that these function names are definitely referenced   ***/
/*** by code within the executable.  This enables PPL      ***/
/*** files to call any of these functions.                 ***/

!end_comment_header!


    ########## dump out the extern's  ##########
for FUNC_NAME in `< $TMPFILE`
do
  echo "extern int ${FUNC_NAME#_}();"	>> $REF_FILE
done

echo ""					>> $REF_FILE
echo ""					>> $REF_FILE

    ########## dump out the array of functions  ##########
#echo "int xforms_func_ref[] () = {"			       \
#echo "int xforms_func_ref[] = {"				       \
echo "int ( * xforms_func_ref[] )() = {"				       \
					>> $REF_FILE

for FUNC_NAME in `< $TMPFILE`
do
#  echo " (int) ${FUNC_NAME#_},"		>> $REF_FILE
  echo " (int (*) ()) ${FUNC_NAME#_},"		>> $REF_FILE
done
echo "  0 };"				>> $REF_FILE


########### compile the file  ####################
set -x
$CC $COPT -c $REF_FILE
set +x

#mv $REF_FILE_O	$IFORMS/lib/$TARGSTR
mv $REF_FILE_O	$LIB_DIR

echo ""
#ls -ls $IFORMS/lib/$TARGSTR/$REF_FILE_O
ls -ls ${LIB_DIR}/$REF_FILE_O

# dmb:02/28/92:Added to keep generated prototype files the same.
rm -f $REF_FILE
echo ""
