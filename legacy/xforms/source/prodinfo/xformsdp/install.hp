#!/bin/sh
########################################################################
# Copyright 1994 Intergraph Corporation
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

PRODUCT_NAME=xformsrt
VERSION=01.02.06.03
DATE=01-DEC-1994

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
# FUNCTION: PAS_f_manual_remove()
############################################################
PAS_f_manual_remove()
{
#  dmb:01/26/93:New function. Look to see whether product is already
#  installed on the target machine and offer to end this
#  installation so that the user can go remove it.
# dmb:01/27/93:We'll do this during the work ("install") part of 
# the installation to keep the setup ("preprocess") part brief.

#dmb:04/05/93:Added OS_KEY
  #Usage: PAS_f_manual_remove $ArchTypeKey $OS_KEY

  ArchTypeKey=$1
#dmb:04/05/93:Added OS_KEY
  OS_KEY=$2

  OLD_DIR=`proddata +%p -x $IDname`
  OLD_VER=`proddata +%v -x $IDname`

  # This is the test used by deltools dates to see whether a
  # product is actually installed.
  if [ -f "$OLD_DIR"/product.def ]
  then

# dmb:01/27/93:The default is to remove any other version.
#  Another fairly plausible default is to remove all older versions
#  and keep all newer versions.
#   Note the use of '[[ A > B ]]'.  Check for portability.
#        if [[ "$IDversion" > "$OLD_VER" ]]

    # Product is currently installed.
    if [ "$IDversion" = "$OLD_VER" ]
    then
      # The same version is installed.
      remove_default_answer='n'
    else
      # A different version is installed.
      remove_default_answer='y'
    fi
  fi

  if [ "$PREPROCESS" = "y" ]
  then

    # This is the test used by deltools dates to see whether a
    # product is actually installed.
    if [ -f "$OLD_DIR"/product.def ]
    then

      # Product is currently installed.
      remove_answer=`getanswer -c "\n\
Version $OLD_VER of $IDname is already installed in $OLD_DIR." \
 "Stop the current installation so $IDname can be removed?" \
 $remove_default_answer yesno`
      remove_answer=${remove_answer:-"$remove_default_answer"}

    else

      # Product is not currently installed.
      remove_answer="n"
    fi

    if [ "$remove_answer" != "n" ]
    then
      echo  | tee -a $LOGFILE
      echo "Stop the current installation of $IDname to remove $OLD_VER from $OLD_DIR." |
       tee -a $LOGFILE
      echo  | tee -a $LOGFILE

      return 2

    fi

  else

    # We're finished preprocessing.

    # This is the test used by deltools dates to see whether a
    # product is actually installed.
    if [ -f "$OLD_DIR"/product.def ]
    then

      # Product is currently installed.
      remove_answer=`getanswer -q \
       "Stop the current installation so $IDname can be removed?" \
       $remove_default_answer yesno`
      remove_answer=${remove_answer:-"$remove_default_answer"}

    echo "Version $OLD_VER of $IDname is already installed in $OLD_DIR." | tee -a $LOGFILE

    else
      # Product is not currently installed.
      remove_answer="n"
    fi

    if [ "$remove_answer" != "n" ]
    then
#dmb:04/05/93:Changed from ArchTypeKey to OS_KEY
      case $OS_KEY
      in
        CLIX )
          EXT=sh
          ;;
        IRIX )
          EXT=sgi
          ;;
        SUNOS4 )
          EXT=sun
          ;;
        SUNOS5 )
          SUNOS_HW=`uname -m`
          case $SUNOS_HW
          in
            i86pc )
              EXT=isl
            ;;
            sun* )
              EXT=ssl
            ;;
          esac
          ;;
        HPUX )
	  EXT=hp
          ;;

	#sml:08-17-93 add SCO
	SCO )
	  EXT=sco
	  ;;
      esac

      echo | tee -a $LOGFILE
      echo "Stopping the current installation of $IDname to remove $OLD_VER from $OLD_DIR." | tee -a $LOGFILE
      echo | tee -a $LOGFILE

      return 2

    fi
  fi
  # dmb:01/27/93:End if PREPROCESS = "y"

  return 0
}
############################################################
############################################################
# FUNCTION: PAS_f_auto_remove()
############################################################
PAS_f_auto_remove()
{
#  dmb:01/26/93:New function. Look to see whether product is already
#  installed on the target machine and offer to remove it.
# dmb:01/27/93:We'll do this during the work ("install") part of 
# the installation to keep the setup ("preprocess") part brief.

#dmb:04/05/93:Added OS_KEY
  #Usage: PAS_f_auto_remove $ArchTypeKey $OS_KEY

  ArchTypeKey=$1
#dmb:04/05/93:Added OS_KEY
  OS_KEY=$2

  OLD_DIR=`proddata +%p -x $IDname`
  OLD_VER=`proddata +%v -x $IDname`

  # This is the test used by deltools dates to see whether a
  # product is actually installed.
  if [ -f "$OLD_DIR"/product.def ]
  then

# dmb:01/27/93:The default is to remove any version found.
#  Another fairly plausible default is to any other version except
#   the current version.
#  Another is to remove all older versions and keep all newer versions.


#   Note the use of '[[ A > B ]]'.  Check for portability.
#        if [[ "$IDversion" > "$OLD_VER" ]]

    # Product is currently installed.
    if [ "$IDversion" = "$OLD_VER" ]
    then
      # The same version is installed.
      remove_default_answer='y'
#      remove_default_answer='n'
    else
      # A different version is installed.
      remove_default_answer='y'
    fi
  fi

  if [ "$PREPROCESS" = "y" ]
  then

    # This is the test used by deltools dates to see whether a
    # product is actually installed.
    if [ -f "$OLD_DIR"/product.def ]
    then

      # Product is currently installed.
      remove_answer=`getanswer -c "\n\
Version $OLD_VER of $IDname is already installed in $OLD_DIR." \
 "Remove currently installed version of $IDname before proceeding?" \
 $remove_default_answer yesno`
      remove_answer=${remove_answer:-"$remove_default_answer"}

    else

      # Product is not currently installed.
      remove_answer="n"
    fi

    if [ "$remove_answer" != "n" ]
    then
      echo  | tee -a $LOGFILE
      echo "Version $OLD_VER of $IDname will be removed from $OLD_DIR." |
       tee -a $LOGFILE
      echo  | tee -a $LOGFILE
    fi

  else

    # We're finished preprocessing.

    # This is the test used by deltools dates to see whether a
    # product is actually installed.
    if [ -f "$OLD_DIR"/product.def ]
    then

      # Product is currently installed.
      remove_answer=`getanswer -q \
       "Remove currently installed version of $IDname before proceeding?" \
       $remove_default_answer yesno`
      remove_answer=${remove_answer:-"$remove_default_answer"}

    echo "Version $OLD_VER of $IDname is already installed in $OLD_DIR." | tee -a $LOGFILE

    else
      # Product is not currently installed.
      remove_answer="n"
    fi

    if [ "$remove_answer" != "n" ]
    then
#dmb:04/05/93:Changed from ArchTypeKey to OS_KEY
      case $OS_KEY
      in
        CLIX )
          EXT=sh
          ;;
        IRIX )
          EXT=sgi
          ;;
        SUNOS4 )
          EXT=sun
          ;;
        SUNOS5 )
          SUNOS_HW=`uname -m`
          case $SUNOS_HW
          in
            i86pc )
              EXT=isl
            ;;
            sun* )
              EXT=ssl
            ;;
          esac
          ;;
	#sml:08-17-93 add SCO
	SCO )
	  EXT=sco
	  ;;
        HPUX )
	  EXT=hp
	  ;;
      esac

      echo | tee -a $LOGFILE
      echo "Removing version $OLD_VER of $IDname from $OLD_DIR." | tee -a $LOGFILE
      echo | tee -a $LOGFILE

