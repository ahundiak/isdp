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

# Remove Product

PRODUCT_NAME=ums
VERSION=02.01.06.00
DATE=29-NOV-1994

##########################################################################
#  
#
# The Plan:
#        +-- ProdPreRemove
#        |                   +-- CompPreRemove
#Remove -+-- ProdRemove -----+-- CompRemove
#        |                   +-- CompPostRemove
#        +-- ProdPostRemove
#
###########
#   setup environment
#    
##   Remove Components
#
# Get Installed Component List (SelectedList)
#    ProductPreRemove ${Product}
#    for Component in $SelectedList
#    do
#      preremove ${Component}
#      mv_rm_files ${Component}
#      postremove ${Component}
#    done
#
#    ProductPost ${Product}
#    ProductCleanup
#      Remove ingrconfig entry here
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
# FUNCTION: PAS_f_rm_symlink_files ()
########################################################################
# Remove symbolically linked files as necessary.
########################################################################
PAS_f_rm_symlink_files ()
{
  # USAGE: PAS_f_rm_symlink_files $Component $DESTDIR ${ArchTypeKey}

  Component=$1
  DESTDIR=$2  
  ArchTypeKey=$3

  #dmb:04/28/93:Chagnged because SCO_UNIX gives errors if filenames are too long
#  WF1=$TMPDIR/symlnk$$
  TFILENAME=`echo symlnk$$ | cut -c1-14`
  WF1=$TMPDIR/$TFILENAME
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

    ### remove old symbolic link
    echo "rm -f $Directory/$FILE" >>$NULL 2>>$NULL
    rm -f $Directory/$FILE >>$LOGFILE 2>>$LOGFILE

  done

  IFS="$OIFS"
  rm -f $WF1
}
########################################################################
########################################################################
########################################################################


#
# Setup Product Environment
#

# dmb:04/05/93:Added for post ISS7.0 installation changes:
OS_KEY=`uname -s | tr '[a-z]' '[A-Z]'`
case $OS_KEY
in
  CLIX )
    #dmb:04/21/93:INGRHOME is not supported for CLIX
    INGRHOME=/usr/ip32
#    INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
    INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
    INGR_RUN=${INGR_RUN:-/usr}

    ;;

  IRIX )
    #dmb:04/21/93:INGRHOME is not supported for IRIX
#    INGRHOME=/usr/ip32
    INGRHOME=/var/opt/ingr
#    INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
    INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
    INGR_RUN=${INGR_RUN:-/usr}

    CONF="/usr/etc/inetd.conf"
#    CONF="$INGR_RUN/etc/inetd.conf"
    ;;
  SUNOS )
    SUNOS_VER=`uname -r`
    case $SUNOS_VER
    in
      4.* )
        #dmb:04/21/93:INGRHOME is not supported for SUNOS4
        INGRHOME=/usr/ip32
#        INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
        INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
        INGR_RUN=${INGR_RUN:-/usr}

        OS_KEY=SUNOS4
        psargs="aux"
        ;;
      5.* )
        #dmb:04/21/93:INGRHOME is only supported for SUNOS5

        INGRHOME=${INGRHOME:-/opt/ingr}
        #dmb:04/21/93:Trim INGRHOME down to the first directory only.
        INGRHOME=`echo $INGRHOME | sed 's/:.*//'`

        INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
#        INGR_DELIVER=${INGR_DELIVER:-$INGRHOME}
        INGR_RUN=${INGR_RUN:-$INGRHOME}

        OS_KEY=SUNOS5
        psargs="ef"
        ;;
    esac
    ;;

  HP-UX )
    INGRHOME=${INGRHOME:-/usr/ip32}
    #sml:11-29-94:Trim INGRHOME down to the first directory only.
    INGRHOME=`echo $INGRHOME | sed 's/:.*//'`

    INGR_DELIVER=$DESTDIR
    INGR_RUN=${INGR_RUN:-/usr}

    ArchType=hpux
    ArchTypeKey=HPUX

    GROUP=sys
    INQ_LGLASS=false

    SYMLINK_TEST=-l

    DfltProcType=hp9000
    DfltProcTypeKey=HP9000

    OS_KEY=HPUX
  ;;

