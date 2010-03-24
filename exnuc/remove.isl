IDnumber=SN0S018AA-0304A
IDname=EXNUCDP
IDtitle="Executive Nucleus Development Platform"
IDversion=03.04.00.12
IDdate=14-Feb-2002
IDclass="Design o Engineering o Manufacturing"
IDassoc="0S"
DELdir=exnucdp
DELloadp=555
DELattr="shared|preprocess"
DELarch="INTEL_SOLARIS"
VARIANT=dp
PDkey=Exnuc
#============================================================
# remove.sh

echo "\nRemove ${IDtitle} - ${IDname} (${IDnumber})"

# Check user id. 
Test_id=$(id | cut -c5)
if [ "$Test_id" -ne 0 ]
then
   echo "\nMust be Super-User to run Remove\n"
   exit 1
fi

Version=`echo "${IDversion}" | sed 's/\.[0-9]*$//'`

TARGET_OS=$(uname -s)

if [ "$TARGET_OS" = "SunOS" -a -s "/usr/5bin/echo" ]
then
   alias -x echo="/usr/5bin/echo"
fi
if [ -z "$TMPDIR" ]  # if TMPDIR is NOT set then set it to /usr/tmp
then
   TMPDIR=/usr/tmp
fi

case $TARGET_OS in
CLIX)
   export INGRHOME=${INGRHOME:-/usr/ip32}
;; # End of CLIX
SunOS)
   OSVER="$(uname -r | cut -c1)"
   case $OSVER in
   4)
      export INGRHOME=${INGRHOME:-/usr/ip32}
   ;;
   5)
      export INGRHOME=${INGRHOME:-/opt/ingr}
   ;;
   *)
      echo "\nERROR: unsupported SunOS version \"$OSVER\""
      echo "The product was NOT completely removed.\n"
      exit 1
   ;;
   esac
;; # End of SunOS
IRIX)
   OSVER="$(uname -r | cut -c1)"
   case $OSVER in
   5|6)
      export INGRHOME=${INGRHOME:-/var/opt/ingr}
   ;;
   *)
      echo "\nERROR: unsupported IRIX version \"$OSVER\""
      echo "The product was NOT completely removed.\n"
      exit 1
   ;;
   esac
;; # End of IRIX
*)
   echo "\nUnknown TARGET Operation System \"$TARGET_OS\"\n"
   echo "The product was NOT completely removed.\n"
   exit 1
;;
esac  # End of TARGET_OS case

if [ ! -d "$INGRHOME" ]
then
   echo "\nThe \$INGRHOME \"$INGRHOME\" directory does NOT exist."
   echo "The product was NOT completely removed.\n"
   exit 1
fi

if [ ! -f "$INGRHOME/ingrconfig" ]
then
   echo "\nThe ingrconfig file does NOT exist in the \$INGRHOME \"$INGRHOME\" directory."
   echo "The product was NOT completely removed.\n"
   exit 1
fi

PROD_DEF_DIR="$(echo $INGRHOME | cut -f1 -d:)/$(echo $IDname | tr [A-Z] [a-z] )"
SYS_DEL_DIR=$(grep LIBXC $INGRHOME/ingrconfig | cut -f6 -d#)

if [ "$PROD_DEF_DIR" != "$SYS_DEL_DIR" ]
then
   if [ -d "$PROD_DEF_DIR" ]
   then
      echo "\nThe ${IDname} product may have files in the \"$PROD_DEF_DIR\" directory."
      PROD_LOC=$PROD_DEF_DIR
   fi
fi

if [ -d "$SYS_DEL_DIR" ]
then
   echo "\nThe ${IDname} product has files in the \"$SYS_DEL_DIR\" directory."
    PROD_LOC="$PROD_LOC $SYS_DEL_DIR"
else
   echo "\nThe ${IDname} product does NOT have files in the \"$SYS_DEL_DIR\" directory."
fi

if test -z "$PROD_LOC"
then
   echo "\nThe ${IDname} product does NOT have any directories defined."
   echo "Terminating removal ..."
   echo "The product was NOT completely removed.\n"
   exit 0
fi

echo "\nRemove ${IDname} Version ${Version}"
echo "from: $PROD_LOC (y/[n])\c"
read product_remove
if [ "$product_remove" != "y" ]
then
   echo "\nTerminating removal ..."
   echo "The product was NOT completely removed.\n"
   exit 0
fi
# END OF PROMPT SECTION

# Remove the Product directories.
for Dir in $(echo "$PROD_LOC")
do
  if [ -d "$Dir" ]
  then
    echo "\nConfirm removal of product directory \"$Dir\" (y/[n])\c"
    read confirm_removal
    if [ "$confirm_removal" = "y" -o "$confirm_removal" = "Y" ]
    then
       echo "rm -rf $Dir"
       rm -rf $Dir
    else
       echo "\nNot removing product directory \"$Dir\" ..."
       echo "Terminating removal ..."
       echo "The product was NOT completely removed.\n"
       exit 0
    fi
  else
    echo "\nProduct directory \"$Dir\" not found.\n"
  fi

if [ ! -f "$INGRHOME/product_data" ]
then
   echo "\nThe product_data file does NOT exist in the \$INGRHOME \"$INGRHOME\" directory."
   echo "The product was NOT completely removed.\n"
   exit 1
fi

PData=$INGRHOME/product_data
PDataT=$TMPDIR/pdat$$

# Remove entry from product_data
echo "Removing entry for $PDkey from $PData"

if [ -f "$PData" ]
then
  if [ -s "$PData" ]   # NOTE: Must not sed from an empty file.
  then
    sed "/^\"${PDkey}\"/d" $PData >$PDataT
    mv $PDataT $PData
  else
   echo "\nWarning: the $PData file was empty." >&2
   echo "Thus, could NOT remove product name.\n"
  fi
else
   echo "\nERROR: Cannot access $PData." >&2
   echo "The product was NOT completely removed.\n"
   exit 1
fi

done
echo "\nFinished removing ${IDname} Version ${Version} $(date)\n"
