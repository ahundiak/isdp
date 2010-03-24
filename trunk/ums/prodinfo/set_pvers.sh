# This script should help make it easier to set the product date
# in the README files.
# History:
# 05/06/91   dmb     Slapped together.
# 10/17/91   dmb     Slapped around some more for PAS4.0 in HELP.

# dmb:10/17/91: update build notes in New Fixes Section with edit_pinfo.sh

#if [ $# = 1 ]
#then
#  FILE=$1
#else
#  echo "USAGE: $0 [filename]\n\
#    where filename is the name of any file in all prodinfo directories."
#  exit 1
#fi


# dmb:10/17/91: Get context.
# Setup environment
VERBOSE=${VERBOSE:-""}

# dmb:05/20/92:Added so we don't look so bad on SUN builds.
case $OS_KEY
in
  SCO )
    NO_NEWLINE=""
    CR="\c"
  ;;
  HPUX )
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
#  SUNOS | SUNOS4 )
  SUNOS4 )
    NO_NEWLINE="-n"
    CR=""
  ;;
  SUNOS5 )
    NO_NEWLINE=""
    CR="\c"
  ;;
  * )
    echo "WARNING: $OS_TYPE_KEY is not yet supported" >&2
    exit 2
  ;;
esac

case $CURRENT_PROC_TYPE_KEY
in
  HP9000 )
    ## For SCO
    ArchType=hpux
    ProcType=hp9000
    ProcKey=hp

    ECHO='echo '
    ;;
  I486 )
    ## For SCO
    ArchType=SCO
    ProcType=I486
    ProcKey=i4

    ECHO='echo '
    ;;
  I386 )
    ArchType=sco
    ArchTypeKey=SCO
    ProcType=i386
    ProcTypeKey=I386
    ProcSuffix=i3

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
# or     ProcKey=sg

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
  I86PC )
#dmb:08/02/94:Experimental setup for INTEL_SOLARIS.
    # For INTEL_SOLARIS
    ArchType=INTEL_SOLARIS
 
# This probably neds to expand to cover sun4c, sun2, etc.
    ProcType=i86pc
#dmb:08/17/94:I don't think these are used anymore...
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
  echo "`basename $0`: Can not find file ${SYS_INFO}/system.env" 1>&2
  exit 2
fi

# NOTE: Temporary kludge until HELP symbol is straightened out.
#dmb:04/08/93:Removed
#export HELP=$SYSTEM_BUILD


cd $SYSTEM_SOURCE/prodinfo
echo "Current Product Version and Date are: "
. prodversion.sh -v

echo
echo ${NO_NEWLINE} "Change current product version or date? (y/n) [n]: ${CR}"
read answer
answer=${answer:-n}
if [ $answer = 'y' -o $answer = 'Y' ]
then

  $EDITOR prodversion.sh
  echo "Current Product Version and Date are now: "
  . prodversion.sh -v
fi


#dmb,ebh:04/08/92:Added to generate version include file for HELP
# Generate an include file to set the version number for the executable
if [ -f "${SYSTEM_INFORMATION}/exeversion.sh" ]
then
  . ${SYSTEM_INFORMATION}/exeversion.sh
else
  # 07/06/92: Changed error to note for general use.
  echo "NOTE: `basename $0`: Can not find file ${SYS_INFO}/exeversion.sh" 1>&2
#  exit 2
fi


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
  echo "  Updating prodversion.sh for $PROD_NAME"

   PROD_INFO_DIR=$SYSTEM_SOURCE/prodinfo/$PROD_NAME
#      export PROD_NAME=$PROD_NAME

   echo cp prodversion.sh $PROD_INFO_DIR/prodversion.sh
   cp prodversion.sh $PROD_INFO_DIR/prodversion.sh


echo "Setting Product Release Date in $PROD_INFO_DIR/README"
sed -e "s/^Date:        .*$/Date:        $PROD_DATE/" \
    -e "s/^Version:    .*$/Version:     $PROD_VERSION/" \
    -e "s/^Version $PROD_VERSION .*$/Version $PROD_VERSION -- $PROD_DATE/"\
    $PROD_INFO_DIR/README  >$PROD_INFO_DIR/README.tmp

mv -f $PROD_INFO_DIR/README.tmp $PROD_INFO_DIR/README

done
echo ""