#  HYDRA|SCO )
#    #dmb:04/28/93:Temporary kludge
#    OS_KEY=SCO
#    #dmb:04/21/93:INGRHOME is only supported for SUNOS5

   * )
#sml:07-27-93   add this since SCO UNIX doesn't interpret uname -s
#               like God intended.  Instead we query uname -m and infer
#               OS_KEY from the processor type.  (yeah, a real robust
#               solution.

    SECONDARY_OS_KEY=`uname -m`
    if [ $SECONDARY_OS_KEY = "i386" ]
    then
      OS_KEY=SCO
    elif [ $SECONDARY_OS_KEY = "i486" ]
    then
      OS_KEY=SCO
    fi

	if [ $OS_KEY = "SCO" ]
	then
      #INGRHOME=${INGRHOME:-/opt/ingr}
      INGRHOME=${INGRHOME:-/usr/ip32}
      #dmb:04/21/93:Trim INGRHOME down to the first directory only.
      INGRHOME=`echo $INGRHOME | sed 's/:.*//'`

      INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
      #        INGR_DELIVER=${INGR_DELIVER:-$INGRHOME}
      INGR_RUN=${INGR_RUN:-$INGRHOME}

      #dmb:04/28/93:Use section from IRIX if INGRHOME is not supported for SCO
      #    #dmb:04/21/93:INGRHOME is not supported for SCO
      #    INGRHOME=/usr/ip32
      #    INGR_DELIVER=${INGR_DELIVER:-/usr/ip32}
      #    INGR_DELIVER=${INGR_DELIVER:-`proddata '+%p' -x $PRODUCT_NAME`}
      #    INGR_RUN=${INGR_RUN:-/usr}
	fi

    ;;

esac

#dmb:04/21/93:Use TMPDIR if set.
TMPDIR=${TMPDIR:-$INGR_RUN/tmp}

#dmb:04/21/93:Make sure TMPDIR is there
if [ ! -d $TMPDIR ]
then
  mkdir -p $TMPDIR
fi

export INGRHOME

Product=$PRODUCT_NAME
ProdKey="`echo $Product | tr '[a-z]' '[A-Z]'`"

################################################################
# Get product directory name
################################################################
DESTDIR=`proddata +%p -x $Product`
export DESTDIR

# See if the product directory is symbolically linked elsewhere.
# proddata returns REAL_PATH
# Check this logic on installation to other filesystem
DESTDIRBASE=`basename $DESTDIR`

if [ "$INGRHOME/$DESTDIRBASE" = "$DESTDIR" ]
then
# Product is under $INGRHOME (/usr/ip32)
  LINK_PATH=""
else
# the product is really in $DESTDIR and symbolically linked to /usr
  LINK_PATH="$INGRHOME/$DESTDIRBASE"
fi


P_DEF=$DESTDIR/product.def
if [ ! -f $P_DEF ]
then
  echo "`basename $0`: WARNING! Can not find product.def file for $Product" >&2

# Temporary. Could ask about continuing and remove the product directory.
# Could possibly ls -ls common directories ( eg. /usr/bin, /usr/lib,
# etc. and remove everything symlinked to $PRODDIR.
  exit 2
fi

. $P_DEF

if [ $OS_KEY = "SCO" ]
then
  #sml:07-15-93	We need to remove this hard-coded stuff here 
  DFLTS=/usr/ip32/.defaults
else
  DFLTS=$INGRHOME/.defaults
fi

if [ ! -f $DFLTS ]
then
  echo "`basename $0`: WARNING! Can not find installation defaults file $DFLTS for $Product" >&2

