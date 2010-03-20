#######################################################################
### chng_ident.sh  - script to update "#ident" of shared library    ###
###                    and regular forms library                    ###
###                                                                 ###
###  JAJ: 02/04/91:   Also, update glob.c line:                     ###
###     "char _XFI_appl_version_array[512]="02.00.02.18";"          ###
#######################################################################


# dmb:05/20/92:Added so we don't look so bad on SUN builds.
OS_TYPE_KEY=`uname -s | tr '[a-z]' '[A-Z]'`
case $OS_TYPE_KEY
in
  HP-UX )
    NO_NEWLINE=""
    CR="\c"
  ;;
  CLIX )
    NO_NEWLINE=""
    CR="\c"
  ;;
  IRIX )
    NO_NEWLINE=""
    CR="\c"
  ;;
  SUNOS )
    NO_NEWLINE="-n"
    CR=""
  ;;
    * )
     # sml:08-20-93 add case for SCO, since uname -s is unreliable
     #              on that box
     OS_SECONDARY_KEY=`uname -m`

     case $OS_SECONDARY_KEY
     in
       i386|i486 )
         OS_TYPE_KEY=SCO
         NO_NEWLINE=""
         CR="\c"
       ;;

       * )
         echo "WARNING: $OS_TYPE_KEY is not yet supported" >&2
         exit 2
       ;;
     esac
  
  ;;
esac

################################
### get the version number   ###
################################
. $PRODINFO/prodversion.sh

DATE=`date`

if [ ! -d "$TMPDIR" ]
then
  export TMPDIR=/usr/tmp
fi

FILE_LIST="$XFI/src/glob.c"

cat <<!end_of_warning!


        *****************************************************
        ********   DO NOT INTERRUPT (^C) NOW  !!!!!!   ******
        **********  (or 'sed' may damage src files)  ********
        *****************************************************

!end_of_warning!

for IDENT_FULLFILE in $FILE_LIST
do
  if [ -r "$IDENT_FULLFILE" ]
  then

    if [ ! -s "$IDENT_FULLFILE" ]
    then

      cat <<!end_of_error_message!

      +++++++++++++++++++++++++++++++++++++++++++++++++++++
      $0: ERROR: The source file
      "$IDENT_FULLFILE" is 0 bytes.
      +++++++++++++++++++++++++++++++++++++++++++++++++++++
      It was probably destroyed by somebody CTRL-C -ing out
      of this script.  It will be necessary to restore the
      "$IDENT_FULLFILE" file
      either from source-control (SPC),
      or perhaps a copy is in /usr/tmp under a similar name
      ( but verify the /usr/tmp copy before using it ).
      +++++++++++++++++++++++++++++++++++++++++++++++++++++

!end_of_error_message!
      exit 1

    fi

  else

      cat <<!end_of_error_message2!

      +++++++++++++++++++++++++++++++++++++++++++++++++++++
      $0: ERROR: The source file
      "$IDENT_FULLFILE"
      is not readable, or does not exist.
      +++++++++++++++++++++++++++++++++++++++++++++++++++++

!end_of_error_message2!
    exit 2

  fi

  IDENT_FILE=`basename $IDENT_FULLFILE`
  TMP_INSTALL_FILE="$TMPDIR/$IDENT_FILE$$"
  TMP_SED_FILE="$TMPDIR/ident.sed$$"
  cp $IDENT_FULLFILE $TMP_INSTALL_FILE

  INSERT="#ident \"XFORMS version $PROD_VERSION $DATE Intergraph Corp.\""
  cat <<!end_of_sed_script! > $TMP_SED_FILE
/^#ident /{
i\\
$INSERT
d
}
!end_of_sed_script!

  echo "Inserting $INSERT"
  echo "  into $IDENT_FULLFILE..."
  echo

  set -x

  sed -f $TMP_SED_FILE < $TMP_INSTALL_FILE > $IDENT_FULLFILE

  set +x

done


##################################################################
## Update the "_XFI_appl_version_array" declaration line in glob.c
##################################################################

FPI_FILE=$XFI/src/glob.c
TMP_FILE=$TMPDIR/glob2.c$$
TMP_INSERT_FILE=$TMPDIR/insert.sed$$
cp $FPI_FILE    $TMP_FILE

INSERT="char _XFI_appl_version_array[512]=\"$PROD_VERSION\";"

cat <<!end_of_insert_script!     > $TMP_INSERT_FILE
/^char _XFI_appl_version_array/{
i\\
$INSERT
d
}
!end_of_insert_script!

echo
echo "Inserting '$INSERT'"
echo "  into $FPI_FILE"
echo

set -x

sed -f $TMP_INSERT_FILE < $TMP_FILE > $FPI_FILE

set +x

rm -f $TMP_INSERT_FILE $TMP_INSTALL_FILE $TMP_SED_FILE $TMP_FILE

	##########################################################
	### Wait until the very end before giving the OK to CTRL-C
	##########################################################

cat <<!end_of_ok!

        *****************************************************
        ********   OK TO INTERRUPT (^C) NOW  !!!!!!   *******
        *****************************************************


!end_of_ok!

exit 0
