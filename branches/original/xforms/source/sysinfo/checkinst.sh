#!/bin/ksh
########################################################################
# Copyright 1992 Intergraph Corporation
# All Rights Reserved
# 
# Including software, file formats, and audio-visual displays;
# may only be used pursuant to applicable software license agreement;
# contains confidential and proprietary information of Intergraph
# and/or third parties which is protected by copyright and trade
# secret law and may not be provided or otherwise made available
# without proper authorization.
# 
# RESTRICTED RIGHTS LEGENDS
# 
# Use, duplication, or disclosure by the Government is subject to
# restrictions as set forth in subparagraph (c) (1) (ii) of The Rights
# in Technical Data and Computer Software clause at DFARS 252.227-7013
# or subparagraphs (c) (1) and (2) of Commercial Computer Software --
# Restricted Rights at 48 CFR 52.227-19, as applicable.
# 
# Unpublished -- rights reserved under the Copyright Laws of the
# United States.
# 
# Intergraph Corporation
# Huntsville, Alabama   35894-0001
# 
 
# Check Product Installation

########################################################################
# PAS Product Management Utilities Library
########################################################################
# General Requirements:
#  - The main purpose of the PAS Product Management Utilities Library is
#    to provide a uniform interface to the product definition information
#    for all users.
#  - In a production environment, Product Management Utilities must be
#    provided to ensure consistency across processes. (builds, packagings,
#    baselines, etc).
#  - They must support unattended operations.
#  - They should be as general as possible. If possible, the same utility
#    should be used on CLIPPERs, SUNs, and PCs when appropriate.
#  - Product Management Utilities should provide a common user interface
#    for manipulating Intergraph products. They should be as clear and
#    efficient as possible. It should make correct product manipulation as 
#    foolproof as possible.
#  - If possible, each utility should run on all supported
#    archetectures without modification.
#  - Each utility should be as bullet-proof as possible. 
#    - We should have a failsafe mode that does as much of the right
#      thing as possible even if the input data has been damaged.
#      Eg: The default behavior for install should be to get all
#      components for the approprate archetecture and processor type
#      and deliver them with no questions asked, except possibly 
#      for the space check.
#    
##########################################################################
#
# The Plan:
#   Provide a set of functions which can be pulled into the working
#   environment by any script executing in any environment this product
#   is likely to encounter. Hence the requirement for general methods.
#
# The Utilities:
# Notes:
#   dmb:04/01/92: These utilities assume some things about the processing
#   dmb:04/01/92: environment. These assumptions are part of the PAS
#   dmb:04/01/92: Product Management Environment and are an attempt at
#   dmb:04/01/92: exploring an Standard Intergraph Product Management
#   dmb:04/01/92: Environment 
#
# Design Notes:
# dmb:04/16/92: This works well in a production environment, but doesn't
#               quite seem to be what we want in a delivered environment.
#               Maybe as a last-ditch default. Use Method 2.
# Method 1
#PRODUCT_NAME=${PRODUCT_NAME:-xformsrt}
#
# dmb:04/14/92: These should be excluded or optional I think.
#VERSION=${VERSION:-01.00.08.00}
#DATE=${DATE:-01-APR-1992}
#
########################################################################
# References:
#  For details of the command line interface and runtime environment
#  for DELTOOLS, see:
#    DELTOOLS Product Developer's Guide. DSA043700, Oct. 1991.
#
########################################################################
############################################################
# FUNCTION: PAS_f_get_pdef_table()
############################################################
PAS_f_get_pdef_table()
{
  #Usage: VAR_LIST="`PAS_f_get_pdef_table 'FILE INFORMATION'`"

  TABLE_NAME=$1

  sed -n -e "/#${TABLE_NAME}/,/#END OF ${TABLE_NAME}/p" $P_DEF |
    sed '1d;s/^#//;$d'
}
############################################################
##########################################################
# FUNCTION: PAS_f_mkdir
##########################################################
PAS_f_mkdir()
{
  PASstatus=0
  DIR=$1
  if [ ! -d "$DIR" ]
  then
    echo mkdir -p "$DIR"   >>$NULL 2>>$NULL
    if mkdir -p "$DIR" 
    then
      :
    else
      ### CSS 5.0 bug:  mkdir -p doesn't return with 0 when successful
      if [ ! -d "$DIR" ]
      then
        echo "Unable to make $DIR"  >>$LOGFILE 2>>$LOGFILE
        PASstatus=1
      fi
    fi
  fi
  return $PASstatus
}
##########################################################
########################################################################
# FUNCTION: PAS_f_mv_rm_files ()
########################################################################
# Move the files for this component to /usr/tmp in case any of them 
# are currently in use, since you can't overwrite them if they're in
# use. If they're under /usr2/ip32, you also can't move them across
# filesystems to /usr/tmp if they're busy.
########################################################################
PAS_f_mv_rm_files ()
{
  # USAGE: PAS_f_mv_rm_files $Component $DESTDIR $ArchTypeKey

  Component=$1
  DESTDIR=$2
  ArchTypeKey=$3

  ################################################################
  ### see if the DESTDIR directory is symbolically linked elsewhere
  ################################################################
  if [ -d $DESTDIR ]
  then
    REAL_PATH=`ls -ls $DESTDIR | awk '/->/ {print $NF}' `
  fi
  
  if [ "$REAL_PATH" = "" ]
  then
    ### the user loaded the product to $DESTDIR
    REAL_USR="usr"
  else
    ### the product is in $REAL_PATH and symbolically linked to $DESTDIR
    REAL_USR=`echo $REAL_PATH | awk -F/ 'NR==1 { print $2 } ' `
  fi
  
  REAL_TMP="/$REAL_USR/tmp"

  PAS_f_mkdir $REAL_TMP >>$LOGFILE 2>>$LOGFILE
  
  MV_RM_FILES="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ArchTypeKey}'\" || $2 == \"ALL\" ) ) \
       {print $3;} \
     }' -`"

  for FFF in $MV_RM_FILES
  do
    eval FROM_FILE=$FFF
    if [ -s "$FROM_FILE" -a ! \( -d "$FROM_FILE" \) ]
    then
      echo mv -f $FROM_FILE $REAL_TMP >>$NULL 2>>$NULL
      mv -f $FROM_FILE $REAL_TMP >>$LOGFILE 2>>$LOGFILE

      if [ "$?" = 0 ]
      then
        FNAME=`basename $FROM_FILE`

        ###  Remove the old file, if it's not busy  ####
        echo rm -f $REAL_TMP/$FNAME >>$NULL 2>>$NULL
        rm -f $REAL_TMP/$FNAME >>$LOGFILE 2>>$LOGFILE

        if [ "$?" != 0 ]   ###  File is in use  ###
        then
          echo "Moved file $FROM_FILE ( in use ) to $REAL_TMP/$FNAME" |
            tee -a $LOGFILE
        fi
      fi
    fi
  done
}
########################################################################
########################################################################
# FUNCTION: PAS_f_symlink_files ()
########################################################################
# Symbolically link files as necessary.
########################################################################
PAS_f_symlink_files ()
{
  # USAGE: PAS_f_symlink_files $Component $DESTDIR ${ArchTypeKey}

  Component=$1
  DESTDIR=$2  
  ArchTypeKey=$3

  WF1=$TMPDIR/symlnk$$
  PAS_f_get_pdef_table 'SYMLINK.ITB'  | tail +3 |
     awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' >$WF1

  OIFS="$IFS"
  IFS='	'

  cat $WF1 |
  while read Comp ArchKey Directory File
  do
    eval Directory=$Directory
    eval File=$File

    FILE=`basename $File`  

    # dmb:11/20/91: Make sure there's a directory there to link to
    # dmb:11/20/91: ls -d returns 0 on sun even if directory is not there
    PAS_f_mkdir $Directory >>$LOGFILE 2>>$LOGFILE

    ### remove old symbolic link before creating new one
    echo "rm -f $Directory/$FILE" >>$NULL 2>>$NULL
    rm -f $Directory/$FILE >>$LOGFILE 2>>$LOGFILE

    echo "ln -s $DESTDIR/$File $Directory/$FILE" >>$NULL 2>>$NULL
    ln -s $DESTDIR/$File $Directory/$FILE >>$LOGFILE 2>>$LOGFILE

  done

  IFS="$OIFS"
  rm -f $WF1
}
########################################################################
##########################################################
# FUNCTION: PAS_f_check_space ()
##########################################################
PAS_f_check_space ()
{
  DESTDIR=$1
  SPACE=$2
  DISK_PARTITION=`echo ${DESTDIR} | cut -f2 -d"/"`
  if Free -t /${DISK_PARTITION} $SPACE
  then
    return 0
  else
    answer=`getanswer -c "Not enough space on $DESTDIR to load $IDname.\n\
$SPACE blocks are required." -s "Continue? " y yesno`

    answer=${answer:-"y"}
    if [ "$answer" != "y" ]
    then
      return 1
    fi
  fi

  return 0
}
##########################################################
########################################################################
# FUNCTION: PAS_f_chmod ()
########################################################################
# Change the mode on all the files in this component.
########################################################################
PAS_f_chmod ()
{
  # USAGE: PAS_f_chmod ${MODE} ${Component} ${ArchTypeKey}
  MODE=$1
  Component=$2
  ArchTypeKey=$3

  CHMOD_DIRS="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ArchTypeKey}'\" || $2 == \"ALL\" ) ) \
       {print $3;} \
     }' - |
     sed 's/\/[^/]*$//' | sort -u`"

  for FFF in $CHMOD_DIRS
  do
    eval CHMOD_FILE=$FFF
    echo "chmod ${MODE} $DESTDIR/$CHMOD_FILE"        >>$NULL 2>>$NULL
    chmod ${MODE} $DESTDIR/$CHMOD_FILE               >>$LOGFILE 2>>$LOGFILE
    echo "chmod ${MODE} $DESTDIR/$CHMOD_FILE/*"      >>$NULL 2>>$NULL
    chmod ${MODE} $DESTDIR/$CHMOD_FILE/*             >>$LOGFILE 2>>$LOGFILE
  done
}
########################################################################
########################################################################
# FUNCTION: PAS_f_rm_symlink_files ()
########################################################################
# Remove symbolically linked files as necessary
########################################################################
PAS_f_rm_symlink_files ()
{
  # USAGE: PAS_f_rm_symlink_files $Component $DESTDIR ${ArchTypeKey}

  echo Called $0 $* >>$NULL 2>&1

  Component=$1
  DESTDIR=$2  
  ArchTypeKey=$3

  WF1=$TMPDIR/symlnk$$
  PAS_f_get_pdef_table 'SYMLINK.ITB'  | tail +3 |
     awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' >$WF1

  OIFS="$IFS"
  IFS='	'

  cat $WF1 |
  while read Comp ArchKey Directory File
  do
    FILE=`basename $File`  

    ### remove old symbolic link
    echo "rm -f $Directory/$FILE" >>$NULL 2>>$NULL
    rm -f $Directory/$FILE >>$LOGFILE 2>>$LOGFILE

  done

  IFS="$OIFS"
  rm -f $WF1
}
########################################################################
########################################################################
# FUNCTION: PAS_f_rm_symlink_prod_dir ()
########################################################################
# Remove symbolically linked prod_dir as necessary
########################################################################
PAS_f_rm_symlink_prod_dir ()
{
  # USAGE: PAS_f_rm_symlink_prod_dir $Component $DESTDIR ${ArchTypeKey}

  echo Called $0 $* >>$NULL 2>&1

  Component=$1
  DESTDIR=$2  
  ArchTypeKey=$3

  WF1=$TMPDIR/symlnk$$
  PAS_f_get_pdef_table 'SYMLINK.ITB'  | tail +3 |
     awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' >$WF1

  OIFS="$IFS"
  IFS='	'

  cat $WF1 |
  while read Comp ArchKey Directory File
  do
    FILE=`basename $File`  

    ### remove old symbolic link
    echo "rm -f $Directory/$FILE" >>$NULL 2>>$NULL
    rm -f $Directory/$FILE >>$LOGFILE 2>>$LOGFILE

  done

  IFS="$OIFS"
  rm -f $WF1
}
########################################################################
########################################################################
# FUNCTION: PAS_f_list_files ()
########################################################################
PAS_f_list_files ()
{
  # USAGE: PAS_f_list_files $Component $DESTDIR $ArchTypeKey

  echo Called $0 $* >>$NULL 2>&1

  Component=$1
  DESTDIR=$2
  ArchTypeKey=$3
  PASstatus=0

  LIST_FILES="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ArchTypeKey}'\" || $2 == \"ALL\" ) ) \
       {print $3;} \
     }' -`"

  echo LIST_FILES: $LIST_FILES      >>$NULL 2>>$NULL
  ( cd $DESTDIR
    pwd >>$NULL 2>&1

    for FFF in $LIST_FILES
    do
      eval CHECK_FILE=$FFF
      if [ ! -d "$CHECK_FILE" ]
      then
        echo ls ${LS_ARG} $CHECK_FILE >>$NULL 2>>$NULL
        if ls ${LS_ARG} $CHECK_FILE >>$LOGFILE 2>>$LOGFILE
        then
          :
        else
          PASstatus=$?
#          echo Set PASstatus $PASstatus
        fi
      fi
    done
    return $PASstatus
  )
# Get return status from subshell.
#PASstatus=$?
#return $PASstatus
return $?
}
########################################################################
########################################################################
# FUNCTION: PAS_f_sum_files ()
########################################################################
PAS_f_sum_files ()
{
  # USAGE: PAS_f_sum_files $Component $DESTDIR $ArchTypeKey

  echo Called $0 $* >>$NULL 2>&1
  PASstatus=0

  Component=$1
  DESTDIR=$2
  ArchTypeKey=$3

  SUM_FILES="`PAS_f_get_pdef_table 'PACKAGE.ITB'  | tail +3 |
     awk -F'	' \
     '{ if ( $1 == \"'${Component}'\" && \
        ( $2 == \"'${ArchTypeKey}'\" || $2 == \"ALL\" ) ) \
       {print $3;} \
     }' -`"

  echo SUM_FILES: $SUM_FILES      >>$NULL 2>>$NULL
  ( cd $DESTDIR
    echo "PWD is " `pwd` >>$NULL 2>&1

    for FFF in $SUM_FILES
    do
      eval CHECK_FILE=$FFF
      if [ -f $CHECK_FILE ]
      then
        echo "sum $CHECK_FILE" >>$NULL 2>>$NULL
        sum $CHECK_FILE | awk '{print $1, $2 "	"  $3}' >>$LOGFILE 2>>$LOGFILE
        :
      else
        echo "$0: Cannot find file $CHECK_FILE" >>$LOGFILE 2>>$LOGFILE
        PASstatus=2
      fi
    done
#    done >>$LOGFILE 2>>$LOGFILE

    return $PASstatus
  )
# Get return status from subshell.
#PASstatus=$?
#echo PASstatus $PASstatus >&2
#return $PASstatus
return $?

#echo SUM_FILES: $SUM_FILES      >>$NULL 2>>$NULL
#  for FFF in $SUM_FILES
#  do
#      echo sum $FFF $REAL_TMP >>$NULL 2>>$NULL
#      sum $FFF $REAL_TMP >>$LOGFILE 2>>$LOGFILE
#      PASstatus=$?
#  done
#  return $PASstatus
}
########################################################################
########################################################################
# FUNCTION: PAS_f_list_symlink_files ()
########################################################################
# Check symbolically linked files as necessary
########################################################################
PAS_f_list_symlink_files ()
{
  # USAGE: PAS_f_list_symlink_files $Component $DESTDIR ${ArchTypeKey}

  echo Called $0 $* >>$NULL 2>&1

  Component=$1
  DESTDIR=$2  
  ArchTypeKey=$3

  PASstatus=0

  WF1=$TMPDIR/symlnk$$
  PAS_f_get_pdef_table 'SYMLINK.ITB'  | tail +3 |
     awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' >$WF1

  OIFS="$IFS"
  IFS='	'

  cat $WF1 |
  while read Comp ArchKey Directory File
  do
    eval Directory=$Directory
    eval File=$File

    FILE=`basename $File`  

    ### check symbolic link
    echo "ls ${SYMLINK_ARG} $Directory/$FILE" >>$NULL 2>>$NULL
    if ls ${SYMLINK_ARG} $Directory/$FILE >>$LOGFILE 2>>$LOGFILE
    then
      :
    else
      PASstatus=$?
    fi
  done

  IFS="$OIFS"
  rm -f $WF1

  return $PASstatus

}
########################################################################
########################################################################
# FUNCTION: PAS_f_find_and_gen_sums ()
########################################################################
# Find files and generate checksums
# dmb:04/01/92:Warning: This is just roughed in from the original in
#              gen_sums.sh
########################################################################
PAS_f_find_and_gen_sums ()
{
  # USAGE: PAS_f_find_and_gen_sums $Component $DESTDIR ${ArchTypeKey}

  echo Called $0 $* >>$NULL 2>&1

  Component=$1
  DESTDIR=$2
  ArchTypeKey=$3

  cd $DESTDIR
  pwd >>$NULL 2>&1

  # dmb:04/01/92:Rework this!
  EXE_DIR="${EXE_DIR:-`dirname \`whence $0\``}"
  echo EXE_DIR is $EXE_DIR >>$NULL 2>&1
  PATH=$PATH:$EXE_DIR

  DATA_DIR=${DATA_DIR:-$EXE_DIR/$ArchTypeKey}
  echo DATA_DIR is $DATA_DIR >>$NULL 2>&1

  #echo "Writing checksums for $Component to $DATA_DIR/${Component}.${ext}" \