# Temporary. Could ask about continuing and remove the product directory.
# Could just try to remove all components found in product.def

  exit 2
fi


PATH=$DESTDIR:$DESTDIR/bin:$PATH
export PATH

###################################
###  Set up the log file name
###################################

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

#dmb:02/06/93:Try this for nested remove problem...
LOGFILE=${LOGFILE:-/dev/tty}
#LOGFILE=/dev/tty
export LOGFILE

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
case `uname -s`
in
  CLIX )
    ArchType=clipper
    ArchTypeKey=CLIPPER

    GROUP=sys
    INQ_LGLASS=inqlgexist

    SYMLINK_TEST=-L

# dmb:05/09/92: If this is not a server, install default proc type images.
# dmb:05/09/92: If this is a server, ask about what proctype(s) to install.
#    ProcType=`inqcpuid`
#    ProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

# dmb:05/11/92: Install C100 images by default on CLIX since they'll
#               run on all CLIX machines.
#    DfltProcType=c100
#    DfltProcTypeKey=C100

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
  ;;

  IRIX )
    ArchType=mips
    ArchTypeKey=MIPS

    GROUP=sys
#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

    SYMLINK_TEST=-l

# dmb:06/26/92: Simply inquire for all machines...
# dmb:10/23/92: We need to come to some consessus as to how to say this
#               on MIPS
#    DfltProcType=`inqcpuid`
#    DfltProcTypeKey=`inqcpuid | tr '[a-z]' '[A-Z]'`

    DfltProcType=mips
    DfltProcTypeKey=MIPS
  ;;
  SunOS )
#dmb:08/18/94:Added INTEL_SOLARIS.
    GROUP=daemon
#    INQ_LGLASS=inqlgexist
    INQ_LGLASS=false

    SYMLINK_TEST=-h

#    ProcType=`arch`
#    ProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`

# dmb:06/26/92: Simply inquire for all machines...
#    DfltProcType=`arch`
#    DfltProcTypeKey=`arch | tr '[a-z]' '[A-Z]'`

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

  ;;

  HP-UX )
    INGR_DELIVER=$DESTDIR
    INGR_RUN=${INGR_RUN:-/usr}

    ArchType=hpux
    ArchTypeKey=HPUX

    GROUP=sys
    INQ_LGLASS=false

    SYMLINK_TEST=-l

    DfltProcType=hp9000
    DfltProcTypeKey=HP9000

    OS_KEY=HPUX
    ;;

#  HYDRA|SCO|hydra|sco )
#    #dmb:04/28/93:Temporary kludge for SCO. since uname may be unreliable
#    OS_KEY=SCO

   * )
#sml:07-27-93   add this since SCO UNIX doesn't interpret uname -s
#               like God intended.  Instead we query uname -m and infer
#               OS_KEY from the processor type.  (yeah, a real robust
#               solution.

     SECONDARY_OS_KEY=`uname -m`
     if [ $SECONDARY_OS_KEY = "i386" ]
     then
       OS_KEY=SCO
     elif [ $SECONDARY_OS_KEY = "i486" ]
     then
       OS_KEY=SCO
     fi

	if [ $OS_KEY = "SCO" ]
	then
      SYMLINK_TEST=-L

      #dmb:04/21/93:INGRHOME is not supported for SCO

      #    INGR_DELIVER=${INGR_DELIVER:-/opt/ingr}
      INGR_DELIVER=$DESTDIR
      INGR_RUN=${INGR_RUN:-/usr}

      ArchType=sco
      ArchTypeKey=SCO

      GROUP=sys
      #    INQ_LGLASS=inqlgexist
      INQ_LGLASS=false

      #    DfltProcType=i486
      #    DfltProcTypeKey=I486

      DfltProcType=i386
      DfltProcTypeKey=I386

      #    DfltProcType=`uname -m`
      #    DfltProcTypeKey=`uname -m | tr '[a-z]' '[A-Z]'`
	else
      #  * )
      echo "Can not remove ${IDtitle} from X`uname -s`X" >&2
      exit 2
	fi
  ;;