#dmb:01/28/93: Added to fix SUN install.
      cd $TMPDIR
      TLOGFILE=$TMPDIR/log
      mv $LOGFILE $TLOGFILE

#dmb:03/27/93: Added in an attempt to prevent problems with 
#              remove script's directory removal.
      export PAS_AUTO_REMOVE_FLAG='y'

      echo "$OLD_DIR/remove.${EXT}  | tee -a $TLOGFILE"  >>$NULL 2>>$NULL
      $OLD_DIR/remove.${EXT} 2>&1 | tee -a $TLOGFILE
      echo | tee -a $TLOGFILE

      echo "Resuming $IDname installation..." | tee -a $TLOGFILE

# dmb:01/28/93:Make sure we have one of these again.
      PAS_f_mkdir $DESTDIR
      cd $DESTDIR
      mv $TLOGFILE $LOGFILE

    fi
  fi  # dmb:01/27/93:End if PREPROCESS = "y"

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

# dmb:04/05/93:Added for post ISS7.0 installation changes:
# dmb:04/05/93:Just use the first directory of $INGRHOME

# sml:11-16-94:Set INGRHOME based on OS_KEY
#INGRHOME=${INGRHOME:-/opt/ingr}

case $OS_KEY
in
    "CLIX" | "SCO" | "HPUX" | "SUNOS4" )
	INGRHOME=${INGRHOME:-/usr/ip32}
	;;

    "IRIX" )
	INGRHOME=${INGRHOME:-/var/opt/ingr}
	;;

    "SUNOS5" )
	INGRHOME=${INGRHOME:-/opt/ingr}
	;;

    * )
	INGRHOME=${INGRHOME:-/usr/ip32}
	;;
