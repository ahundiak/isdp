#!/bin/sh
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

# Install Product

PRODUCT_NAME=ums
VERSION=02.00.02.04
DATE=16-JUL-1992

########################################################################
# General Requirements:
#  - The main purpose of the installation script is to get the files
#    for a product on the target machine and set them up so that the
#    product can be run.
#  - It must support unattended installations.
#  - The script should be as general as possible. If possible, the same
#    script should be used on CLIPPERs, SUNs, and PCs when
#    appropriate.
#  - Install scripts should provide a common user interface for
#    installing Intergraph products. This should be as clear and
#    efficient as possible. It should make correct installation as 
#    foolproof as possible.
#  - The script should be as bullet-proof as possible. 
#    - We should have a failsafe mode that does as much of the right
#      thing as possible even if the input data has been damaged.
#      The default behavior for install should be to get all
#      components for the approprate archetecture and processor type
#      and deliver them with no questions asked, except possibly 
#      for the space check.
#    
##########################################################################
#
# The Plan:
#   setup environment
#   ProductPre0
#
#   Get Selections
#     for Component in $AvailableList
#     do
#       GetSelection
#       if [ $Selected ]
#       then
#         CheckSpace
#         if [ $SpaceOK ]
#         then
#           SelectedList="$SelectedList $Component"
#         fi
#       fi
#     done
#
#   Get Components
#     if [ $AnySelected ]
#     then
#       ProductPre1
#       for Component in $SelectedList
#       do
#         eval ${Component}pre
#         eval getfile ${Component}
#         eval ${Component}post
#       done
#
#    ProductPost
#    ProductCleanup
#  fi
#
########################################################################
# References:
#  For details of the command line interface and runtime environment
#  for install, see:
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
########################################################################


#
# Setup Product Environment
#

P_DEF=$TMPDIR/product.def

# NOTE: for some reason, newprod does not seem to export the symbols
#it gets from here even if product.def tries to export them.
. $P_DEF

Product="`echo $IDname | tr '[A-Z]' '[a-z]'`"
export DESTDIR

########################################################################
#### First, determine which box we're installing on and prepare to use
####  the correct commands and prodfile names accordingly.
########################################################################

case `uname -s`
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

# dmb:05/11/92: Install C100 images by default on CLIX since they'll
#               run on all CLIX machines.
#    DfltProcType=c100
#    DfltProcTypeKey=C100

# dmb:06/26/92: Simply inquire for all machines...
    DfltProcType=`inqcpuid`
    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`
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

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`arch`
#    DfltProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`
  ;;
  * )
    echo "Can not deliver ${IDtitle} to `uname -s`" >&2
    exit 2
  ;;
esac


######################################################################
###  Make the default directory to put the product in
######################################################################
PAS_f_mkdir $DESTDIR

# This may not be neccessary
cd $DESTDIR


###################################
###  Set up the log file name
###################################
LOGFILE=$DESTDIR/log
rm -f $LOGFILE

#
# ProductAnnce
#
if [ "$VERBOSE" ]
then
  NULL=/dev/tty
else
  NULL=/dev/null
fi
export NULL

cat << !end_of_info! >>$NULL 2>>$NULL

IDname: $IDname
IDtitle: $IDtitle
IDversion: $IDversion
IDdate: $IDdate
!end_of_info!

if [ "$PREPROCESS" != "y" ]
then
  INTRO_MESSAGE="Installing ${IDtitle} ( version ${IDversion} )
 in $DESTDIR"
else
  INTRO_MESSAGE="Preprocessing ${IDtitle} ( version ${IDversion} )"
fi

cat << !end_of_intro! | tee -a $LOGFILE
$INTRO_MESSAGE
!end_of_intro!


date >>$LOGFILE 2>>$LOGFILE