esac


PRODNAME=$ProdKey
export PRODNAME

# dmb:05/11/92: Method 1: Look at .defaults
SupportedProcTypes="`PAS_f_get_pdef_table 'SUPPORTED_PROCESSOR_TYPES.ITB' |
  tail +3 |
  awk -F'	' \
  '{ if ( $1 == \"'${ArchTypeKey}'\" || $1 == \"ALL\" ) \
    {print $2;} \
  }' -`"

OtherProcTypeList="`echo $SupportedProcTypes |
  sed \"s/${DfltProcTypeKey}//;s/^ //;s/ $//;s/  / /\"`"
OtherAvailProcTypes="`echo $OtherProcTypeList | sed 's/ [^ ]*$/ and&/'`"

#echo "$DfltProcTypeKey images were delivered to this machine by default."
#echo "$OtherAvailProcTypes images were also available"

# dmb:01/07/93: Install C100 images by default on all CLIPPERS
# dmb:01/07/93: Also install C400 images by default on C400 CLIPPERS
if [ "${TargetProcTypeKey}" = 'C400' ]
then
  Others='y'
else
  Others=`getanswer -q "Install images for other processor types?"`
fi

Others=${Others:-n}

REMOVE_PROC_TYPES=""

if [ "$Others" = 'n' ]
then
  REMOVE_PROC_TYPES="$DfltProcTypeKey"
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
      REMOVE_PROC_TYPES="$REMOVE_PROC_TYPES $InstProcType"
    fi
  done
fi

# dmb:05/11/92: Method 2: Look at what is actually installed under bin
#   as a first order guess... (untested)
# Note: may have to look for lib directory, too.
#for dir in `find $DESTDIR -type d -print | sed -n '/\/bin\/p'`
#do
#  InstProcType=`basename $dir`
#  REMOVE_PROC_TYPES="$REMOVE_PROC_TYPES $InstProcType"
#done

REMOVE_PROC_TYPES="`echo $REMOVE_PROC_TYPES |
  sed 's/^ //;s/ $//;s/  / /'`"
echo "Remove images for $REMOVE_PROC_TYPES"

REMOVE_PROC_TYPE_LIST="`echo $REMOVE_PROC_TYPES | tr '[A-Z]' '[a-z]'`"


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
  HPUX )
    if [ "$HPUX_IDversion" ]
    then
      IDversion=$HPUX_IDversion
    fi
  ;;

esac
echo IDversion is now $IDversion >>$NULL 2>>$NULL


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



echo                                           >>$LOGFILE 2>>$LOGFILE
echo "Removing ${IDtitle} ( version ${IDversion} )" \
                                               >>$LOGFILE 2>>$LOGFILE
echo " from $DESTDIR"         >>$LOGFILE 2>>$LOGFILE

date >>$LOGFILE 2>>$LOGFILE



#
# ProductPreRemove
#
##########################
# New PRODUCT PREREMOVE

# dmb:01/26/93:Added
PAS_f_get_pdef_table "PREREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "PRODUCT_PREREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "${IDname}_PREREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "${ArchTypeKey}_PREREMOVE_NOTICE.ITB"

echo BEGIN PRODUCT PREREMOVE >>$NULL 2>>$NULL

OIFS="$IFS"
IFS='	'

#dmb:01/27/93:Begin Original
#PAS_f_get_pdef_table 'PREREMOVE.ITB' |
#  sed -n "/^${Product}[ ]*[	]/p" |
#  while read Comp Command
##dmb:01/27/93:End Original

PAS_f_get_pdef_table 'PREREMOVE.ITB'  | tail +3 |
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

echo END PRODUCT PREREMOVE >>$NULL 2>>$NULL
##########################

#
# Get Selections
#
# Get AvailableList from $P_DEF



AvailableList="`PAS_f_get_pdef_table 'INSTALL.ITB' | tail +3 |
    cut -f1 -d'	'`"


echo AvailableList is $AvailableList >>$NULL 2>>$NULL


####################
# Get SelectedList
SelectedList=""


#
# BEGIN SELECT COMPONENT LOOP
#
# Note: for things to work out right, all Default='deliver' components
# should be removed last.

for Component in $AvailableList
do
  Delivered=''

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


  # Hold for now. We may want to do something fancy...
  #  Size="`PAS_f_get_pdef_table 'SPACE.ITB' | tail +3 |
  #   awk -F'	' '$1 == \"'$Component'\" && $2 == \"'$ProcType'\" {print $3}'`"
  #echo Size is $Size           >>$NULL 2>>$NULL

  if [ "$Default" = "deliver" ]
  then
     Delivered="y"
  else
    Prompt="Deliver the ${Title}?"
    echo Prompt: $Prompt       >>$NULL 2>>$NULL

    # Must set this for getanswer to work. Use PRODNAME for ProdKey?
    PRODNAME=$ProdKey
    export PRODNAME
    Delivered=`getanswer -q "$Prompt"`

  fi

  case "$Delivered"
  in
    [Yy]|[Yy][Ee]|[Yy][Ee][Ss] )
      echo $Component WAS delivered      >>$NULL 2>>$NULL
      SelectedList="$Component $SelectedList"
    ;;
    * )
      echo $Title WAS NOT delivered.     >>$NULL 2>>$NULL
    ;;
  esac