esac


#dmb:04/05/93:We could use this if we wanted to stay tied to ksh ...
#INGRHOME=${INGRHOME%%:*}
#dmb:04/05/93:... or we could use this in sh.
INGRHOME=`echo $INGRHOME | sed 's/:.*$//'`
export INGRHOME

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
# dmb:04/05/93:Added for post ISS7.0 installation changes:

#dmb:04/05/93:Changed to OS_KEY
UNAME_KEY=`uname -s | tr '[a-z]' '[A-Z]'`
case $UNAME_KEY
in
  CLIX )
    #dmb:04/21/93:INGRHOME is not supported for CLIX

#    INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
    INGR_DELIVER=$DESTDIR
    INGR_RUN=${INGR_RUN:-/usr}

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
#        DfltProcType=c100
#        DfltProcTypeKey=C100

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`inqcpuid`
#    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

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

#dmb:04/05/93:Added OS_KEY
    OS_KEY=CLIX
  ;;
    HP-UX )
    INGR_DELIVER=$DESTDIR
    INGR_RUN=${INGR_RUN:-/usr}


    INGRHOME=${INGRHOME:-/usr/ip32}
    INGRHOME=`echo $INGRHOME | sed 's/:.*$//'`


      ArchType=hpux
      ArchTypeKey=HPUX

      GROUP=sys
      INQ_LGLASS=false

      DfltProcType=hp9000
      DfltProcTypeKey=HP9000

      OS_KEY=HPUX
      ;;
  IRIX )
    #dmb:04/21/93:INGRHOME is not supported for IRIX

#    INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
#    INGR_DELIVER=$DESTDIR
#    INGR_RUN=${INGR_RUN:-/usr}

    IRIX_VERSION=`uname -r`
    case $IRIX_VERSION
    in
      4.* )
        OS_KEY=IRIX

        INGR_DELIVER=$DESTDIR
        INGR_RUN=${INGR_RUN:-/usr}
        ;;

      5.* )
        OS_KEY=IRIX

        INGRHOME=${INGRHOME:-/var/opt/ingr}
        INGRHOME=`echo $INGRHOME | sed 's/:.*$//'`

        INGR_DELIVER=$DESTDIR
        INGR_RUN=$INGRHOME
        ;;
      * )
        echo "Unknown IRIX_VERSION $IRIX_VERSION: Cannot set OS_KEY"
        ;;
    esac

    ArchType=mips
    ArchTypeKey=MIPS

    GROUP=sys
