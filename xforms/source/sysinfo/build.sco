#set -x
# This is the build script for the entire Project.
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
MAKE='make -e -f makefile.sco'

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


#dmb:04/08/93:Try removing this, too
#if [ -f "${SYSTEM_INFORMATION}/system.env" ]
#then
#  . ${SYSTEM_INFORMATION}/system.env
#else
#  echo "Can not find file ${SYSTEM_INFORMATION}/system.env" 1>&2
#  exit 2
#fi


PRODUCT_FILE_NAME="${SYSTEM_INFORMATION}/product.lis"
COMPONENT_FILE_NAME="${SYSTEM_INFORMATION}/component.lis"

#dmb:04/01/92: Put PAS_f_get_component_list here?
ComponentList="`<${COMPONENT_FILE_NAME}`"

ProductList="`<${PRODUCT_FILE_NAME}`"


# dmb:04/28/92: Experimental
ProcTypeList="$PROC_TYPE_LIST"

#dmb:04/08/93:Removed
#dmb:01/27/92:Temporary Kludge
#ProcTypeList="$ProcTypeList"

# dmb:05/13/92: Removed
# dmb:02/03/92:Set up symbol that will be used in product.def
#PROC_TYPE=${CURRENT_PROC_TYPE}
#PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
#export PROC_TYPE PROC_TYPE_KEY

# Set Pvers here?
. $PRODINFO/set_pvers.sh

# dmb:01/14/93:Added Build Comments

comments_tmp=comments$$
# dmb:01/14/93:Its much cheaper to always open the file.
>${comments_tmp}

echo ${NO_NEWLINE} "Enter comments into the Build Log? (y/n) [n]: ${CR}"
read do_comments
do_comments=${do_comments:-n}
if [ $do_comments = 'y' -o $do_comments = 'Y' ]
then

  $EDITOR ${comments_tmp}

fi

# dmb:01/14/93: Moved LOGFILE setup to outer shell
# Set logfile: Default is to screen
LOGFILE=${LOGFILE:-/dev/null}

#echo LOGFILE is $LOGFILE
#echo PROD_DATE is $PROD_DATE
#echo PROD_VERSION is $PROD_VERSION
#echo DBG is $DBG

#####################################################################
# BEGIN BUILD
#####################################################################
#dmb:08/03/94:Adding braces {} to capture times
#dmb:08/03/94:Changing outer parens () to braces {}
{ time {
echo "Begin ${SYSTEM_NAME_KEY} Build." `date`
# Identify build context for the record...
echo $0 $SaveArgs
echo

echo LOGFILE is $LOGFILE
echo
echo PROD_DATE is $PROD_DATE
echo PROD_VERSION is $PROD_VERSION

# dmb:01/14/93: Added Build Comments
echo
#echo "cat ${comments_tmp}"

if [ $do_comments = 'y' -o $do_comments = 'Y' ]
then

  cat << !end_of_comment_header! # >>${comments_tmp}
--------------------
Begin Build Comments
--------------------
!end_of_comment_header!

  cat ${comments_tmp}

  cat << !end_of_comment_footer! # >>${comments_tmp}
---------------------
End of Build Comments
---------------------
!end_of_comment_footer!

fi

# dmb:01/14/93:Added for Build Comments. May need to move this up.
# dmb:02/25/93:Moved up.
rm -f ${comments_tmp}

# Run this to help with full derivation
echo ""
uname -a
echo ""

# Need it include some /bin/inq* stuff here to establish hardware used?

case $OS_KEY
in
  CLIX|IRIX|SCO )
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
  echo "Begin Build for $CURRENT_PROC_TYPE"

  #
  # Set Environment
  #

  # dmb:02/03/92:Set up symbol that will be used in product.def
  PROC_TYPE=${CURRENT_PROC_TYPE}
  PROC_TYPE_KEY=`echo $CURRENT_PROC_TYPE | tr "[a-z]" "[A-Z]"`
  export PROC_TYPE PROC_TYPE_KEY CURRENT_PROC_TYPE

  . ${SYSTEM_INFORMATION}/system.env
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


  #
  # MESSAGE FILES
  #
  echo ""
  echo "  Making Message files for $CURRENT_PROC_TYPE Components"
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
        DOPT="-DDEBUG $DOPT"
      else
        DOPT="$DOPT"
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
          #echo "   ${MAKEMAKE} *.m makefile"
          echo "   ${MAKEMAKE} *.m makefile.sco"
          #${MAKEMAKE} *.m makefile
          ${MAKEMAKE} *.m makefile.sco

          echo "   COPT=$COPT DOPT=$DOPT"
          #echo "   $MAKE messages"
          echo "   $MAKE messages -f makefile.sco"
          #$MAKE messages
          $MAKE messages makefile.sco
        fi
      fi
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################
  

  #
  # MAKEMAKE
  #
  echo ""
  echo " Make makefiles for $CURRENT_PROC_TYPE Components"
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
# sml:10-21-94 make a temporary file and remove the WHY clause for SCO
#      set -x
      pwd
      if [ `\ls *.mSCO 2>/dev/null | wc -c` -ne 0 ]
      then
        echo "   ${MAKEMAKE} *.mSCO makefile"
        ${MAKEMAKE} *.mSCO /usr/tmp/makefile.tmp
    if [ -f /usr/tmp/makefile.tmp ]
    then
	if [ "$OS_KEY" = "SCO" ]
	then
	  grep -v "WHY" /usr/tmp/makefile.tmp > makefile.sco
	  rm /usr/tmp/makefile.tmp
	else
	  mv /usr/tmp/makefile.tmp makefile.sco 
	fi
    fi
      fi
#      set +x
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################


  #
  # MAKE ANSI PROTOTYPE HEADERS
  #
  # Perhaps this can be done at the same time makemake is run?  
  echo ""
  echo "  Making $CURRENT_PROC_TYPE ANSI-C Prototypes"
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
#dmb:03/15/93:Modified to build mkptypes itself.
#        if grep ptypes makefile >/dev/null
        if egrep -e '^ptypes' makefile >/dev/null
        then
          echo "   COPT=$COPT DOPT=$DOPT"
          echo
          echo "********    WARNING! DO NOT INTERRUPT (^C)    ********"
          echo
          echo "   $MAKE ptypes"
          trap "" 2 3
          $MAKE ptypes
          echo "   made ptypes"
          echo
          echo "********    OK TO INTERRUPT (^C)    ********"
          echo
          trap -
        fi
      fi
    )
  done
  ####################
  # END COMPONENT LOOP
  ####################


  #
  # MAKE
  #
  echo ""
  echo "  Making $CURRENT_PROC_TYPE Components"
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
        DOPT="-DDEBUG $DOPT"
      else
        DOPT="$DOPT"
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
#dmb:03/15/93:Modified to build mkptypes and makemake.
#        if grep promote makefile >/dev/null
        if egrep -e '^promote' makefile >/dev/null
        then
          echo "   COPT=$COPT DOPT=$DOPT"
          echo "   $MAKE promote"
          $MAKE promote
        fi
      fi
    )
  done
  echo ""
  
  echo "Finished Build for $CURRENT_PROC_TYPE"
  echo ""

done

######################
# BEGIN PROC_TYPE LOOP
######################


echo ""
echo "End ${SYSTEM_NAME_KEY} Build." `date`
echo "Writing to ${LOGFILE}"
#dmb:08/03/94:Adding braces {} to capture times
#dmb:08/03/94:Changing outer parens () to braces {}
} } 2>&1 | tee ${LOGFILE}

#set +x
