###################################################################
## Shell script to check Product Build
## NOTE: This script combines both prep and pkg steps.
#
# History:
# 10/09/91   dmb     Modified for HELP from XFORMS.
#                    First cut will use internal lists. Second will use
#                    external filed lists or rules.
# 10/10/91   dmb     Combined prep and pkg. 
#                    Using external package.lis. Will convert to itb
#
###################################################################
# NOTE: This version makes one cpio file per Component.
#       These separate cpio files match prompts during installation.
#
# NOTE: This packaging script is an experiment in the separate script
#       for each product model. It handles all variations for this
#       product, however. It may be possible in the long run to 
#       maintain one single script for all variations of all products.
###################################################################
# The plan:
#
#   This is handled in $SYS_INFO/check
#   for Product in $ProdList
#   do
#   This is handled in $PROD_INFO/check 
#     for Arch in $ArchList
#     do
#       for DlvrComp in $ProdDlvrCompList
#       do
#         prep
#         pkg
#       done
#     done
#   done
#
# These can be inferred from the source platform itself (Default)
#ProductList="`find $SYSTEM_SOURCE/prodinfo -type d -print |
#    sed 's/\/prodinfo//;s/^.*\///'`"
#ComponentList="`find $SYSTEM_SOURCE/dcompinfo -type d -print |
#    sed 's/\/dcompinfo//;s/^.*\///'`"
# or these can also be read from a user supplied data (table) file(s).
# This could be useful when components must be built in a specific order.
##########################################################
#   This is $PROD_INFO/check 
##########################################################

# dmb:02/01/92 Original funclib location

# Set up environment

USAGE="`basename $0`: [options] [PROC_TYPE]"
USAGE2="\
   where PROC_TYPE is one element from the following list:\
     c100|c300|c400|sun4"


CURRENT_PROC_TYPE=${CURRENT_PROC_TYPE}

VERBOSE=${VERBOSE:-""}
if [ "$VERBOSE" ]
then
  NULL=/dev/tty
else
  NULL=/dev/null
fi
export NULL

if [ $# -ne 1 ]
then
      echo "$USAGE" >&2
      echo "$USAGE2" >&2
      exit 1
else
    CURRENT_PROC_TYPE="$1"
    shift
fi

#dmb:05/14/92:Added these to make sure variables follow the rules.
DEFAULT_PROC_TYPE=`echo $DEFAULT_PROC_TYPE | tr '[A-Z]' '[a-z]'`
CURRENT_PROC_TYPE=`echo $CURRENT_PROC_TYPE | tr '[A-Z]' '[a-z]'`

DEFAULT_PROC_TYPE_KEY=`echo $DEFAULT_PROC_TYPE | tr '[a-z]' '[A-Z]'`
CURRENT_PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr '[a-z]' '[A-Z]'`

# dmb:01/28/92:Set up symbol that will be used in product.def
PROC_TYPE=${CURRENT_PROC_TYPE}
PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr '[a-z]' '[A-Z]'`
export PROC_TYPE PROC_TYPE_KEY

#
# dmb:02/11/91:NOTE: We don't have room to copy files at present. We'll 
# start by trying to link them.
#
#OPER='cp '
#OPER='echo ln '
OPER='ln '


# Set Packaging Defaults based on Current Processor Type
echo DEFAULT_PROC_TYPE is $DEFAULT_PROC_TYPE         >>$NULL
echo DEFAULT_PROC_TYPE_KEY is $DEFAULT_PROC_TYPE_KEY >>$NULL
echo CURRENT_PROC_TYPE is $CURRENT_PROC_TYPE         >>$NULL
echo CURRENT_PROC_TYPE_KEY is $CURRENT_PROC_TYPE_KEY >>$NULL
echo PROC_TYPE is $PROC_TYPE                         >>$NULL
echo PROC_TYPE_KEY is $PROC_TYPE_KEY                 >>$NULL

# dmb:01/28/92:This section should probably move to system.env

# dmb:11/20/91: DELTOOLS folk (sw) say that Clipper blocks are used on both
#   archetectures, so we should only check from the CLIPPER for now.
case $PROC_TYPE_KEY
in
  I486 )
    ArchType=sco
    ArchTypeKey=SCO
    ProcType=i486
    ProcTypeKey=I486
    ProcSuffix=i4
    ;;
  I386 )
    ArchType=sco
    ArchTypeKey=SCO
    ProcType=i386
    ProcTypeKey=I386
    ProcSuffix=i3
    ;;
  C100 )
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c100
    ProcTypeKey=C100
    ProcSuffix=c1
    ;;
  C300 )
    ## For CLIX
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c300
    ProcTypeKey=C300
    ProcSuffix=c3
    ;;
  C400 )
    ## For CLIX
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c400
    ProcTypeKey=C400
    ProcSuffix=c4
    ;;
  HP9000 )
    ## For HPUX
    ArchType=hpux
    ArchTypeKey=HPUX
    ProcType=hp9000
    ProcTypeKey=HP9000
    ProcKey=hp

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
    ArchType=sun
    ArchTypeKey=SUN