#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`inqcpuid`
#    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

    DfltProcType=mips
    DfltProcTypeKey=MIPS

#dmb:04/05/93:Added OS_KEY
#    OS_KEY=IRIX
  ;;
  SUNOS )
#dmb:08/18/94:Added INTEL_SOLARIS.
    GROUP=daemon

#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

#    ProcType=`arch`
#    ProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`arch`
#    DfltProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`

#dmb:04/05/93:Added with OS_KEY - BEGIN
    SUNOS_VERSION=`uname -r`
    case $SUNOS_VERSION
    in
      4.* )
        OS_KEY=SUNOS4

        ArchType=sun
        ArchTypeKey=SUN

        DfltProcType=sun4
        DfltProcTypeKey=SUN4

        #dmb:04/21/93:INGRHOME is not supported for SUNOS4

#        INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
        INGR_DELIVER=$DESTDIR
        INGR_RUN=${INGR_RUN:-/usr}
        ;;
      5.* )
        OS_KEY=SUNOS5
        SUNOS_HW=`uname -m`
        case $SUNOS_HW
        in
          i86pc )
            ArchType=isl
            ArchTypeKey=INTEL_SOLARIS
 
            DfltProcType=i86pc
            DfltProcTypeKey=I86PC
          ;;
          sun* )
            ArchType=sun
            ArchTypeKey=SUN

            DfltProcType=sun4
            DfltProcTypeKey=SUN4
          ;;
        esac


        #dmb:04/21/93:INGRHOME is only supported for SUNOS5

        #dmb:04/05/93:Just use the first directory of $INGRHOME
        INGRHOME=${INGRHOME:-/opt/ingr}
        #dmb:04/05/93:We could use this if we wanted to stay tied to ksh.
        #INGRHOME=${INGRHOME%%:*}
        #dmb:04/05/93:... or we could use this in sh.
        INGRHOME=`echo $INGRHOME | sed 's/:.*$//'`

#        INGR_DELIVER=$INGRHOME
        INGR_DELIVER=$DESTDIR
        INGR_RUN=$INGRHOME
        ;;
      * )
        echo "Unknown SUNOS_VERSION $SUNOS_VERSION: Cannot set OS_KEY"
        ;;
    esac

    export SUNOS_VERSION

#dmb:04/05/93:Added with OS_KEY - END

  ;;

  * )
    OS_SECONDARY_KEY=`uname -p | tr '[a-z]' '[A-Z]'`
    case $OS_SECONDARY_KEY
    in
    I386 )
      ArchType=sco
      ArchTypeKey=SCO

      GROUP=sys
#    INQ_LGLASS=inqlgexist
      INQ_LGLASS=false

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`inqcpuid`
#    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

      DfltProcType=i386
      DfltProcTypeKey=I386

#dmb:04/05/93:Added OS_KEY
      OS_KEY=SCO

#    INGR_DELIVER=$DESTDIR
#    INGR_RUN=${INGR_RUN:-/usr}

      INGR_RUN=/usr
      ;;
    
    I486 )
      ArchType=sco
      ArchTypeKey=SCO

      GROUP=sys
#    INQ_LGLASS=inqlgexist
      INQ_LGLASS=false

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`inqcpuid`
#    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

      DfltProcType=i486
      DfltProcTypeKey=I486

#dmb:04/05/93:Added OS_KEY
      OS_KEY=SCO
      INGR_RUN=/usr

#    INGR_DELIVER=$DESTDIR
#    INGR_RUN=${INGR_RUN:-/usr}

      ;;
    * )
      echo "Can not deliver ${IDtitle} to `uname -s`" >&2
      exit 2
      ;;
    esac
  ;;