SupportedProcTypes="`PAS_f_get_pdef_table 'SUPPORTED_PROCESSOR_TYPES.ITB' |
  tail +3 |
  awk -F'	' \
  '{ if ( $1 == \"'${ArchTypeKey}'\" || $1 == \"ALL\" ) \
    {print $2;} \
  }' -`"

OtherProcTypeList="`echo $SupportedProcTypes |
  sed \"s/${DfltProcTypeKey}//;s/^ //;s/ $//;s/  / /\"`"

OtherAvailProcTypes="`echo $OtherProcTypeList | sed 's/ [^ ]*$/ and&/'`"


#dmb:05/11/92:Test Added for PREPROCESS attempt
if [ "$PREPROCESS" = "y" ]
then
  if [ "$OtherAvailProcTypes" ]
  then
    cat << !end_of_proc_type_info! | tee -a $LOGFILE

$DfltProcTypeKey images will be delivered to this machine by default.
$OtherAvailProcTypes images are also available.

!end_of_proc_type_info!
  else
    cat << !end_of_proc_type_info2! | tee -a $LOGFILE

$DfltProcTypeKey images will be delivered to this machine.

!end_of_proc_type_info2!

  fi

  if [ "$DEFAULTS" = 'y' ]
  then
    Others='n'
  else
    if [ "$OtherAvailProcTypes" ]
    then
      Others=`getanswer "Install images for other processor types?" "n"`
    else
      Others='n'
    fi
  fi

  INSTALL_PROC_TYPES=""
  if [ "$Others" = 'n' ]
  then
    INSTALL_PROC_TYPES="$DfltProcTypeKey"
  else
    for InstProcType in $OtherProcTypeList $DfltProcTypeKey
    do
      if [ "$InstProcType" = "$DfltProcTypeKey" ]
      then
        d=y
      else
        d=n
      fi

      InstOther=`getanswer "Install $InstProcType processor images?" "$d"`
      if [ "$InstOther" = 'y' ]
      then
        INSTALL_PROC_TYPES="$INSTALL_PROC_TYPES $InstProcType"
      fi
    done
  fi
else
  Others=`getanswer -q "Install images for other processor types?"`
  Others=${Others:-n}

  INSTALL_PROC_TYPES=""
  if [ "$Others" = 'n' ]
  then
    INSTALL_PROC_TYPES="$DfltProcTypeKey"
  else
    for InstProcType in $OtherProcTypeList $DfltProcTypeKey
    do
      InstOther=`getanswer -q "Install $InstProcType processor images?"`
      if [ "$InstOther" = 'y' ]
      then
        INSTALL_PROC_TYPES="$INSTALL_PROC_TYPES $InstProcType"
      fi
    done
  fi
fi