#                                                              >>$NULL 2>&1
  echo "Writing checksums for $Component to stdout"            >>$NULL 2>&1
  find * -type f -print |
   sed '/^log$/d' |
   xargs sum |
   awk '{print $1, $2 "	"  $3}' |
   sort -t'	' +1 -2
  # sort -t'	' +1 -2 >$DATA_DIR/${Component}.${ext}
}
########################################################################
########################################################################
# FUNCTION: PAS_f_chk_sums ()
########################################################################
# Check checksums of files as necessary
# dmb:04/01/92:Warning: This is just roughed in from the original in
#              chk_sums.sh
########################################################################
PAS_f_chk_sums ()
{
  # USAGE: PAS_f_chk_sums $Component $DESTDIR ${ArchTypeKey}

  Component=$1
  DESTDIR=$2
  ArchTypeKey=$3

  cd $DESTDIR
  pwd >>$NULL 2>&1

  # dmb:04/01/92:Rework this!
  echo \$0 is $0
  EXE_DIR="${EXE_DIR:-`dirname \`whence $0\``}"
  echo EXE_DIR is $EXE_DIR >>$NULL 2>&1
  PATH=$PATH:$EXE_DIR

  DATA_DIR=${DATA_DIR:-$EXE_DIR/$ArchTypeKey}
  echo DATA_DIR is $DATA_DIR >>$NULL 2>&1

  #Need to check existence of DATA_DIR here.
  # Try to make it if it is not there.
  PAS_f_mkdir $DATA_DIR >>$LOGFILE 2>>$LOGFILE

  #Double check existence of DATA_DIR here.
  if [ ! -d "$DATA_DIR" ]
  then
    echo "$0: Can not find directory $DATA_DIR" 1>&2
    return 2
  fi

  echo "Checking files for $Component installed under $DESTDIR" `date`

  PAS_f_find_and_gen_sums ${Component} ${ArchTypeKey} inst

  #diff $DATA_DIR/${Component}.${ext}  $DATA_DIR/${Component}.inst

  if cmp $DATA_DIR/${Component}.${ext} $DATA_DIR/${Component}.inst >/dev/null 2>&1
  then
    echo "${Component} passed installation check" `date`
  else
    echo "${Component} failed installation check" `date`
    diff $DATA_DIR/${Component}.${ext}  $DATA_DIR/${Component}.inst
  fi

  return $?
}
########################################################################
########################################################################
#=======================================================================
#================== Process Product Main ===============================
#=======================================================================
########################################################################