done

echo SelectedList is $SelectedList       >>$NULL 2>>$NULL

# END SELECT COMPONENT LOOP


##################################
# Begin PROC_TYPE LOOP
##################################
for PROC_TYPE in $REMOVE_PROC_TYPE_LIST
do
  PROC_TYPE_KEY=`echo $PROC_TYPE | tr '[a-z]' '[A-Z]'`
  export PROC_TYPE PROC_TYPE_KEY
  echo "Removing images for $PROC_TYPE_KEY"


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
      I486 )
        ProcType=i486
        ProcTypeKey=I486
        ProcSuffix=i4
        ;;
      I386 )
        ProcType=i386
        ProcTypeKey=I386
        ProcSuffix=i3
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
      HP9000 )
	ProcType=hp9000
	ProcTypeKey=HP9000
	ProcSuffix=hp
	;;
      * )
        echo "Can not remove ${IDtitle} from $PROC_TYPE_KEY" >&2
        exit 2
        ;;
    esac


  #
  # Remove Components
  #

  # BEGIN REMOVE COMPONENT LOOP
  for Component in $SelectedList
  do

  #   ComponentPreRemove

    echo BEGIN COMPONENT PREREMOVE >>$NULL 2>>$NULL

    OIFS="$IFS"
    IFS='	'

   #dmb:01/27/93:Begin Original
#    PAS_f_get_pdef_table 'PREREMOVE.ITB' |
#      sed -n "/^${Component}[ ]*[	]/p" |
#      while read Comp Command
   #dmb:01/27/93:End Original

    PAS_f_get_pdef_table 'PREREMOVE.ITB'  | tail +3 |
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
#          eval ${Command} >>$LOGFILE 2>>$LOGFILE
          eval ${Command} 2>&1 | tee -a $LOGFILE
        fi
        # Tab
        IFS='	'
      done
    IFS="$OIFS"

    echo END COMPONENT PREREMOVE >>$NULL 2>>$NULL

    ##########################

    # ComponentRemove
    PAS_f_rm_symlink_files ${Component} ${DESTDIR} ${ArchTypeKey}
    PAS_f_mv_rm_files ${Component} ${DESTDIR} ${ArchTypeKey}


  #   ComponentPostRemove
    ##########################
    # New COMPONENT POSTREMOVE

    echo BEGIN COMPONENT POSTREMOVE >>$NULL 2>>$NULL

    OIFS="$IFS"
    IFS='	'

   #dmb:01/27/93:Begin Original