# This probably neds to expand to cover sun4c, sun2, etc.
    ProcType=sun4
    ProcTypeKey=SUN4
    ProcSuffix=s4

#    ECHO='/usr/5bin/echo '
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
    echo "$PROC_TYPE_KEY builds not supported yet." >&2
    exit 1
    ;;
esac


# DEFAULT_PROC_TYPE is the local processing host, so make any
# neccessary adjustments here.
case $DEFAULT_PROC_TYPE_KEY
in
  I486 )
    ## For SCO
    ECHO='echo '
    ;;
  I386 )
    ## For SCO
    ECHO='echo '
    ;;
   HP9000)
    ## For HPUX
    ECHO='echo '
    ;;
  C100|C300|C400 )
    ## For CLIX
    ECHO='echo '
    ;;
  SUN4|I86PC )
    # For SUN, SPARC_SOLARIS, and INTEL_SOLARIS
    ECHO='/usr/5bin/echo '
    ;;
  MIPS )
    ## For MIPS (SGI)
    ECHO='echo '
    ;;
  * )
    echo "Packaging on a $DEFAULT_PROC_TYPE_KEY is not supported yet." >&2
    exit 1
    ;;
esac


# Set the environment
if [ -f "${SYSTEM_INFORMATION}/system.env" ]
then
  . ${SYSTEM_INFORMATION}/system.env
else
  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
  exit 2
fi

# Get funclib into the environment.
if [ -f "${SYSTEM_PRODUCT_INFORMATION}/PAS_pkglib.sh" ]
then
  . ${SYSTEM_PRODUCT_INFORMATION}/PAS_pkglib.sh
else
  echo "Can not find file ${SYSTEM_PRODUCT_INFORMATION}/PAS_pkglib.sh" 1>&2
  exit 2
fi

# Moved to take advantage of system.env if needed
if [ -z "$TMPDIR" ]
then
  TMPDIR=/usr/tmp
  export TMPDIR
fi
PAS_f_mkdir $TMPDIR
TMP="$TMPDIR/tmp$$"


if [ -z "${PROD_NAME}" ]
then
  read PROD_NAME?"Check which Product? "
fi

# What should the real default be?
PROD_NAME=${PROD_NAME:-`eval basename $PWD`}

# dmb:Added
PROD_INFO_DIR=$SYSTEM_SOURCE/prodinfo/${PROD_NAME}

P_DEF=${PROD_INFO_DIR}/product.def
INSTALL=${PROD_INFO_DIR}/install.sh
REMOVE=${PROD_INFO_DIR}/remove.sh

### set up the release version number ###
. $PROD_INFO_DIR/prodversion.sh


##################################################
if [ "$VERBOSE" ]
then
  echo "Check ${PROD_NAME} ${PROC_TYPE} ${PROD_VERSION} on ${DEFAULT_PROC_TYPE}" >>$NULL
else
  echo "Check ${PROD_NAME} ${PROC_TYPE}" >>$NULL
fi
##################################################
  ComponentList="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $2 == \"'${ProcTypeKey}'\" || $2 == \"'${ArchTypeKey}'\" || \
          $2 == \"ALL\" ) \
       {print $1;} \
     }' - |
     sort -u `"

if [ "$VERBOSE" ]
then
  echo "in check.sh"
  echo "\$PROD_NAME is $PROD_NAME"
  echo "\$PROD_VERSION is $PROD_VERSION"
  echo "\$PROD_SRC is $PROD_SRC"
  echo "\$PROD_INFO_DIR is $PROD_INFO_DIR"
  echo "\$DEFAULT_PROC_TYPE is $DEFAULT_PROC_TYPE"
  echo "\$DEFAULT_PROC_TYPE_KEY is $DEFAULT_PROC_TYPE_KEY"
  echo "\$CURRENT_PROC_TYPE is $CURRENT_PROC_TYPE"
  echo "\$CURRENT_PROC_TYPE_KEY is $CURRENT_PROC_TYPE_KEY"
  echo "\$PROC_TYPE is $PROC_TYPE"
  echo "\$PROC_TYPE_KEY is $PROC_TYPE_KEY"
  echo "\$PROD_BLD is $PROD_BLD"
  echo "\$PROD_REL is $PROD_REL"
  echo "\$PROD_DLVR is $PROD_DLVR"
  echo "\$ComponentList is $ComponentList"
fi

for Component in $ComponentList
do

  ####################################################
  # PREP
  ####################################################
  echo
  echo " Check $PROD_NAME $Component ${PROC_TYPE} directories..."
  ####################################################

#  #########################################
#  ## Clean out the Packaging Directories ##
#  #########################################
#
#  echo "  Cleaning directory $PROD_REL"
#  rm -rf $PROD_REL
#
#
  DLVR_UNIT="$Component"

# Do we really need this?
  DLVR_UNIT_KEY="`echo $DLVR_UNIT | tr '[a-z]' '[A-Z]'`"

  PROD_FILE=${DLVR_UNIT}.p${ProcSuffix}
  PROD_FILE_LOC=${PROD_DLVR}/${PROD_FILE}

  COMP_SIZE_VAR="${PROC_TYPE_KEY}_${DLVR_UNIT}_size"


  # Get list of Release Units

  ReleaseUnitList="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ProcTypeKey}'\" || $2 == \"'${ArchTypeKey}'\" || \
          $2 == \"ALL\" ) ) \
       {print $3;} \
     }' - |
     sort -u `"

