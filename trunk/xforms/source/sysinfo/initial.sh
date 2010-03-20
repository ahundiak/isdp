#dmb:02/02/93:Adding -a and -o switches sos I can slap in the
# unbundled build stuff as fast as I can.
ALL_SUPPORTED_OS_KEYS=''
OVERRIDE_SUPPORTED_OS_KEY_INITIALIZATION_LIST=''

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
    -v )
     export VERBOSE='y'
     shift
     ;;
    -a )
     ALL_SUPPORTED_OS_KEYS='y'
     shift
     ;;
    -o )
     ALL_SUPPORTED_OS_KEYS='o'
     OVERRIDE_SUPPORTED_OS_KEY_INITIALIZATION_LIST="$OVERRIDE_SUPPORTED_OS_KEY_INITIALIZATION_LIST $2"
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


# These are read from a user supplied table.
# This is useful when components must be built in a specific order or when
# a subset of components are to be built.
PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"
ComponentList="`<${COMPONENT_FILE_NAME}`"
ProductList="`<${PRODUCT_FILE_NAME}`"

#
# Initialize Products
#
  
time (
echo "Begin ${SYSTEM_NAME_KEY} Product Initialization." `date`

echo ""

#dmb:02/02/93:Adding unbundled Initializing feature.
#dmb:05/14/92: Would CURRENT_OS_KEY_INITIALIZATION_LIST be clearer than OS_KEY_INITIALIZATION_LIST?
#   Use OS_KEY_INITIALIZATION_LIST for build, SUPPORTED_OS_KEY_INITIALIZATION_LIST for package.
#dmb:01/14/93:Adding -a switch to check all supported proc types.

# dmb:02/02/93:Converted to case & kludged in OVERRIDE
case "$ALL_SUPPORTED_OS_KEYS"
in
  'y' )
  OS_KEY_INITIALIZATION_LIST="$SUPPORTED_OS_KEY_INITIALIZATION_LIST"
  ;;
  'o' )
  OS_KEY_INITIALIZATION_LIST="$OVERRIDE_SUPPORTED_OS_KEY_INITIALIZATION_LIST"
  ;;
  * )
#  OS_KEY_INITIALIZATION_LIST="$OS_KEY_INITIALIZATION_LIST"
# dmb:03/05/93:Changed to use OS_KEY_INITIALIZATION_LIST by default
  OS_KEY_INITIALIZATION_LIST="$OS_KEY_INITIALIZATION_LIST"
  ;;
esac


#echo ALL_SUPPORTED_OS_KEYS is $ALL_SUPPORTED_OS_KEYS
#echo SUPPORTED_OS_KEY_INITIALIZATION_LIST is $SUPPORTED_OS_KEY_INITIALIZATION_LIST
#echo OS_KEY_INITIALIZATION_LIST is $OS_KEY_INITIALIZATION_LIST


for CURRENT_OS_KEY in $OS_KEY_INITIALIZATION_LIST
do
#  echo "Begin Initialization for $CURRENT_OS_KEY"
  #
  # Set Environment
  #

  . ${SYSTEM_INFORMATION}/system.env


#  echo OSVERLIST is $OSVERLIST
  for OSVER in $OSVERLIST
  do
#    echo ""
#    echo "  Initializing $CURRENT_OS_KEY $OSVER Products"

    for Product in $ProductList
    do
      ( 

       # dmb:02/05/92:Use newprod Initial
       PATH=`proddata +%p -x deltools`/node:$PATH
       cd $HOME

#       echo Initial $SYSTEM_DELIVER_ROOT/$OSDIR/$OSVER/$DLVRPROC/ws_s/$Product
#set -x
  `proddata +%p -x deltools`/node/Initial $SYSTEM_DELIVER_ROOT/$OSDIR/$OSVER/$DLVRPROC/ws_s/$Product
#set +x

#      echo
    ) | tee $HOME/product.log

  done
done

  done
  echo ""
  
  echo "Finished ${SYSTEM_NAME_KEY} Product Initialization." `date`
  echo ""

)