#    PAS_f_get_pdef_table 'POSTREMOVE.ITB' |
#      sed -n "/^${Component}[ ]*[	]/p" |
#      while read Comp Command
   #dmb:01/27/93:End Original

    PAS_f_get_pdef_table 'POSTREMOVE.ITB'  | tail +3 |
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
#          eval ${Command} >>$LOGFILE 2>>$LOGFILE
          eval ${Command} 2>&1 | tee -a $LOGFILE
        fi
        # Tab
        IFS='	'
      done
    IFS="$OIFS"

    echo END COMPONENT POSTREMOVE >>$NULL 2>>$NULL

  done
  # END REMOVE COMPONENT LOOP

done
##################################
# End PROC_TYPE LOOP
##################################


# ProductPostRemove
##########################
# New PRODUCT POSTREMOVE

echo BEGIN PRODUCT POSTREMOVE >>$NULL 2>>$NULL

OIFS="$IFS"
IFS='	'

#dmb:01/27/93:Begin Original
#PAS_f_get_pdef_table 'POSTREMOVE.ITB' |
#  sed -n "/^${Product}[ ]*[	]/p" |
#  while read Comp Command
#dmb:01/27/93:End Original

PAS_f_get_pdef_table 'POSTREMOVE.ITB'  | tail +3 |
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

echo END PRODUCT POSTREMOVE >>$NULL 2>>$NULL

# dmb:01/26/93:Added
PAS_f_get_pdef_table "POSTREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "PRODUCT_POSTREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "${IDname}_POSTREMOVE_NOTICE.ITB"
PAS_f_get_pdef_table "${ArchTypeKey}_POSTREMOVE_NOTICE.ITB"

##########################

# ProductPost
# Remove product directories
###################################
### remove the real product directory
###################################
echo ""
echo "Removing the $ProdKey directory $DESTDIR"
echo ""
echo "rm -rf $DESTDIR >>$NULL 2>>$NULL" >>$NULL 2>>$NULL
rm -rf $DESTDIR >>$NULL 2>>$NULL

###########################################################
### remove the symbolically linked product directory, if any
###########################################################

if [ "$LINK_PATH" ]
then
  if [ "$SYMLINK_TEST" "$LINK_PATH" ]
  then
    echo ""
    echo "Removing symbolic link directory at $LINK_PATH"
    echo ""
    echo "rm -rf $LINK_PATH >>$NULL 2>>$NULL" >>$NULL 2>>$NULL
    rm -rf $LINK_PATH >>$NULL 2>>$NULL
  fi
fi



echo ""                                          >>$LOGFILE 2>>$LOGFILE
echo "Finished removing $ProdKey"  >>$LOGFILE 2>>$LOGFILE
echo ""                                          >>$LOGFILE 2>>$LOGFILE


# dmb,sml:03/27/93:Adding POST-REMOVE for TR#249202619.
# Clean out directory contents first just in case we're actually in the
# directory
# We need to NOT DO THIS if we're removing as part of the autoremove phase
# of installation. - sml
 if [ "$PAS_AUTO_REMOVE_FLAG" != "y" ]
 then
   rm -rf $DESTDIR/* >/dev/null 2>/dev/null
   rm -rf $DESTDIR >/dev/null 2>/dev/null
 fi
#
# Remove entry from ingrconfig
# dmb:01/27/93:The deltools folks clued us in to this trick... Thanx!!
#  Running dates will clean out ingrconfig entries which point to 
#  empty directories.  We'll add the product name here as a
#  verification that the remove worked.
dates $ProdKey  >/dev/null 2>/dev/null

date >>$LOGFILE 2>>$LOGFILE


exit 0
