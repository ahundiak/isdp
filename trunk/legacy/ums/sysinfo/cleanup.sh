# This script cleans up the entire System Build Space.
# For now it will be empty... Much more very soon. dmb:09/25/91

# Need to add cmd line args to contiro ComponentList and ProductList.
#  File? Internal Rule? External Rule?

#USAGE="`basename $0`: [options] [PlatArch]"
USAGE="`basename $0`: [options] [PlatArch]"
USAGE2="   where PlatArch is a DelArch key"

ArchTypeList=''
PlatArch=""
ARGS=''
FontClean=''
FullClean=''
TotalClean=''
for arg in $*
do
  case $arg
  in
    -F )
     FontClean=True
     shift
     ;;
    -f )
     FullClean=True
     shift
     ;;
    -t )
     TotalClean=True
     shift
     ;;
    -v )
     VERBOSE=True
     shift
     ;;
    -* )
      echo "$USAGE" >&2
      echo "$USAGE2" >&2
      exit 1
     ;;
    * )
    ArchTypeList="$ArchTypeList $1"
    shift 
     ;;
  esac
done


if [ -z "${ArchTypeList}" ]
then
  ArchTypeList="${PROC_TYPE_LIST:-$DEFAULT_PROC_TYPE}"
fi


# Get current environment
if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
  exit 2
fi

# These can be inferred from the source platform itself (Default)
#ProductList="`find $SYSTEM_SOURCE/*/prodinfo -type d -print` |
#    sed 's/\/prodinfo//;s/^.*\///'`"
#ComponentList="`find $SYSTEM_SOURCE/*/compinfo -type d -print`"
#    sed 's/\/compinfo//;s/^.*\///'`"
# or these can also be read from a user supplied data (table) file(s).

#set -x

# This could be useful when components must be built in a specific order.
PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"


#ComponentList="`<${COMPONENT_FILE_NAME}`"
# dmb:11/06/91:Lets experiment with this a while.
ComponentList="*"


ProductList="`<${PRODUCT_FILE_NAME}`"

echo ""
echo "Begin ${SYSTEM_NAME_KEY} Clean Up." `date`
echo ""
echo " Cleaning Up Source Components"

export SYSTEM_SOURCE
(
#set -x
cd $SYSTEM_SOURCE

echo $PWD

## Fast method
if [ "$VERBOSE" ]
then
  echo "find $ComponentList -type d -print | sort -u"
fi

for Dir in `find $ComponentList -type d -print | sort -u`
do
  if [ "$VERBOSE" ]
  then
    echo "    Component Source Directory is $SYSTEM_SOURCE/$Dir"
  fi

  ( cd $SYSTEM_SOURCE/$Dir;
    pwd
    set -x
    rm -f *.[ao] *~ core 
    set +x
  )
done
)

if [ "$TotalClean" ]
then
  # dmb:09/25/91:This will have to be softened somewhat. See XFORMS cleanups.
  echo rm -rf ${SYSTEM_BUILD_ROOT}
  set -x
  rm -rf ${SYSTEM_BUILD_ROOT}
  set +x
  exit
fi


for ArchType in $ArchTypeList
do
  echo "Begin Clean up for $ArchType"

    #
    # Set Environment
    #

CURRENT_PROC_TYPE=$ArchType
export CURRENT_PROC_TYPE

# Get current environment
if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
  exit 2
fi

  echo ""
  echo " Cleaning Up $ArchType Components"


  (cd $SYSTEM_BUILD
  
  ## Fast method
  if [ "$VERBOSE" ]
  then
    echo "find $ComponentList -type d -print | sort -u"
  fi
  
  for Dir in `find $ComponentList -type d -print | sort -u`
  do
    if [ "$VERBOSE" ]
    then
      echo "    Component Build Directory is $SYSTEM_BUILD/$Dir"
    fi
  
    ( cd $SYSTEM_BUILD/$Dir;
      pwd
# Need some way to remove all generated files - bin, makefiles, etc.
      rm -f *.[ao] *~ core 
    )
  done
  )

  echo ""
  echo "Finished Clean Up for $ArchType"
  echo ""

done

echo ""
echo "Finished ${SYSTEM_NAME_KEY} Clean Up." `date`
echo ""