if [ "$VERBOSE" ]
then
  INSTALL_PROC_TYPES="`echo $INSTALL_PROC_TYPES |
    sed 's/^ //;s/ $//;s/  / /'`"
  echo "Install images for $INSTALL_PROC_TYPES" >>$NULL 2>>$NULL
fi

INSTALL_PROC_TYPE_LIST="`echo $INSTALL_PROC_TYPES | tr '[A-Z]' '[a-z]'`"


#
# Product PreInstall
#

PAS_f_get_pdef_table "PREINSTALL_NOTICE.ITB"
PAS_f_get_pdef_table "PRODUCT_PREINSTALL_NOTICE.ITB"
PAS_f_get_pdef_table "${IDname}_PREINSTALL_NOTICE.ITB"

if [ "$PREPROCESS" != "y" ]
then

  echo BEGIN PRODUCT PREINSTALL >>$NULL 2>>$NULL

  OIFS="$IFS"
  IFS='	'

  PAS_f_get_pdef_table 'PREINSTALL.ITB' |
    sed -n "/^${Product}[ ]*[	]/p" |
    while read Comp Command
    do
      # Space
      IFS=' '
      if [ "${Command}" ]
      then
        echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
        eval ${Command} >>$LOGFILE 2>>$LOGFILE
      fi
      # Tab
      IFS='	'
    done
    IFS="$OIFS"

  echo END PRODUCT PREINSTALL >>$NULL 2>>$NULL

fi


#
# Get Selections
#

# Get AvailableList from $P_DEF

AvailableList="`PAS_f_get_pdef_table 'INSTALL.ITB' | tail +3 |
    cut -f1 -d'	'`"



####################
total_space=0
requested_space=0

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

  ##################################
  # dmb:05/11/92:Added
  # Begin PROC_TYPE LOOP
  ##################################
  for PROC_TYPE in $INSTALL_PROC_TYPE_LIST
  do
    PROC_TYPE_KEY=`echo $PROC_TYPE | tr '[a-z]' '[A-Z]'`
    export PROC_TYPE PROC_TYPE_KEY


  #dmb:04/16/92:Added
    ComponentKey=`echo ${Component} | tr '[a-z]' '[A-Z]'`
    PAS_f_get_pdef_table "${ComponentKey}_PRESELECT_NOTICE.ITB"

    Size="`PAS_f_get_pdef_table 'SPACE.ITB' | tail +3 |
     awk -F'	' '$1 == \"'$Component'\" && \
       $2 == \"'$PROC_TYPE_KEY'\" {print $3}'`"
    requested_space=$total_space
    requested_space=`expr $requested_space + $Size`

  done
  ##################################
  # dmb:05/11/92:Added
  # End PROC_TYPE LOOP
  ##################################

  if [ ! "$Default" = "deliver" ]
  then
    echo
    echo "$total_space blocks have already been requested."
    echo "The ${Title} require $Size blocks,"
    echo "  making a total of $requested_space blocks required."
  fi



#   GetSelection

# dmb:04/20/92:
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

      ##########################################################
      ### Add the size of the requested component to the total
      ### for for all requested parts and check the space available.
      ##########################################################
      total_space=`expr $total_space + $Size`
      PAS_f_check_space ${DESTDIR} $total_space
      if [ "$?" -eq 0 ]
      then
        SelectedList="$SelectedList $Component"
      fi

      #dmb:04/16/92:Added
      ComponentKey=`echo ${Component} | tr '[a-z]' '[A-Z]'`
      PAS_f_get_pdef_table "${ComponentKey}_POSTSELECT_NOTICE.ITB"

      ;;
    * )
      continue
      ;;
  esac

done

# END SELECT COMPONENT LOOP

#
# Get Components
#
#dmb:04/13/92:Test Added for PREPROCESS attempt
if [ "$PREPROCESS" != "y" ]
then
  echo

  ##################################
  # dmb:05/11/92:Added
  # Begin PROC_TYPE LOOP
  ##################################
  for PROC_TYPE in $INSTALL_PROC_TYPE_LIST
  do
    PROC_TYPE_KEY=`echo $PROC_TYPE | tr '[a-z]' '[A-Z]'`
    export PROC_TYPE PROC_TYPE_KEY
    echo "Installing $PROC_TYPE_KEY images..." | tee -a $LOGFILE

    case $PROC_TYPE_KEY
    in
      C100 )
        ProcType=c100
        ProcTypeKey=C100
        ProcSuffix=c1
        ;;
      C300 )
        ProcType=c300
        ProcTypeKey=C300
        ProcSuffix=c3
        ;;
      C400 )
        ProcType=c400
        ProcTypeKey=C400
        ProcSuffix=c4
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


    # BEGIN GET COMPONENT LOOP
    for Component in $SelectedList
    do

      INSTALL_LINE="`PAS_f_get_pdef_table 'INSTALL.ITB' |
          sed -n \"/$Component/p\"`"

      OIFS="$IFS"
      IFS='	'
      set $INSTALL_LINE
      Comp="$1"
      Default="$2"
      Title="$3"
      IFS="$OIFS"


    #   Component PreInstall

    # dmb:05/12/92: Do this before or after component preinstall?
      PAS_f_mv_rm_files ${Component} ${DESTDIR} ${ArchTypeKey}


      echo BEGIN COMPONENT PREINSTALL >>$NULL 2>>$NULL

      OIFS="$IFS"
      IFS='	'

      #dmb:04/16/92:Added
      ComponentKey=`echo ${Component} | tr '[a-z]' '[A-Z]'`
      PAS_f_get_pdef_table "${ComponentKey}_PREINSTALL_NOTICE.ITB"


      PAS_f_get_pdef_table 'PREINSTALL.ITB' |
        sed -n "/^${Component}[ ]*[	]/p" |
        while read Comp Command
        do
          # Space
          IFS=' '
          if [ "${Command}" ]
          then
            echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
            eval ${Command} >>$LOGFILE 2>>$LOGFILE
          fi
          # Tab
          IFS='	'
        done
      IFS="$OIFS"

      echo END COMPONENT PREINSTALL >>$NULL 2>>$NULL



    #   Get Component

      getfile "${Component}.p${ProcSuffix}" - |
          compress -d | cpio -ivmud >>$LOGFILE 2>>$LOGFILE

      # dmb:04/20/92:Added status check
      PASstatus=$?
      if [ "$PASstatus" -ne 0 ]
      then
        echo "Error getting files for ${Product}"  >>$LOGFILE 2>>$LOGFILE
        exit $PASstatus
      fi


    #   Component PostInstall

      # Note: we need to work this into product.def
      MODE=755
      PAS_f_chmod ${MODE} ${Component} ${ArchTypeKey}
      PAS_f_symlink_files ${Component} ${DESTDIR} ${ArchTypeKey}


      echo BEGIN COMPONENT POSTINSTALL >>$NULL 2>>$NULL

      OIFS="$IFS"
      IFS='	'

      #dmb:04/16/92:Added
      ComponentKey=`echo ${Component} | tr '[a-z]' '[A-Z]'`
      PAS_f_get_pdef_table "${ComponentKey}_POSTINSTALL_NOTICE.ITB"

      PAS_f_get_pdef_table 'POSTINSTALL.ITB' |
        sed -n "/^${Component}[ ]*[	]/p" |
        while read Comp Command
        do
          # Space
          IFS=' '
          if [ "${Command}" ]
          then
            echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
            eval ${Command} >>$LOGFILE 2>>$LOGFILE
          fi
          # Tab
          IFS='	'
        done
      IFS="$OIFS"

      echo END COMPONENT POSTINSTALL >>$NULL 2>>$NULL

    done
    # END GET COMPONENT LOOP

  done
  ##################################
  # dmb:05/11/92:Added
  # End PROC_TYPE LOOP
  ##################################

  # ProductPostInstall
  ###################################################################
  #### Change owner and group of all files and directories
  ###################################################################
  find $DESTDIR -print | xargs chown root
  find $DESTDIR -print | xargs chgrp ${GROUP}


  ##########################
  # New PRODUCT POSTINSTALL

  echo BEGIN PRODUCT POSTINSTALL >>$NULL 2>>$NULL

  OIFS="$IFS"
  IFS='	'

  PAS_f_get_pdef_table 'POSTINSTALL.ITB' |
    sed -n "/^${Product}[ ]*[	]/p" |
    while read Comp Command
    do
      # Space
      IFS=' '
      if [ "${Command}" ]
      then
        echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
        eval ${Command} >>$LOGFILE 2>>$LOGFILE
      fi
      # Tab
      IFS='	'
    done
  IFS="$OIFS"

  echo END PRODUCT POSTINSTALL >>$NULL 2>>$NULL

  #dmb:04/16/92:Added
  PAS_f_get_pdef_table "POSTINSTALL_NOTICE.ITB"
  PAS_f_get_pdef_table "PRODUCT_POSTINSTALL_NOTICE.ITB"
  PAS_f_get_pdef_table "${IDname}_POSTINSTALL_NOTICE.ITB"


  cat << !end_of_info_msg! | tee -a $LOGFILE

Please see $DESTDIR/README for information about this release.

!end_of_info_msg!

  date | tee -a $LOGFILE

fi
#dmb:04/13/92:END Added for PREPROCESS attempt

exit 0