#
# BEGIN PROCESS_PRODUCT
#

#
# Setup Product Environment
#

#set -x

# Method 2

# dmb:04/16/92: Test Type or -L for TestLevel?
# dmb:04/16/92: -v level for verbosity or Reporting Level?
# -r reportingLevel
# -t testingLevel

USAGE="USAGE: $0 [options] ProductName\n\
  options:\n\
    -v             Verbose\n\
    -t TestType    where TestType is:\n\
                     0 = simple ls (default type)\n\
                     1 = ls -l\n\
                     2 = ls -lL\n\
                     3 = checksum"

INTENDED_USAGE="USAGE: $0 [options] ProductName\n\
  options:\n\
    -l logfile     Log results to the named file\n\
    -v             Verbose\n\
    -t TestType    where TestType is:\n\
                     0 = simple ls (default type)\n\
                     1 = ls -l\n\
                     2 = ls -lL\n\
                     3 = checksum"

################################################################
###################################
###  Set up the log file name
###################################

LOGFILE=/dev/tty
#LOGFILE=''
export LOGFILE

TEST_TYPE=0
TESTING=""
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
     # NEED TO SUPPLY DEFAULT LOGFILE NAME? PROMPT? ERROR EXIT?
            LOGFILE=''
            shift
            ;;  
     esac

     ARGS="$ARGS -l $LOGFILE"

     ;;
    -t )
     case $2
     in
       [!-]* )
     # Probably need to check range on test level.
            TEST_TYPE=$2
            shift 2
            ;;
       * )
     # NEED TO SUPPLY DEFAULT TEST_TYPE? PROMPT? ERROR EXIT?
            shift
            ;;  
     esac

     ARGS="$ARGS -t $TEST_TYPE"

     ;;
    -d )
     DBG='y'
     shift
     ;;
    -v )
     VERBOSE='y'
     shift
     ;;
    -T )
     TESTING='y'
     shift
     ;;
    -h|-\? )
     print "$USAGE" >&2
     return 1
     ;;
  esac