esac


#dmb:04/21/93:This may cause some problems if we add INGRHOME support
#             to the other platforms, although it is technically
#             correct according to DELTOOLS README.
INGRHOME=${INGRHOME:-$INGR_DELIVER}
export INGRHOME

#dmb:01/26/93:dmb:04/05/93:Added OS_KEY
export ArchTypeKey OS_KEY

######################################################################
###  Make the default directory to put the product in
######################################################################
PAS_f_mkdir $DESTDIR

# This may not be neccessary and needs to be examiled.
#dmb:01/28/93:This needs to be watched especially closely on the SUN
cd $DESTDIR

###################################
###  Set up the log file name
###################################
# dmb:01/28/93:Note if log is in TMPDIR, we don't need to create DESTDIR
#  until after the auto_remove, but it gets lost if the installation
#  fails.
LOGFILE=$DESTDIR/log.new
#LOGFILE=$TMPDIR/log
if [ "$PREPROCESS" = "y" ]
then
  rm -f $LOGFILE
fi

if [ "$VERBOSE" ]
then
  NULL=/dev/tty
else
  NULL=/dev/null
fi
export NULL

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
  HPUX )
    if [ "$HPUX_IDversion" ]
    then
      IDversion=$HPUX_IDversion
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
  SCO )
    if [ "$SCO_IDversion" ]
    then
      IDversion=$SCO_IDversion
    fi
    ;;
esac
echo IDversion is now $IDversion >>$NULL 2>>$NULL

#
# ProductAnnce
#

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


#
# Product PrePreprocess:dmb:02/03/93:Added to help work around
#  autoremove problem
# dmb:02/06/93:Removed PREPROCESS restriction so this will get done
#     for default installations as well.
#

echo BEGIN PRODUCT PREPREPROCESS >>$NULL 2>>$NULL

OIFS="$IFS"
IFS='	'

PAS_f_get_pdef_table 'PREPREPROCESS.ITB'  | tail +3 |
   awk 'BEGIN {IFS=OFS="	"} \
              { if ( $1 == "'${Product}'" && \
                   ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                { \
                  print \
                } \
              }' |
  while read Comp ArchKey Command
  do
    # Space
    IFS=' '
    if [ "${Command}" ]
    then
      echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
# dmb:01/27/93:Original
#      eval ${Command} >>$LOGFILE 2>>$LOGFILE
      eval ${Command} 2>&1 | tee -a $LOGFILE
    fi
    # Tab
    IFS='	'
  done
  IFS="$OIFS"

echo END PRODUCT PREPREPROCESS >>$NULL 2>>$NULL

#
# End Product PrePreprocess
#

# These should probably be done in product.def for better control.
PAS_f_get_pdef_table "PREINSTALL_NOTICE.ITB"
PAS_f_get_pdef_table "PRODUCT_PREINSTALL_NOTICE.ITB"
PAS_f_get_pdef_table "${IDname}_PREINSTALL_NOTICE.ITB"
# dmb:01/26/93:Added
PAS_f_get_pdef_table "${ArchTypeKey}_PREINSTALL_NOTICE.ITB"

# dmb:01/26/93:Added
PAS_f_auto_remove ${ArchTypeKey} $OS_KEY

# dmb:04/20/92:Fallback attempt if auto_remove isn't accepted.
#PAS_f_manual_remove ${ArchTypeKey} $OS_KEY
#PASstatus=$?
#if [ "$PASstatus" -ne 0 ]
#then
#  exit $PASstatus
#fi

#dmb:01/28/93:Begin New location
#PAS_f_mkdir $DESTDIR
#cd $DESTDIR
#dmb:01/28/93:End New location

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
# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
    if [ "${TargetProcTypeKey}" = 'C400' ]
    then
      DeliveredProcTypes="$DfltProcTypeKey and $OtherAvailProcTypes"
      cat << !end_of_proc_type_info! | tee -a $LOGFILE

