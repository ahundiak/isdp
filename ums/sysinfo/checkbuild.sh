# This is the Build Check script for the entire Project.

# dmb:05/14/92:This needs the same kind of check level logic used in
#  checkinst.sh
###################
# History:
# 09/24/91   dmb     Freely adapted from XFORMS Project build.sh
#                    The basic build model has been modified to support
#                    multiple target archetectures.
# 10/15/91   dmb     Separated the names of the makefiles from the 
#                    components list.  All components have a file named
#                    'makefile'
# 11/11/91   dmb     Added -l switch for logfile.
# 04/16/92   dmb     Added $MAKEMAKE and $SaveArgs
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
# These can be inferred from the source platform itself (Default)
#ProductList="`find $SYSTEM_SOURCE/*/prodinfo -type d -print |
#    sed 's/\/prodinfo//;s/^.*\///'`"
#ComponentList="`find $SYSTEM_SOURCE/*/compinfo -type d -print |
#    sed 's/\/compinfo//;s/^.*\///'`"
#
# or these can also be read from a user supplied data (table) file(s).
# This could be useful when components must be built in a specific order.
#


# For debugging the build script and makefiles...
#MAKE='make -e -n'
# For real builds...
MAKE='make -e'

ARGS=''
DBG=''
ALL_SUPPORTED_PROC_TYPES=''
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
    -a )
     ALL_SUPPORTED_PROC_TYPES='y'
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


# dmb:04/28/92: Experimental
ProcTypeList="$PROC_TYPE_LIST"

#dmb:01/27/92:Temporary Kludge
ProcTypeList="$ProcTypeList"

# dmb:05/13/92: Removed
# dmb:02/03/92:Set up symbol that will be used in product.def
#PROC_TYPE=${CURRENT_PROC_TYPE}
#PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
#export PROC_TYPE PROC_TYPE_KEY

# Show System Version here
#. $PRODINFO/set_pvers.sh
echo "Current Product Version and Date are: "
. $PRODINFO/prodversion.sh -v

