if [ $# = 1 ]
then
  FILE=$1
else
  echo "USAGE: $0 [filename]"
  echo "where filename is the name of any file in all prodinfo directories."
  exit 1
fi

# dmb:10/17/91: Get context.
# Setup environment
VERBOSE=${VERBOSE:-""}

case $CURRENT_PROC_TYPE_KEY
in
  HPUX )
    ## For HPUX
    ArchType=HPUX
    ProcType=HP9000
    ProcKey=hp

    ECHO='echo '
    ;;
  I386 )
    ## For SCO 
    ArchType=INTEL_SCO
    ProcType=I386
    ProcKey=i3

    ECHO='echo '
    ;;
  C100 )
    ## For CLIX
    ArchType=CLIPPER
    ProcType=C100
    ProcKey=c1

    ECHO='echo '
    ;;
  C300 )
    ## For CLIX
    ArchType=CLIPPER
    ProcType=C300
    ProcKey=c3

    ECHO='echo '
    ;;
  C400 )
    ## For CLIX
    ArchType=CLIPPER
    ProcType=C400
    ProcKey=c4

    ECHO='echo '
    ;;
  MIPS )
    ## For MIPS (SGI)
    ArchType=MIPS
    ProcType=MIPS
    ProcKey=mi

    ECHO='echo '
    ;;
  SUN4 )
    # For SUN
    ArchType=SUN

# This probably neds to expand to cover sun4c, sun2, etc.
    ProcType=sun4
    ProcKey=s

    ECHO='/usr/5bin/echo '
    ;;
  * )
    echo "$CURRENT_PROC_TYPE delivery not supported yet." >&2
    exit 1
    ;;
esac

SYS_INFO=$SYSTEM_INFORMATION
# Set the environment
if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "`basename $0: Can not find file ${SYS_INFO}/system.env" 1>&2
  exit 2
fi

# NOTE: Temporary kludge until HELP symbol is straightened out.
export HELP=$SYSTEM_BUILD


cd $SYSTEM_SOURCE/prodinfo


# These can be inferred from the source platform itself (Default)
#ProductList="`find $SYSTEM_SOURCE/*/prodinfo -type d -print |
#    sed 's/\/prodinfo//;s/^.*\///'`"
#ComponentList="`find $SYSTEM_SOURCE/*/compinfo -type d -print |
#    sed 's/\/compinfo//;s/^.*\///'`"

# or these can also be read from a user supplied data (table) file(s).
# This could be useful when components must be built in a specific order.
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"
ComponentList="`<${COMPONENT_FILE_NAME}`"

# Note: This should probably live in $PROD_INFO, not $SYS_INFO
PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
ProductList="`<${PRODUCT_FILE_NAME}`"


# dmb:10/17/91:Update this to set version and date in product.def 
#  and README.
for PROD_NAME in $ProductList
do
   PROD_INFO_DIR=$SYSTEM_SOURCE/prodinfo/$PROD_NAME

   echo cp $FILE $PROD_INFO_DIR/$FILE
   cp $FILE $PROD_INFO_DIR/$FILE

done
echo ""