$DeliveredProcTypes images will be delivered to this machine by default.

!end_of_proc_type_info!
    else
      cat << !end_of_proc_type_info! | tee -a $LOGFILE

$DfltProcTypeKey images will be delivered to this machine by default.
$OtherAvailProcTypes images are also available.

!end_of_proc_type_info!
    fi

  else
    cat << !end_of_proc_type_info2! | tee -a $LOGFILE

$DfltProcTypeKey images will be delivered to this machine.

!end_of_proc_type_info2!

  fi

  if [ "$DEFAULTS" = 'y' ]
  then
# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
    if [ "${TargetProcTypeKey}" = 'C400' ]
    then
      Others='y'
    else
      Others='n'
    fi
  else
    if [ "$OtherAvailProcTypes" ]
    then
# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
      if [ "${TargetProcTypeKey}" = 'C400' ]
      then
        Others='y'
      else
        Others=`getanswer "Install images for other processor types?" "n"`
      fi
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

# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
      if [ "${TargetProcTypeKey}" = 'C400' ]
      then
        case $InstProcType
        in
          C100|C400 )
            InstOther='y'
            ;;
          * )
            InstOther=`getanswer "Install $InstProcType processor images?" "$d"`
            ;;
        esac
      else
        InstOther=`getanswer "Install $InstProcType processor images?" "$d"`
      fi

      if [ "$InstOther" = 'y' ]
      then
        INSTALL_PROC_TYPES="$INSTALL_PROC_TYPES $InstProcType"
      fi
    done
  fi
else
# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
  if [ "${TargetProcTypeKey}" = 'C400' ]
  then
    Others='y'
  else
    Others=`getanswer -q "Install images for other processor types?"`
  fi
  Others=${Others:-n}

  INSTALL_PROC_TYPES=""
  if [ "$Others" = 'n' ]
  then
    INSTALL_PROC_TYPES="$DfltProcTypeKey"
  else
    for InstProcType in $OtherProcTypeList $DfltProcTypeKey
    do
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
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

if [ "$PREPROCESS" != "y" ]
then

  echo BEGIN PRODUCT PREINSTALL >>$NULL 2>>$NULL

  OIFS="$IFS"
  IFS='	'

  PAS_f_get_pdef_table 'PREINSTALL.ITB'  | tail +3 |
     awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Product}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' |
    while read Comp ArchKey Command
    do
      # Space
      IFS=' '
      if [ "${Command}" ]
      then
        echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
# dmb:01/27/93:Original
#        eval ${Command} >>$LOGFILE 2>>$LOGFILE
        eval ${Command} 2>&1 | tee -a $LOGFILE
      fi
      # Tab
      IFS='	'
    done
    IFS="$OIFS"

  echo END PRODUCT PREINSTALL >>$NULL 2>>$NULL

fi

#
# End Product PreInstall
#

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

#   GetSelection

# dmb:04/20/92:
  if [ "$Default" = "deliver" ]
  then
    Selected="y"
  else
#dmb:02/05/93:New Location
    if [ "$PREPROCESS" = "y" ]
    then
      echo
      echo "A total of $total_space blocks have already been requested."
      echo "The ${Title} require $Size blocks,"
      echo "  making a total of $requested_space blocks required."
    fi
#dmb:02/05/93:End New Location

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
        #dmb:02/05/93:Added
        if [ "$PREPROCESS" = "y" ]
        then
          echo "${Title} will be installed."
        fi
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
#    echo "Installing $PROC_TYPE_KEY images..." | tee -a $LOGFILE

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
      I86PC )
        ProcType=i86pc
        ProcTypeKey=I86PC
        ProcSuffix=i
        ;;
      I386 )
        ProcType=i386
        ProcTypeKey=i386
        ProcSuffix=i3
        ;;
      I486 )
        ProcType=i486
        ProcTypeKey=i486
        ProcSuffix=i4
        ;;
      HP9000 )
	ProcType=hp9000
	ProcTypeKey=HP9000
	ProcSuffix=hp
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

      PAS_f_get_pdef_table 'PREINSTALL.ITB'  | tail +3 |
        awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' |
        while read Comp ArchKey Command
        do
          # Space
          IFS=' '
          if [ "${Command}" ]
          then
            echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