#  # Get list of Release Directories : Is this really needed?

  ReleaseDirectoryList="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ProcTypeKey}'\" || $2 == \"'${ArchTypeKey}'\" || \
          $2 == \"ALL\" ) ) \
       {print $3;} \
     }' - |
    sed 's/\/[^/]*$//' | sort -u`"


  if [ "$VERBOSE" ]
  then
    echo "For Component $Component"
    echo "  \$ReleaseDirectoryList is $ReleaseDirectoryList"
    echo "  \$ReleaseUnitList is $ReleaseUnitList"
    echo "  \$PROD_FILE_LOC is $PROD_FILE_LOC"
  fi


  ###################################
  ## Set up the packaging directories
  ###################################

  MKDIR_LIST="$ReleaseDirectoryList"

  for FFF in $MKDIR_LIST
  do
    eval BLD_DIR=$PROD_BLD/$FFF
    eval REL_DIR=$PROD_REL/$FFF

    # Check for Build directory
    if [ ! -d $BLD_DIR ]
    then
      echo "`basename $0`: Can not find directory $BLD_DIR" >&2
      exit 2
    fi

#    # Create the needed packaging directory
#    if [ ! -d $REL_DIR ]
#    then
#      echo "$0: Cannot find directory $REL_DIR"
#      exit 2
##      PAS_f_mkdir $REL_DIR
#    fi
  done


  #####################
  ## Check the files ##
  #####################

  echo " Check $PROD_NAME $Component ${PROC_TYPE} files..."


  FILE_LIST="$ReleaseUnitList"

  for FFF in $FILE_LIST
  do
    OPER='\ls -ls'
    ### actually check for presence of each file
    eval echo "$OPER $PROD_BLD/$FFF"                 >>$NULL
    eval $OPER $PROD_BLD/$FFF >/dev/null
  done

#dmb:05/14/92: Lets see if we can automatically inspect these...
#   This seems to do fine on CLIPPER. It doesn't seem to do so well
#   for SUN. Sun executables show up as data.
ProcSufKey="`echo $ProcSuffix | tr '[a-z]' '[A-Z]'`"
# dmb:05/18/92: Trying to improve on iar check. Needs command line 
# argument for testing level.
EXE_FILES=""

  echo " Check $PROD_NAME $Component ${PROC_TYPE} executables..."
# dmb:05/18/92: First, look for executable type files
# dmb:07/01/92: Another SUN kludge. Remove "executable shell script"s
#               from EXE_FILES list.
  echo "   file check"
  EXE_FILES="`for FFF in $FILE_LIST
  do
    OPER='\file'
    ### actually check for presence of each file
    eval echo \"$OPER $PROD_BLD/$FFF\"                 >>$NULL
    eval $OPER $PROD_BLD/$FFF
  done | grep -i executable |
  sed '/executable shell script/d' |
  cut -f1 -d:`"

#echo EXE_FILES=$EXE_FILES
# dmb:06/30/92:Add SUN kludge. Sun file reports executables as 'sparc',
#     not sun4.
  if [ "${PROC_TYPE}" = 'sun4' ]
  then
    ProcSufKey='sparc '
  else
    ProcSufKey=" $ProcSufKey "
  fi

# dmb:05/18/92: Next, check them for the correct processor type
  for FFF in $EXE_FILES
  do
# dmb:03/05/93:Added -i for SPARC
    \file $FFF | grep -i -v "$ProcSufKey"
#    \file $FFF | grep -v "$ProcSufKey"
  done

#dmb:05/18/92:Skip the iar check until we figure out what we need it
# to do for us. 

  echo "   skipping iar check"
  continue


#dmb:05/18/92: Now check that the executables are made of the right stuff
#dmb:05/15/92:Experimental. This isn't quite working correctly yet. There
# are problems in filtering out unwanted data.
  echo "   iar check"
  for FFF in $EXE_FILES
  do
    OPER='\iar'
    ### actually check for presence of each file
  echo $FFF
    eval $OPER $FFF | tr '[A-Z]' '[a-z]' |
      grep -v "$PROC_TYPE"
  done 


done
