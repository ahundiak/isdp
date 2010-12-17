# This is the package script for the entire Project.

#sysinfo/package70.sh
# This script calls prodinfo/package70.sh.

# dmb:02/02/93: Pilot attempt at unbundled packaging. We'll start
# with MIPS first. 
#  we have hardwired around that part of the packaging.  


###################
# History:
# 09/24/91   dmb     Freely adapted from XFORMS Project build.sh
#                    The basic build model has been modified to support
#                    multiple target archetectures.
# 11/12/91   dmb     Added -l switch for logfile.
#
# Notes:
#  Recommended practice is to define a set of common symbols to be
# used in makefiles and set their values here. This should allow
# individual tailoring of the make process. 
# In our production environment, we use the -e switch on make to override
# the variable definitions from the environment. Applications and
# examples users will get the correct default locations by using
# make without the -e.
#

# For debugging the build script and makefiles...
MAKE='make -e -n'
# For real builds...
#MAKE='make -e'

#dmb:02/02/93:Adding -a and -t switches sos I can slap in the
# unbundled build stuff as fast as I can.
ALL_SUPPORTED_PROC_TYPES=''
OVERRIDE_SUPPORTED_PROC_TYPE_LIST=''

ARGS=''
LOGFILE=''

for arg in $*
do
  case $arg
  in
    -l )
     ARGS="$ARGS -l $LOGFILE"

     case "$2"
     in
       [!-]* )
         LOGFILE=$2
         shift 2
         ;;
       * )
         # NEED TO SUPPLY DEFAULT LOGFILE NAME
         LOGFILE=''
         shift
         ;;  
     esac

     echo LOGFILE is $LOGFILE

     ;;
    -s )
     ARGS="$ARGS -s"
     shift
     ;;
    -f )
     ARGS="$ARGS -f"
     shift
     ;;
    -i )
     ARGS="$ARGS -i"
     shift
     ;;
    -d )
     ARGS="$ARGS -d"
     shift
     ;;
    -v )
     export VERBOSE='y'
     shift
     ;;
    -a )
     ALL_SUPPORTED_PROC_TYPES='y'
     shift
     ;;
    -t )
     ALL_SUPPORTED_PROC_TYPES='o'
    OVERRIDE_SUPPORTED_PROC_TYPE_LIST="$OVERRIDE_SUPPORTED_PROC_TYPE_LIST $2"
     shift 2
     ;;
  esac
done

if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
  exit 2
fi


# These can be inferred from the source platform itself (Default)
#ProductList="`find $SYSTEM_SOURCE/*/prodinfo -type d -print |
#    sed 's/\/prodinfo//;s/^.*\///'`"
#ComponentList="`find $SYSTEM_SOURCE/*/compinfo -type d -print |
#    sed 's/\/compinfo//;s/^.*\///'`"

# or these can also be read from a user supplied data (table) file(s).
# This could be useful when components must be built in a specific order.
PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"
ComponentList="`<${COMPONENT_FILE_NAME}`"
ProductList="`<${PRODUCT_FILE_NAME}`"


# Use this with remote mounted production.
# dmb:11/20/91:DELTOOLS folk (sw) say that Clipper blocks are used on both
#   archetectures, so we'll just package on CLIPPERS for now.


# Set logfile: Default is to screen
LOGFILE=${LOGFILE:-/dev/null}
echo LOGFILE is $LOGFILE


#
# Package Products
#
  
time (
echo "Begin ${SYSTEM_NAME_KEY} Package." `date`

echo ""

#dmb:02/02/93:Adding unbundled packaging feature.
#dmb:05/14/92: Would CURRENT_PROC_TYPE_LIST be clearer than PROC_TYPE_LIST?
#   Use PROC_TYPE_LIST for build, SUPPORTED_PROC_TYPE_LIST for package.
#dmb:01/14/93:Adding -a switch to check all supported proc types.

# dmb:02/02/93:Converted to case & kludged in OVERRIDE
case "$ALL_SUPPORTED_PROC_TYPES"
in
  'y' )
  PROC_TYPE_PACKAGE_LIST="$SUPPORTED_PROC_TYPE_LIST"
  ;;
  'o' )
  PROC_TYPE_PACKAGE_LIST="$OVERRIDE_SUPPORTED_PROC_TYPE_LIST"
  ;;
  * )
  PROC_TYPE_PACKAGE_LIST="$PROC_TYPE_LIST"
  ;;
esac


#echo ALL_SUPPORTED_PROC_TYPES is $ALL_SUPPORTED_PROC_TYPES
#echo SUPPORTED_PROC_TYPE_LIST is $SUPPORTED_PROC_TYPE_LIST
#echo PROC_TYPE_LIST is $PROC_TYPE_LIST
#echo PROC_TYPE_PACKAGE_LIST is $PROC_TYPE_PACKAGE_LIST


#for CURRENT_PROC_TYPE in $PROC_TYPE_LIST
#for CURRENT_PROC_TYPE in $SUPPORTED_PROC_TYPE_LIST

for CURRENT_PROC_TYPE in $PROC_TYPE_PACKAGE_LIST
do
  echo "Begin Package for $CURRENT_PROC_TYPE"
  #
  # Set Environment
  #


#dmb:05/14/92: Shouldn't we do this here?
#  # dmb:02/03/92:Set up symbol that will be used in product.def
#  PROC_TYPE=${CURRENT_PROC_TYPE}
#  PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
#  export PROC_TYPE PROC_TYPE_KEY CURRENT_PROC_TYPE


  . ${SYSTEM_INFORMATION}/system.env

#dmb:05/14/92:This looks wrong. Take it out.
#  # NOTE: Temporary kludge until $SYSTEM_NAME symbol is straightened out.
#  export SYSTEM_NAME=$SYSTEM_BUILD

  echo ""
  echo "  Packaging $CURRENT_PROC_TYPE Components"
  for Product in $ProductList
  do
    ( 
#      export PROD_NAME=$Product
      echo "   \$PRODINFO/package70.sh $CURRENT_PROC_TYPE for $Product"
      PROD_NAME=$Product $SYSTEM_SOURCE/prodinfo/package70.sh $CURRENT_PROC_TYPE
    )
  done
  echo ""
  
  echo "Finished $Product Package for $CURRENT_PROC_TYPE"
  echo ""

done

echo
echo "Be sure to run checkprod.sh to check Products for PLOAD Requirements"
echo

echo "Initializing Products for Delivery"
# dmb:02/05/92:Try using new newprod Initial
( PATH=`proddata +%p -x deltools`/node:$PATH
  cd $HOME
  date
set -x
  `proddata +%p -x deltools`/node/Initial $SYSTEM_DELIVER/*
#  `proddata +%p -x deltools`/node/Initial $PROD_DLVR/*
set +x
  echo
) | tee $HOME/product.log

echo "End ${SYSTEM_NAME_KEY} Project Package." `date`
) | tee ${LOGFILE}