# dmb:01/27/93:Original
#           eval ${Command} >>$LOGFILE 2>>$LOGFILE
            eval ${Command} 2>&1 | tee -a $LOGFILE
          fi
          # Tab
          IFS='	'
        done
      IFS="$OIFS"

      echo END COMPONENT PREINSTALL >>$NULL 2>>$NULL


    #   Get Component

      #dmb:02/05/93:Added
      echo "Installing the ${Title} for $PROC_TYPE_KEY." | tee -a $LOGFILE
      getfile "${Component}.p${ProcSuffix}" - |
          compress -d | cpio -ivmudc >>$LOGFILE 2>>$LOGFILE
          
	  #compress -d | cpio -ivmud >>$LOGFILE 2>>$LOGFILE

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

      PAS_f_get_pdef_table 'POSTINSTALL.ITB'  | tail +3 |
        awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Component}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' |
        while read Comp ArchKey Command
        do
          # Space
          IFS=' '
          if [ "${Command}" ]
          then
            echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
# dmb:01/27/93:Original
#           eval ${Command} >>$LOGFILE 2>>$LOGFILE
            eval ${Command} 2>&1 | tee -a $LOGFILE
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

  PAS_f_get_pdef_table 'POSTINSTALL.ITB'  | tail +3 |
    awk 'BEGIN {IFS=OFS="	"} \
                { if ( $1 == "'${Product}'" && \
                     ( $2 == "'${ArchTypeKey}'" || $2 == "ALL" ) ) \
                  { \
                    print \
                  } \
                }' |
    while read Comp ArchKey Command
    do
      # Space
      IFS=' '
      if [ "${Command}" ]
      then
        echo "eval ${Command} >>$LOGFILE 2>>$LOGFILE" >>$NULL 2>>$NULL
# dmb:01/27/93:Original
#       eval ${Command} >>$LOGFILE 2>>$LOGFILE
        eval ${Command} 2>&1 | tee -a $LOGFILE
      fi
      # Tab
      IFS='	'
    done
  IFS="$OIFS"

  echo END PRODUCT POSTINSTALL >>$NULL 2>>$NULL

  # dmb:02/05/93:Added kludges since newprod doesn't do this anymore.
  INFO_CHANGE_LIST="$TMPDIR/README* $TMPDIR/product.def"
  for file in $INFO_CHANGE_LIST
  do
    chmod 544 $file
    chown root $file
    chgrp $GROUP $file
  done

  SCRIPT_CHANGE_LIST="$DESTDIR/checkinst.*  $TMPDIR/remove.*"
  for file in $SCRIPT_CHANGE_LIST
  do
    chmod 755 $file
    chown root $file
    chgrp $GROUP $file
  done

  #dmb:04/16/92:Added
  PAS_f_get_pdef_table "POSTINSTALL_NOTICE.ITB"
  PAS_f_get_pdef_table "PRODUCT_POSTINSTALL_NOTICE.ITB"
  PAS_f_get_pdef_table "${IDname}_POSTINSTALL_NOTICE.ITB"
# dmb:01/26/93:Added
  PAS_f_get_pdef_table "${ArchTypeKey}_POSTINSTALL_NOTICE.ITB"

  cat << !end_of_info_msg! | tee -a $LOGFILE

Please see $DESTDIR/README for information about this release.

!end_of_info_msg!

  date | tee -a $LOGFILE

  mv -f $LOGFILE $DESTDIR/product.log

fi
#dmb:04/13/92:END Added for PREPROCESS attempt

exit 0
