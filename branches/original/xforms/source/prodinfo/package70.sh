###################################################################
## Shell script to package Products for Delivery
#  Updated for ISS70

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
# NOTE: This version makes one cpio file per DeliveryUnit.
#       These separate cpio files match prompts during installation.
#
# NOTE: This packaging script is an experiment in the separate script
#       for each product model. It handles all variations for this
#       product, however. It may be possible in the long run to 
#       maintain one single script for all variations of all products.
###################################################################
# The plan:
#
#   This is handled in $SYS_INFO/package
#   for Product in $ProdList
#   do
#   This is handled in $PROD_INFO/package 
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
#DeliveryUnitList="`find $SYSTEM_SOURCE/dcompinfo -type d -print |
#    sed 's/\/dcompinfo//;s/^.*\///'`"
# or these can also be read from a user supplied data (table) file(s).
# This could be useful when components must be built in a specific order.
##########################################################
#   This is $PROD_INFO/package 
##########################################################

# dmb:02/01/92 Original funclib location

# Set up environment

USAGE="`basename $0`: [options] [PROC_TYPE]"
USAGE2="\
   where PROC_TYPE is one element from the following list:\
     c100|c400|mips|sun4"


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

DEFAULT_PROC_TYPE_KEY=`echo $DEFAULT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
CURRENT_PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`

# dmb:01/28/92:Set up symbol that will be used in product.def
PROC_TYPE=${CURRENT_PROC_TYPE}
PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
export PROC_TYPE PROC_TYPE_KEY

#
# dmb:02/11/91:NOTE: We don't have room to copy files at present. We'll 
# start by trying to link them.
#
#OPER='cp '
#OPER='echo ln '
OPER='ln '


# Set Packaging Defaults based on Current Processor Type
echo DEFAULT_PROC_TYPE is $DEFAULT_PROC_TYPE
echo DEFAULT_PROC_TYPE_KEY is $DEFAULT_PROC_TYPE_KEY
echo CURRENT_PROC_TYPE is $CURRENT_PROC_TYPE
echo CURRENT_PROC_TYPE_KEY is $CURRENT_PROC_TYPE_KEY
echo PROC_TYPE is $PROC_TYPE
echo PROC_TYPE_KEY is $PROC_TYPE_KEY

# dmb:01/28/92:This section should probably move to system.env

# dmb:11/20/91: DELTOOLS folk (sw) say that Clipper blocks are used on both
#   archetectures, so we should only package from the CLIPPER for now.
case $PROC_TYPE_KEY
in
  C100 )
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c100
    ProcTypeKey=C100
    ProcSuffix=c1
    NewprodSuffix=sh
    NewprodPdefSuffix=def
    ;;
  C300 )
    ## For CLIX
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c300
    ProcTypeKey=C300
    ProcSuffix=c3
    NewprodSuffix=sh
    NewprodPdefSuffix=def
    ;;
  C400 )
    ## For CLIX
    ArchType=clipper
    ArchTypeKey=CLIPPER
    ProcType=c400
    ProcTypeKey=C400
    ProcSuffix=c4
    NewprodSuffix=sh
    NewprodPdefSuffix=def
    ;;
  MIPS )
    ArchType=mips
    ArchTypeKey=MIPS
# dmb:09/23/92:Should probably reflect MIPS R2000A/R3000 CPU.
# dmb:09/23/92:This will do for now...
    ProcType=mips
    ProcTypeKey=MIPS
    ProcSuffix=mi
    NewprodSuffix=sgi
    NewprodPdefSuffix=sgi

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
    NewprodSuffix=sun
# dmb:02/26/93:Changed to reflect ORB-mandated bundling
#    NewprodPdefSuffix=sun
    NewprodPdefSuffix=def

#    ECHO='/usr/5bin/echo '
    ;;
  * )
    echo "$PROC_TYPE_KEY delivery not supported yet." >&2
    exit 1
    ;;
esac