done
export DBG VERBOSE TESTING LOGFILE

################################################################
# dmb:04/16/92: There should be exactly one arg left.
if [ $# -ne 1 ]
then
  print "$USAGE" >&2
  return 1
else
   PRODUCT_NAME=$1
fi

# dmb:04/16/92: Adjust $LOGFILE if neccessary
if [ "$LOGFILE" ]
then
  case $LOGFILE
  in
  \/* )
    LOGFILE=$LOGFILE
    ;;
  * )
    LOGFILE=$PWD/$LOGFILE
    ;;
  esac
fi

################################################################

Product=$PRODUCT_NAME
ProdKey="`echo $Product | tr '[a-z]' '[A-Z]'`"
INGRDIR=/usr/ip32

if [ "$TESTING" ]
then
  TESTING=":"
else
  TESTING=""
fi

if [ "$VERBOSE" ]
then
  NULL=/dev/tty
else
  NULL=/dev/null
fi


################################################################
# Get product directory name
################################################################
DESTDIR=`proddata +%p -x $Product`
export DESTDIR

# see if the product directory is symbolically linked elsewhere
# proddata returns REAL_PATH
# Check this logic on installation to other filesystem
DESTDIRBASE=`basename $DESTDIR`

#dmb:11/27/91:Removed
#REAL_PATH="$DESTDIR"    # Remove this soon

if [ "$INGRDIR/$DESTDIRBASE" = "$DESTDIR" ]
then
# Product is under $INGRDIR (/usr/ip32)
  LINK_PATH=""
else
# the product is really in $DESTDIR and symbolically linked to /usr
  LINK_PATH="$INGRDIR/$DESTDIRBASE"
fi


P_DEF=$DESTDIR/product.def
if [ ! -f $P_DEF ]
then
  echo "`basename $0`: WARNING! Can not find product.def file for $Product" >&2

# Temporary. Could ask about continuing and process the product directory.
# could possibly ls -ls common directories ( eg. /usr/bin, /usr/lib,
# etc. and process everything symlinked to $PRODDIR.
  return 2
fi

. $P_DEF

DFLTS=$INGRDIR/.defaults
if [ ! -f $DFLTS ]
then
  echo "`basename $0`: WARNING! Can not find installation defaults file for $Product" >&2

# Temporary. Should ask about continuing and process the product directory.
# could just try to process all components found in product.def

  return 2
fi


PATH=$DESTDIR:$DESTDIR/bin:$PATH
export PATH

if [ -z "$TMPDIR" ]
then
  #Free -m not yet supported on CLIPPER in DELTOOLS 06.00.35.00 
  #TMPDIR=`Free -m | cut -f1 -d' '`/tmp

  # Temporary workaround...
  TMPDIR=/usr/tmp
fi
# Need to make sure $TMPDIR is there!



########################################################################
#### First, determine which box we're removing from and prepare to use
####  to set things accordingly.
########################################################################
OSType=`uname -s`
case $OSType
in
  CLIX )
    ArchType=clipper
    ArchTypeKey=CLIPPER


    GROUP=sys
    INQ_LGLASS=inqlgexist


# dmb:05/09/92: If this is not a server, install default proc type images.
# dmb:05/09/92: If this is a server, ask about what proctype(s) to install.
#    ProcType=`inqcpuid`
#    ProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

# dmb:09/11/92: Install C100 images by default on CLIX since they'll
#               run on all CLIX machines.
#    DfltProcType=c100
#    DfltProcTypeKey=C100

# dmb:01/05/93: Install C100 images by default on C100s and C300s.
# dmb:01/05/93: Install C400 images by default on C400s.
# dmb:01/05/93: Inform user that other images are available and prompt.
# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
    TargetProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`
    case $TargetProcTypeKey
    in
      C100|C300 )
        DfltProcType=c100
        DfltProcTypeKey=C100
        ;;
      C400 )
        DfltProcType=c400
        DfltProcTypeKey=C400
        ;;
    esac

# dmb:04/16/92:Adding TEST_TYPE
    case $TEST_TYPE
    in
      0 )
        # dmb:04/14/92:This is the weakest test we should consider
        LS_ARG=""
        SYMLINK_ARG=""
        ;;
      1 )
        # dmb:04/14/92:This just doesn't seem to be useful in this context
        LS_ARG=-lo
        SYMLINK_ARG=-loL
        ;;
      2 )
        # dmb:04/14/92:This is a much stronger test, but runs into data
        # capture problems, almost as bad as the checksum connundrum.
        LS_ARG=-lo
        SYMLINK_ARG=-lo


        # dmb:04/14/92:This test is quite useful. It can tell what
        #   time the product was installed ( from where? ), but it is
        #   too strong a test for MFG, however. All will fail if diffed.
        ;;
    esac

# dmb:04/14/92: As used with unix test or [
# dmb:04/14/92: Currently used only in remove.sh to remove prod dir
#    SYMLINK_TEST=-l

  ;;
  IRIX )
    ArchType=mips
    ArchTypeKey=MIPS


    GROUP=sys
#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

# dmb:05/09/92: If this is not a server, install default proc type images.
# dmb:05/09/92: If this is a server, ask about what proctype(s) to install.
# dmb:10/23/92: We need to come to some consessus as to how to say this
#               on MIPS
#    ProcType=`inqcpuid`
#    ProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

    DfltProcType=mips
    DfltProcTypeKey=MIPS

# dmb:04/16/92:Adding TEST_TYPE
    case $TEST_TYPE
    in
      0 )
        # dmb:04/14/92:This is the weakest test we should consider
        LS_ARG=""
        SYMLINK_ARG=""
        ;;
      1 )
        # dmb:04/14/92:This just doesn't seem to be useful in this context
        LS_ARG=-lo
        SYMLINK_ARG=-loL
        ;;
      2 )
        # dmb:04/14/92:This is a much stronger test, but runs into data
        # capture problems, almost as bad as the checksum connundrum.
        LS_ARG=-lo
        SYMLINK_ARG=-lo


        # dmb:04/14/92:This test is quite useful. It can tell what
        #   time the product was installed ( from where? ), but it is
        #   too strong a test for MFG, however. All will fail if diffed.
        ;;
    esac

# dmb:04/14/92: As used with unix test or [
# dmb:04/14/92: Currently used only in remove.sh to remove prod dir
#    SYMLINK_TEST=-l

  ;;
  SunOS )
    ArchType=sun
    ArchTypeKey=SUN

    GROUP=daemon
#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

#    ProcType=`arch`
#    ProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`

    DfltProcType=sun4
    DfltProcTypeKey=SUN4

# dmb:04/16/92:Adding TEST_TYPE
    case $TEST_TYPE
    in
      0 )
        # dmb:04/14/92:This is the weakest test we should consider
        LS_ARG=""
        SYMLINK_ARG=""
        ;;
      1 )
        # dmb:04/14/92:This just doesn't seem to be useful in this context
        LS_ARG=-lo
        SYMLINK_ARG=-lL
        # dmb:04/14/92:Original:
        #    SYMLINK_ARG=-L
        ;;
      2 )
        # dmb:04/14/92:This is a much stronger test, but runs into data
        # capture problems, almost as bad as the checksum connundrum.
        LS_ARG=-l
        SYMLINK_ARG=-l

        # dmb:04/14/92:Actually, its quite useful. It can tell what
        #   time the product was installed ( from where? ). This is
        #   too strong a test for MFG, however. All will fail if diffed.
        ;;
    esac

  ;;
  * )
    echo "Can not deliver ${IDtitle} to $OSType" >&2
    return 2
  ;;
esac



PRODNAME=$ProdKey
export PRODNAME


#dmb:01/26/93:Added to support multiple bundled versions.
# dmb:01/25/93:Working around need to recognize archetecture-dependent
#  versions ( i.e. CLIPPER_, SUN_, MIPS_, ...) form of these for ISS70.
echo IDversion is $IDversion >>$NULL 2>>$NULL
case $ArchTypeKey
in
  CLIPPER )
    if [ "$CLIPPER_IDversion" ]
    then
      IDversion=$CLIPPER_IDversion
    fi
    ;;
  MIPS )
    if [ "$MIPS_IDversion" ]
    then
      IDversion=$MIPS_IDversion
    fi
    ;;
  SUN )
    if [ "$SUN_IDversion" ]
    then
      IDversion=$SUN_IDversion
    fi
    ;;
esac
echo IDversion is now $IDversion >>$NULL 2>>$NULL


#######################################################################
#
# ProductAnnce
#
echo                        >>$NULL 2>>$NULL
echo IDname: $IDname        >>$NULL 2>>$NULL
echo IDtitle: $IDtitle      >>$NULL 2>>$NULL
echo IDversion: $IDversion  >>$NULL 2>>$NULL
echo IDdate: $IDdate        >>$NULL 2>>$NULL
echo DESTDIR: $DESTDIR      >>$NULL 2>>$NULL
echo REAL_PATH: $REAL_PATH  >>$NULL 2>>$NULL
echo LINK_PATH: $LINK_PATH  >>$NULL 2>>$NULL
echo PATH: $PATH            >>$NULL 2>>$NULL
echo P_DEF: $P_DEF          >>$NULL 2>>$NULL
echo DFLTS: $DFLTS          >>$NULL 2>>$NULL
echo LOGFILE: $LOGFILE      >>$NULL 2>>$NULL
echo TMPDIR: $TMPDIR        >>$NULL 2>>$NULL
echo TESTING: $TESTING      >>$NULL 2>>$NULL
echo Product: $Product      >>$NULL 2>>$NULL
echo PRODNAME: $PRODNAME    >>$NULL 2>>$NULL



echo                                        >>$LOGFILE 2>>$LOGFILE
echo "Checking ${IDtitle} ( version ${IDversion} )" \
                                               >>$LOGFILE 2>>$LOGFILE
echo " in $DESTDIR"                         >>$LOGFILE 2>>$LOGFILE
echo                                        >>$LOGFILE 2>>$LOGFILE

date >>$LOGFILE 2>>$LOGFILE
echo                                        >>$LOGFILE 2>>$LOGFILE

#######################################################################
#
# Setup Proc Types
#

CHECK_PROC_TYPES=""

SupportedProcTypes="`PAS_f_get_pdef_table 'SUPPORTED_PROCESSOR_TYPES.ITB' |
  tail +3 |
  awk -F'	' \
  '{ if ( $1 == \"'${ArchTypeKey}'\" || $1 == \"ALL\" ) \
    {print $2;} \
  }' -`"

OtherProcTypeList="`echo $SupportedProcTypes |
  sed \"s/${DfltProcTypeKey}//;s/^ //;s/ $//;s/  / /\"`"
OtherAvailProcTypes="`echo $OtherProcTypeList | sed 's/ [^ ]*$/ and&/'`"

# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
if [ "${TargetProcTypeKey}" = 'C400' ]
then
  Others='y'
else
  Others=`getanswer -q "Install images for other processor types?"`
fi

Others=${Others:-n}

CHECK_PROC_TYPES=""

if [ "$Others" = 'n' ]
then
  CHECK_PROC_TYPES="$DfltProcTypeKey"
else
  for InstProcType in $OtherProcTypeList $DfltProcTypeKey
  do
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
# dmb:01/11/93: Restored -q on getanswer
    if [ "${TargetProcTypeKey}" = 'C400' ]
    then
      case $InstProcType
      in
        C100|C400 )
          InstOther='y'
          ;;
        * )
          InstOther=`getanswer -q "Install $InstProcType processor images?" "$d"`
          ;;
      esac
    else
      InstOther=`getanswer -q "Install $InstProcType processor images?" "$d"`
    fi

    if [ "$InstOther" = 'y' ]
    then
      CHECK_PROC_TYPES="$CHECK_PROC_TYPES $InstProcType"
    fi
  done
fi

if [ "$VERBOSE" ]
then
  echo "$DfltProcTypeKey images were delivered to this machine by default."

  if [ "$Others" != 'n' ]
  then
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
    if [ "${TargetProcTypeKey}" = 'C400' ]
    then
      echo "$OtherAvailProcTypes images were also delivered by default."
    else
      echo "$OtherAvailProcTypes images were also available"
    fi
  fi
  CHECK_PROC_TYPES="`echo $CHECK_PROC_TYPES |
    sed 's/^ //;s/ $//;s/  / /'`"
  echo "Check installed files for $CHECK_PROC_TYPES"
fi

CHECK_PROC_TYPE_LIST="`echo $CHECK_PROC_TYPES | tr '[A-Z]' '[a-z]'`"



#dmb:04/06/92:OK for now...
#PAS_f_find_and_gen_sums $Product $DESTDIR ${ArchTypeKey}


#######################################################################
# dmb:04/14/92: Exploring...
#######################################################################
PREPROCESS=n
DEFAULTS=y
PRODNAME=$ProdKey
export PREPROCESS PRODNAME DEFAULTS

#
# Get Selections
#

# Get AvailableList from $P_DEF

AvailableList="`PAS_f_get_pdef_table 'INSTALL.ITB' | tail +3 |
    cut -f1 -d'	'`"



####################
SelectedList=""


#
# BEGIN SELECT COMPONENT LOOP
#
# Note: for things to work out right, all Default='deliver' components
# should be delivered first.

for Component in $AvailableList
do

  #This should be done better once we get it working
  INSTALL_LINE="`PAS_f_get_pdef_table 'INSTALL.ITB' |
      sed -n \"/^$Component/p\"`"

  OIFS="$IFS"
  IFS='	'
  set $INSTALL_LINE
  Comp="$1"
  Default="$2"
  Title="$3"
  IFS="$OIFS"

#   GetSelection

  if [ "$Default" = "deliver" ]
  then
    Selected="y"
  else
    Prompt="Deliver the ${Title}?"
    Selected=`getanswer "${Prompt}" "${Default}"`
  fi

  case "$Selected"
  in
    [Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
        SelectedList="$SelectedList $Component"
      ;;
  esac

done

# END SELECT COMPONENT LOOP
#

ListResult=0
SymlinkResult=0
SumResult=0

##################################
# Begin PROC_TYPE LOOP
##################################
for PROC_TYPE in $CHECK_PROC_TYPE_LIST
do
  PROC_TYPE_KEY=`echo $PROC_TYPE | tr '[a-z]' '[A-Z]'`

  export PROC_TYPE PROC_TYPE_KEY
#  echo "Checking installed files for $PROC_TYPE_KEY"


    case $PROC_TYPE_KEY
    in
      C100|C300 )
        ProcType=c100
        ProcTypeKey=C100
        ProcSuffix=c1
        ;;
      C400 )
        ProcType=c400
        ProcTypeKey=C400
        ProcSuffix=c4
        ;;
      MIPS )
        ProcType=mips
        ProcTypeKey=MIPS
        ProcSuffix=mi
        ;;
      SUN4 )
        ProcType=sun4
        ProcTypeKey=SUN4
        ProcSuffix=s4
        ;;
      * )
        echo "Can not deliver ${IDtitle} to $PROC_TYPE_KEY" >&2
        exit 2
        ;;
    esac


#
# Check Components
#

# dmb:04/16/92:Adding TEST_TYPE
    echo TEST_TYPE is $TEST_TYPE >>$NULL 2>>$NULL
    case $TEST_TYPE
    in
      [0-2] )
        # Note: Use two loops for comprehensibility

        echo "Checking $PROC_TYPE_KEY files delivered under the product directory"\
                                            >>$LOGFILE 2>>$LOGFILE
        # BEGIN CHECK COMPONENT LOOP
        for Component in $SelectedList
        do
      
          #   Check Component Files
      
          PAS_f_list_files $Component $DESTDIR ${ArchTypeKey}
          TmpResult=$?
          if [ $TmpResult -ne 0 ]
          then
            ListResult=$TmpResult
          fi
        echo ListResult is $ListResult      >>$NULL 2>>$NULL      
        done
        # END CHECK COMPONENT LOOP
      
        echo
      
        echo "Checking $PROC_TYPE_KEY files symbollically linked to other locations" \
                                            >>$LOGFILE 2>>$LOGFILE
        # BEGIN CHECK COMPONENT LOOP
        for Component in $SelectedList
        do
      
          #   Check Component SymLinked Files
      
          PAS_f_list_symlink_files $Component $DESTDIR ${ArchTypeKey}
          TmpResult=$?
          if [ $TmpResult -ne 0 ]
          then
            SymlinkResult=$TmpResult
          fi
        echo SymlinkResult is $SymlinkResult      >>$NULL 2>>$NULL      
        done
        # END CHECK COMPONENT LOOP
      
        echo
        ;;
      3 )
        echo "Checksumming $PROC_TYPE_KEY files delivered under the product directory"\
                                            >>$LOGFILE 2>>$LOGFILE
        # BEGIN CHECK COMPONENT LOOP
        for Component in $SelectedList
        do
      
          #   Check Component Files
      
          PAS_f_sum_files $Component $DESTDIR ${ArchTypeKey}
          TmpResult=$?
          if [ $TmpResult -ne 0 ]
          then
            SumResult=$TmpResult
          fi
        echo SumResult is $SumResult      >>$NULL 2>>$NULL
        done
        # END CHECK COMPONENT LOOP
      
        echo
        ;;
      * )
        print "$USAGE" >&2
        ;;
    esac

done
##################################
# End PROC_TYPE LOOP
##################################


#######################################################################

CheckResult=`expr $ListResult + $SymlinkResult + $SumResult`


if [ "$CheckResult" -eq 0 ]
then
  echo "${IDname} product passed installation check. " `date`
else
  echo "${IDname} product failed installation check. " `date`
fi

echo CheckResult is $CheckResult                 >>$NULL 2>>$NULL
return $CheckResult

#
# END OF PROCESS_PRODUCT
#