#####################################################################
# Begin CHECK SYSTEM BUILD
#####################################################################
time (
echo "Begin ${SYSTEM_NAME_KEY} Build Check." `date`
# Identify build context for the record...
uname -a
echo $0 $SaveArgs
echo



# Set logfile: Default is to screen
LOGFILE=${LOGFILE:-/dev/null}
echo LOGFILE is $LOGFILE
echo PROD_VERSION is $PROD_VERSION
#echo DBG is $DBG

# Run this to help with full derivation
echo ""
dates
echo ""
# dmb:11/06/91:Need to include exceptions file here for notes on workarounds
# like libxc and FS.
######################
# Begin ARCH_TYPE LOOP
######################
#dmb:05/14/92: Would CURRENT_PROC_TYPE_LIST be clearer than PROC_TYPE_LIST?
#   Use PROC_TYPE_LIST for build, SUPPORTED_PROC_TYPE_LIST for package.
#dmb:01/14/93:Adding -a switch to check all supported proc types.
#for CURRENT_PROC_TYPE in $PROC_TYPE_LIST

if [ "$ALL_SUPPORTED_PROC_TYPES" = 'y' ]
then
  PROC_TYPE_CHECK_LIST=$SUPPORTED_PROC_TYPE_LIST
else
  PROC_TYPE_CHECK_LIST=$PROC_TYPE_LIST
fi

#echo ALL_SUPPORTED_PROC_TYPES is $ALL_SUPPORTED_PROC_TYPES
#echo SUPPORTED_PROC_TYPE_LIST is $SUPPORTED_PROC_TYPE_LIST
#echo PROC_TYPE_LIST is $PROC_TYPE_LIST
#echo PROC_TYPE_CHECK_LIST is $PROC_TYPE_CHECK_LIST

for CURRENT_PROC_TYPE in $PROC_TYPE_CHECK_LIST
do
  echo "Begin Build Check for $CURRENT_PROC_TYPE"

  #
  # Set Environment
  #

  # dmb:02/03/92:Set up symbol that will be used in product.def
  PROC_TYPE=${CURRENT_PROC_TYPE}
  PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
  export PROC_TYPE PROC_TYPE_KEY CURRENT_PROC_TYPE

  . ${SYSTEM_INFORMATION}/system.env

  echo ""
  echo "Check Build Tree for $CURRENT_PROC_TYPE Components"
  echo " under $SYSTEM_BUILD"

  if [ ! -d $SYSTEM_BUILD_ROOT ]
  then
    echo "Can not find directory $SYSTEM_BUILD_ROOT" 1>&2
#    mkdir -p $SYSTEM_BUILD_ROOT
    exit 2
  fi


if [ "$CheckBuildSourceFiles" = 'y' ]
then
# dmb:05/14/92: Since build.sh sets these files out into the build
# structure on each pass, we won't start out checking them. There
# would probably be problems with OLD_PROTO and other generated files
# anyway.
  #
  # Setup Components
  #

  echo "Begin Check for $CURRENT_PROC_TYPE"
  echo "  Checking $CURRENT_PROC_TYPE Directories"
  ( cd $SYSTEM_SOURCE

    if [ ! -d $SYSTEM_BUILD ]
    then
      echo "Can not find directory $SYSTEM_BUILD" 1>&2
      echo "Checking directory $SYSTEM_BUILD"
      mkdir -p $SYSTEM_BUILD
    fi

    # dmb:11/06/91:Broke this out of if: Now files get linked each time

      # Moved here when this came into Build.sh
      # dmb:10/16/91: Added filter for info and log file directories
      find * -print |
          sed '/^sysinfo/d;/^prodinfo/d;/^log/d' |
          cpio -pvmudl $SYSTEM_BUILD

  )
fi

if [ "$CheckMessageFiles" = 'y' ]
then
# dmb:05/14/92: This would probably be a very good thing to do, but
will require some thought. It might be easiest to add a special target
# in the makefiles for this.

  #
  # MESSAGE FILES
  #
  echo ""
  echo "  Checking Message files for $CURRENT_PROC_TYPE Components"
  ######################
  # BEGIN COMPONENT LOOP
  ######################
  for Component in $ComponentList
  do
    if [ "$VERBOSE" ]
    then
      echo Component is $Component
    fi

    ( cd $SYSTEM_BUILD/$Component;
      pwd
      # dmb:11/01/91: Check for DEBUG here
      if [ "$DBG" ]
      then
        DOPT="-DDEBUG"
      else
        DOPT=""
      fi
      export DOPT

      #
      # MESSAGE MAKEMAKE 
      #
      # Look for .m files with a target named 'messages'.
      if [ `\ls *.m 2>/dev/null | wc -c` -ne 0 ]
      then
        if grep '^messages:' *.m >/dev/null
        then
          echo "   ${MAKEMAKE} *.m makefile"
          ${MAKEMAKE} *.m makefile

          echo "   COPT=$COPT DOPT=$DOPT"
          echo "   $MAKE messages"
          $MAKE messages
        fi
      fi
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################
fi

CheckMakeFiles=y
if [ "$CheckMakeFiles" = 'y' ]
then
# dmb:05/14/92: This would probably be a very good thing to do, but
# will also require some thought.
  #
  # MAKEMAKE
  #
  echo ""
  echo "Check $CURRENT_PROC_TYPE makefiles..."
  ######################
  # BEGIN COMPONENT LOOP
  ######################
  for Component in $ComponentList
  do
    if [ "$VERBOSE" ]
    then
      echo Component is $Component
    fi

    ( cd $SYSTEM_BUILD/$Component;
#      pwd
      if [ `\ls *.m 2>/dev/null | wc -c` -ne 0 ]
      then
        if [ "$VERBOSE" ]
        then
          echo "   \ls $SYSTEM_BUILD/$Component/makefile"
        fi

        if ls $SYSTEM_BUILD/$Component/makefile >/dev/null
        then
          :
        else
          echo "$0: WARNING: Cannot find $SYSTEM_BUILD/$Component/makefile" 1>&2
        fi

#        ${MAKEMAKE} *.m makefile
      fi
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################
fi

CheckProtoFiles=n
if [ "$CheckProtoFiles" = 'y' ]
then
# dmb:05/14/92: This would probably be a very good thing to do, but
# will also require some thought.
  #
  # MAKE ANSI PROTOTYPE HEADERS
  #
  # Perhaps this can be done at the same time makemake is run?  
  echo ""
  echo "  Checking $CURRENT_PROC_TYPE ANSI-C Prototypes"
  echo ""

  ####################
  # BEGIN COMPONENT LOOP
  ####################
  for Component in $ComponentList
  do
    if [ "$VERBOSE" ]
    then
      echo Component is $Component
    fi

    ( cd $SYSTEM_BUILD/$Component;
      pwd
      echo "   make ptypes for $Component."

      if [ `\ls [Mm]ake* 2>/dev/null | wc -c` -ne 0 ]
      then
        # Look to see if this makefile knows this target
        if grep ptypes makefile >/dev/null
        then
          echo "   COPT=$COPT DOPT=$DOPT"
          echo
          echo "        WARNING! DO NOT INTERRUPT (^C) yet"
          echo
          echo "   $MAKE ptypes"
          trap "" 2 3
          $MAKE ptypes
          echo "   made ptypes"
          echo
          echo "        OK TO INTERRUPT (^C) now"
          echo
          trap -
        fi
      fi
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################
fi

CheckBuiltFiles=n
if [ "$CheckBuiltFiles" = 'y' ]
then
# dmb:05/14/92: This would probably be a very good thing to do, but
# will also require some thought.
  #
  # MAKE
  #
  echo ""
  echo "  Checking $CURRENT_PROC_TYPE Components"
  for Component in $ComponentList
  do
    if [ "$VERBOSE" ]
    then
      echo Component is $Component
    fi

    ( cd $SYSTEM_BUILD/$Component;
      pwd
      # dmb:11/01/91: Check for DEBUG here
      if [ "$DBG" ]
      then
        DOPT="-DDEBUG"
      else
        DOPT=""
      fi
      export DOPT

      # dmb:11/01/91: Save this. Could look fou build.sh script and run it
      # before or instead of makefile.

  #dmb:04/01/92: Could use this for table-driven makefile name.
  #dmb:04/01/92: Put ArchKey, ProcKey, and BuildVariant, etc into table
  #dmb:04/01/92: and drive makefile name, params, etc. at build time.

#      echo "   compinfo/build.sh for $Component. \$ARGS = $ARGS" )
#      echo "   $MAKE -f $makefile \$ARGS = $ARGS"
#      echo "   $MAKE -f $makefile"
#      $MAKE -f $makefile

      if [ `\ls [Mm]ake* 2>/dev/null | wc -c` -ne 0 ]
      then
        echo "    COPT=$COPT DOPT=$DOPT"
        echo "    $MAKE"
        $MAKE


  #
  # MAKE SHARABLE
  #
  # Look to see if this makefile knows this target
#dmb:04/01/92:Hold this for now: It causes double chg_idents
#        if egrep -e '^sharable:' makefile >/dev/null
#        then
#          echo "   COPT=\"$COPT $PIC\" DOPT=$DOPT"
#          echo "   $MAKE sharable"
#          $MAKE sharable
#        fi

  #
  # MAKE PROMOTE
  #
  # Look to see if this makefile knows this target
        if grep promote makefile >/dev/null
        then
          echo "   COPT=$COPT DOPT=$DOPT"
          echo "   $MAKE promote"
          $MAKE promote
        fi
      fi
    )
  done
  echo ""
fi
  
#dmb:05/14/92: As a matter of fact, that doesn't look useful anymore.
  # NOTE: Temporary kludge until $SYSTEM_NAME symbol is straightened out.
#  export SYSTEM_NAME=$SYSTEM_BUILD
#dmb:05/14/92:This looks like a typo...
#  export $SYSTEM_NAME=$SYSTEM_BUILD

  echo ""
  echo "Checking $SYSTEM_NAME_KEY $CURRENT_PROC_TYPE Components"
  for Product in $ProductList
  do
    ( 
#      export PROD_NAME=$Product
      echo
      echo "Check $Product $CURRENT_PROC_TYPE" >>$NULL
      PROD_NAME=$Product $SYSTEM_SOURCE/prodinfo/checkbuild.sh $CURRENT_PROC_TYPE
    )
  done
  echo ""


  echo "Finished Build Check for $CURRENT_PROC_TYPE"
  echo ""

done

######################
# End of ARCH_TYPE LOOP
######################


echo ""
echo "End ${SYSTEM_NAME_KEY} Build Check." `date`
) 2>&1 | tee ${LOGFILE}

#####################################################################
# End of CHECK SYSTEM BUILD
#####################################################################
