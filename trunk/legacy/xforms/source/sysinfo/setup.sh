#/usr/bin/ksh
ARGS=''
DBG=''
LOGFILE=''
STRIP=''
SaveArgs="$*"

for arg in $*
do
  case $arg
  in
    -l )
     case $2
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

     ARGS="$ARGS -l $LOGFILE"

     ;;
    -s )
     ARGS="$ARGS -s"
     shift
     STRIP=True
     export STRIP
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
     DBG='y'
     shift
     ;;
  esac
done
export DBG


if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
  exit 2
fi


PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"

#dmb:04/01/92: Put PAS_f_get_component_list here?
ComponentList="`<${COMPONENT_FILE_NAME}`"

ProductList="`<${PRODUCT_FILE_NAME}`"


# Set Pvers here?
. $PRODINFO/set_pvers.sh

# dmb:01/14/93:Added Build Comments

# dmb:01/14/93: Moved LOGFILE setup to outer shell
# Set logfile: Default is to screen
LOGFILE=${LOGFILE:-/dev/null}

#####################################################################
# BEGIN BUILD
#####################################################################
time ( 
echo "Begin ${SYSTEM_NAME_KEY} Setup." `date`
# Identify build context for the record...
echo $0 $SaveArgs
echo

echo LOGFILE is $LOGFILE
echo
echo PROD_DATE is $PROD_DATE
echo PROD_VERSION is $PROD_VERSION

# Run this to help with full derivation
echo ""
uname -a
echo ""

# Need it include some /bin/inq* stuff here to establish hardware used?

OS_TYPE_KEY=`uname -s | tr '[a-z]' '[A-Z]'`
case $OS_TYPE_KEY
in
  CLIX|IRIX )
    df -t
  ;;
  SUNOS4|SUNOS5 )
    df -a
  ;;
esac

echo ""
dates
echo ""


######################
# BEGIN PROC_TYPE LOOP
######################

for CURRENT_PROC_TYPE in $PROC_TYPE_LIST
do
  echo "Begin Setup for $CURRENT_PROC_TYPE"

  #
  # Set Environment
  #

  # dmb:02/03/92:Set up symbol that will be used in product.def
  PROC_TYPE=${CURRENT_PROC_TYPE}
  PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
  export PROC_TYPE PROC_TYPE_KEY CURRENT_PROC_TYPE

#  . ${SYSTEM_INFORMATION}/system.env
  echo "\$SYSTEM_BUILD = $SYSTEM_BUILD"

  echo ""
  echo "SetUp Build Tree for $CURRENT_PROC_TYPE Components"


  if [ ! -d $SYSTEM_BUILD_ROOT ]
  then
    echo "Can not find directory $SYSTEM_BUILD_ROOT" 2>&1
    echo "Making directory $SYSTEM_BUILD_ROOT"
    mkdir -p $SYSTEM_BUILD_ROOT
  fi


  #
  # Setup Components
  #
  echo "Begin Setup for $CURRENT_PROC_TYPE"
  echo "  Making $CURRENT_PROC_TYPE Directories"
  ( cd $SYSTEM_SOURCE

    if [ ! -d $SYSTEM_BUILD ]
    then
      echo "Can not find directory $SYSTEM_BUILD" 2>&1
      echo "Making directory $SYSTEM_BUILD"
      mkdir -p $SYSTEM_BUILD
    fi

    # dmb:11/06/91:Broke this out of if: Now files get linked each time

      # Moved here when this came into Build.sh
      # dmb:10/16/91: Added filter for info and log file directories
      find * -print |
          sed '/^sysinfo/d;/^prodinfo/d;/^log/d' |
          cpio -pvmudl $SYSTEM_BUILD

  ) 


  echo ""
  
  echo "Finished Setup for $CURRENT_PROC_TYPE"
  echo ""

done

######################
# BEGIN PROC_TYPE LOOP
######################


echo ""
echo "End ${SYSTEM_NAME_KEY} Setup." `date`
) 2>&1 | tee ${LOGFILE}