# DEFAULT_PROC_TYPE is the local processing host, so make any
# neccessary adjustments here.
case $DEFAULT_PROC_TYPE_KEY
in
  C100|C300|C400 )
    ## For CLIX
    ECHO='echo '
    ;;
  SUN4 )
    # For SUN
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
  read PROD_NAME?"Package which Product? "
fi

# What should the real default be?
PROD_NAME=${PROD_NAME:-`eval basename $PWD`}

#P_DEF=${PROD_INFO_DIR}/product.def
P_DEF=${PROD_INFO_DIR}/product.$NewprodPdefSuffix
INSTALL=${PROD_INFO_DIR}/install.sh
REMOVE=${PROD_INFO_DIR}/remove.sh

### set up the release version number ###
. $PROD_INFO_DIR/prodversion.sh


##################################################
echo "Package directories for ${PROC_TYPE} ${PROD_NAME} ${PROD_VERSION} on ${DEFAULT_PROC_TYPE}"
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
  echo "in package.sh"
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
  echo "Prep directories for $PROD_NAME $PROD_VERSION on ${PROC_TYPE}"
  echo
  ####################################################

  #########################################
  ## Clean out the Packaging Directories ##
  #########################################

  echo "  Cleaning directory $PROD_REL"
  rm -rf $PROD_REL


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

  # Get list of Release Directories : Is this really needed?

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

    # Create the needed packaging directory
    if [ ! -d $REL_DIR ]
    then
      echo "  Making directory $REL_DIR"
      PAS_f_mkdir $REL_DIR
    fi
  done


  #####################
  ## Get the files ##
  #####################

  echo
  echo "Getting $PROD_NAME files for Version $PROD_VERSION of $SYSTEM_NAME on ${PROC_TYPE}..."
  echo


  FILE_LIST="$ReleaseUnitList"

  for FFF in $FILE_LIST
  do
    ### actually copy or link each file
    eval echo "$OPER $PROD_BLD/$FFF 	 ${PROD_REL}/${FFF} "
    eval $OPER $PROD_BLD/$FFF ${PROD_REL}/${FFF}
  done


  ########################################################
  # PKG
  ########################################################
  echo
  echo "Pkg directories for $PROD_NAME $PROD_VERSION on ${PROC_TYPE}"
  echo
  ########################################################

  if [ ! -d "${PROD_DLVR}" ]
  then
    PAS_f_mkdir "${PROD_DLVR}"
  fi
  
  # cd $PROD_REL to get space requirement and make cpio file
  cd $PROD_REL
  
  # Cleanup should have already been done. May want to keep some 
  # failsafe checks, however. dmb:10/02/91.
  ########################################################
  ### Remove the menu_locations files before packaging
  ########################################################
  find . -type f \( -name menu_locations \
                 -o -name core           \
                 -o -name '*.cpio'       \
                 -o -name '*.lgdb' \)    \
      -print | xargs rm -f
  
  
  #############################################
  ## Bundle the files into one big cpio file
  #############################################
  
  DIR_LIST="$ReleaseDirectoryList"
  

# dmb:10/16/91:The wildcard allows us to get top level directory files.
# dmb:10/23/92:Added -c for delivery to MIPS
  find * -depth -print | cpio -covmud | compress > $PROD_FILE_LOC  
  
  
  #################################################
  ## See how much space is needed for delivery ...
  #################################################
#ksh
  COMPONENT_SPACE=`du -s . | cut -f1`  



  #################################
  ## ... and update the product.def file accordingly.
  #################################
  # dmb:10/16/91: This keeps us from being in the directory we're
  #  about to delete
  cd $PROD_INFO_DIR

#dmb:11/24/92:This causes problems for PLOAD in ISS70
#  eval PAS_f_update_file $P_DEF "${COMP_SIZE_VAR}="  "$COMPONENT_SPACE"

  PAS_f_update_pdef_space_table $DLVR_UNIT $PROC_TYPE_KEY $COMPONENT_SPACE

  echo "Removing Temporary Release Structure"
  rm -rf $PROD_REL

done



#############################################################
## Update the product.def file with the :
## 1. DELsize
## 2. version number
## 3. date ( in MM-DD-YYYY VAX format )
#############################################################
#############################################################

( cd $PROD_INFO_DIR

##############################
###  update DELsize in "product.def"
##############################
# This should be the minimum space needed to download the product if
# each question is answered 'no'. This requires looking at the prompts.
#
# The plan: DEL_SIZE_VAR=sum of 'deliver' components sizes
#
# This is definitely wrong, but safely honest
#eval PAS_f_update_file $P_DEF "${DEL_SIZE_VAR}="  "0"


MIN_SPACE=0

CompList="`PAS_f_get_pdef_table 'INSTALL.ITB' | tail +3 |
  awk -F'	' '$2 == \"deliver\" {print $1}'`"

for Comp in $CompList
do
  CompSpace="`PAS_f_get_pdef_table 'SPACE.ITB' | tail +3 |
    awk -F'	' '$1 == \"'$Comp'\" && \
               $2 == \"'$PROC_TYPE_KEY'\" {print $3}'`"

  #dmb:05/14/92: Added check for null results
  if [ -z "$CompSpace" ]
  then
    echo 1>&2
    echo "$0: ERROR: CompSpace is $CompSpace" 1>&2
    echo 1>&2
    exit 2
  fi

  MIN_SPACE=`expr $MIN_SPACE + $CompSpace`
done

# dmb:11/11/92:Move this here and kludge up PROC_TYPE sizes
# dmb:11/24/92:Additional kludge until DELTOOLS and PLOAD are ready
# dmb:01/25/93:Working around verdef's failure to recognize the
#  CLIPPER_ form of these for ISS70.
case "${ArchTypeKey}"
in
  "MIPS" )
    DEL_SIZE_VAR="${ArchTypeKey}_IRIX_DELsize"
   ;;
  "CLIPPER" )
# dmb:01/25/93:This would be the right way to do this...
# NOTE:Install and remove need to be coordinated with this change.
#    DEL_SIZE_VAR="${ArchTypeKey}_DELsize"
    DEL_SIZE_VAR="DELsize"
   ;;
  "SUN" )
    DEL_SIZE_VAR="${ArchTypeKey}_DELsize"
   ;;
esac

eval PAS_f_update_file $P_DEF "${DEL_SIZE_VAR}="  "$MIN_SPACE"


# dmb:11/24/92:These now create errors. Don't use this part. Use table.
# dmb:11/11/92:Added to kludge to set PROC_TYPE sizes
#DEL_SIZE_VAR="${PROC_TYPE_KEY}_DELsize"
#eval PAS_f_update_file $P_DEF "${DEL_SIZE_VAR}="  "$MIN_SPACE"

# Note possible cross check by stamping two different variables
# with the same information.

VAX_DATE="`date '+%d-%h-19%y' | tr '[a-z]' '[A-Z]'`"

##############################
###  update "product.def"
##############################
PAS_f_update_file $P_DEF "IDversion="     "$PROD_VERSION"
PAS_f_update_file $P_DEF "IDdate="        "$PROD_DATE"

#################################
###  update "install.sh"
#################################
PAS_f_update_file $INSTALL "PRODUCT_NAME="     "$PROD_NAME"
PAS_f_update_file $INSTALL "VERSION="     "$PROD_VERSION"
PAS_f_update_file $INSTALL "DATE="        "$VAX_DATE"

#################################
###  update "remove.sh"
#################################
PAS_f_update_file $REMOVE "PRODUCT_NAME="     "$PROD_NAME"
PAS_f_update_file $REMOVE "VERSION="     "$PROD_VERSION"
PAS_f_update_file $REMOVE "DATE="        "$VAX_DATE"


# dmb:10/23/92:Remove share.sh for ISS7.0
############
# Use install.sh for share.sh
############
#cp ${PROD_INFO_DIR}/install.sh   ${PROD_INFO_DIR}/share.sh

#########################################################
### Special kludge for Sun newprod:
###  Currently Sun newprod requires install.sun.
###  Newprod 5.0 requires install.sh be present.
# Should this be ln or cp? dmb:10/04/91: Changed to cp for new newprod.
#########################################################
####  NOTE! WARNING! NOTE! WARNING! NOTE! WARNING!  ####
# This kludge means that a single prodinfo directory must be used.
#########################################################
# dmb:01/07/93: Added case to prevent copying unneeded files for platform
#  unbundling
case $PROC_TYPE_KEY
in
  SUN4 )
    cp ${PROD_INFO_DIR}/install.sh   ${PROD_INFO_DIR}/install.$NewprodSuffix
    cp ${PROD_INFO_DIR}/remove.sh    ${PROD_INFO_DIR}/remove.$NewprodSuffix
# dmb:10/12/91:I dont think we need this file, but I don't know whether 
#  DELTOOLS will let us get on without it.
    #cp ${PROD_INFO_DIR}/share.sh     ${PROD_INFO_DIR}/share.$NewprodSuffix
  ;;
  MIPS )
### Special kludge for SGI_MIPS (MIPS, MIPS_IRIX) newprod:
  cp ${PROD_INFO_DIR}/install.sh   ${PROD_INFO_DIR}/install.$NewprodSuffix
  cp ${PROD_INFO_DIR}/remove.sh    ${PROD_INFO_DIR}/remove.$NewprodSuffix
# dmb:10/12/91:I dont think we need this file, but I don't know whether 
#  DELTOOLS will let us get on without it.
  #cp ${PROD_INFO_DIR}/share.sh     ${PROD_INFO_DIR}/share.$NewprodSuffix
  ;;
esac

#########################################################
### update the product.def's FILE INFORMATION section
#########################################################
# dmb:02/10/92: This needs work to handle multiple processor types
#               per archetecture.
# dmb:02/02/93:Original
FILE_LIST="`PAS_f_get_pdef_table 'FILE INFORMATION' |
  awk -F'	' '$3 ~ /^\"'$ArchTypeKey' / || $3 ~ /^\"ALL / {print $1};' -`"


#dmb:02/02/93:Adding unbundled packaging feature.
FILE_LIST="install.sh remove.sh $FILE_LIST"

if [ "$VERBOSE" ]
then
  echo "Updating product.def dates for $FILE_LIST"
fi  

for file in $FILE_LIST
do
# May want to use getfiledate from $DELTOOLS/node/nodelib
  sed "/^#$file/s/	[^	]*/	$VAX_DATE/" $P_DEF >$TMP
  mv $TMP $P_DEF
done
rm -f $TMP


echo

##########  end of adjusting files  ####################


#SPECIAL_FILES="  \
#    README       \
#    install.sh   \
#    install.sun  \
#    product.def  \
#    remove.sh    \
#    remove.sun   \
#    share.sh     \
#    "

# dmb:02/10/92: This needs work to handle multiple processor types
#               per archetecture.

SPECIAL_FILES="`PAS_f_get_pdef_table 'FILE INFORMATION' |
  awk -F'	' \
   '$3 !~ /compressed cpio/ && \
    ( $3 ~ /^\"'$ArchTypeKey' / || $3 ~ /^\"ALL / )\
     {print $1};' -`"

# dmb:02/02/93: Adding unbundled packaging support. Kwik Kulgde...
SPECIAL_FILES="install.sh remove.sh $SPECIAL_FILES"

if [ "$VERBOSE" ]
then
  echo "Updating SPECIAL_FILES: $SPECIAL_FILES"
fi  

for FFF in $SPECIAL_FILES
do
  echo "cp ${PROD_INFO_DIR}/$FFF $PROD_DLVR"
  cp ${PROD_INFO_DIR}/$FFF $PROD_DLVR
done

# dmb:02/26/93:Adding yet one more workaround...
  if [ "$CURRENT_PROC_TYPE" = 'mips' ]
  then
  # dmb:02/02/93: Adding unbundled packaging support. One last Kulgde...
set -x
    cp ${P_DEF} $PROD_DLVR/product.def
set +x
  fi
echo

) #cd $ORIG_DIR 

echo
