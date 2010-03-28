# grvertarg.sh - This script makes a snapshot of TARGETDIR after a build and
#                compares it to the snapshot of TARGETDIR before the build was
#                started.
#                NOTE : This is ENABLE_RECOMPILE=on specific.
#
#
#    Usage       : grvertarg.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#    History :
#
#    Jan 07 1995 - sam : Added checks to see if image and .so are created.
#                        Also *.cmp files are checked.
#
#$Log: grvertarg.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.1  1997/05/29  15:42:31  scott
# COMMENT : Version upgrade for 3.4
#
# Revision 340.0  1997/05/27  22:07:07  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#


# verify that all environment variables used in this script are defined.

verifyenv TARGETDIR LOGNAME CPUTYPE PROD
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

# Get a snapshot of TARGETDIR after finishing the total recompile

find $TARGETDIR -print > /usr2/tmp/$LOGNAME.aft

# Compare the before and after the build snapshots

ls -slt /usr2/tmp/$LOGNAME.bef /usr2/tmp/$LOGNAME.aft

sort /usr2/tmp/$LOGNAME.bef > /usr2/tmp/$LOGNAME.bef.s
sort /usr2/tmp/$LOGNAME.aft > /usr2/tmp/$LOGNAME.aft.s

diff /usr2/tmp/$LOGNAME.bef.s /usr2/tmp/$LOGNAME.aft.s > /usr2/tmp/$LOGNAME.diff.s

echo "Before the build" > /usr2/tmp/$LOGNAME.sorted
echo "================" >> /usr2/tmp/$LOGNAME.sorted
awk '$1 ~ /^</' /usr2/tmp/$LOGNAME.diff.s >> /usr2/tmp/$LOGNAME.sorted

echo "\nAfter the build" >> /usr2/tmp/$LOGNAME.sorted
echo "===============" >> /usr2/tmp/$LOGNAME.sorted
awk '$1 ~ /^>/' /usr2/tmp/$LOGNAME.diff.s >> /usr2/tmp/$LOGNAME.sorted

echo "\nThe differences in builds can be seen in /usr2/tmp/$LOGNAME.sorted\n"

echo "==================================================================="
cat /usr2/tmp/$LOGNAME.sorted
echo "==================================================================="

if [ "$PROD" = "GRNUC" ]
then

#    List the executable

  if [ -f $GRTARG/bin/Grnuc ]
  then
    ls -ls $GRTARG/bin/Grnuc
  else
    echo " Grnuc executable is not linked up!!\n"
  fi

#    On Sgi platform check if grnuc.so is generated

  if [ "$CPUTYPE" = "sgi" ]
  then
    if [ -f $GRTARG/shlib/grnuc.so ]
      then
        ls -ls $GRTARG/shlib/grnuc.so
      else
        echo "grnuc.so is not created!! Run $GRNUC/shlib/grnuc.dso.\n"
    fi
  fi

#    Check the *.cmp files 

  cd $GRTARG
  echo "==================================================================="
  find . -name \*.cmp -print | xargs ls -ls
  echo "===================================================================\n"
  cd -
  if [ "$CLIPPER" != "y" ]
  then
    CMP=n
    echo "Do you want to copy *.cmp files from c100 system? [n]\c"
    read CMP; : "${CMP}" = "n"
    if [ "$CMP" = "y" ]
    then
      cd $GRNUC/../grnuc34
      echo "==================================================================="
      find . -name \*.cmp -print | cpio -pmduv $GRTARG
      echo "===================================================================\n"
      cd -
    fi
  fi
fi
#
#  Model 
#

if [ "$PROD" = "MODEL" ]
then

#
#    List the executable
#

  if [ -f $MDTARG/bin/Model ]
  then
    ls -ls $MDTARG/bin
  else
    echo " Model executable is not linked up!!\n"
  fi
#
#    On Sgi platform check if *.so's is generated
#
  if [ "$CPUTYPE" = "sgi" ]
  then
    if [ -f $MDTARG/src_shlib/model.so ]
      then
        ls -ls $MDTARG/src_shlib
      else
        echo "model.so is not created!! Run makedso.sh\n"
    fi
  fi
#
#    Check the *.cmp files 
#
  cd $MDTARG
  echo "===================================================================\n"
  find . -name \*.cmp -print | xargs ls -ls
  echo "===================================================================\n"
  cd -
  if [ "$CLIPPER" != "y" ]
  then
    CMP=n
    echo "Do you want to copy *.cmp files from c100 system? [n]\c"
    read CMP; : "${CMP}" = "n"
    if [ "$CMP" = "y" ]
    then
      cd $MODEL/../model34
      echo "===================================================================\n"
      find . -name \*.cmp -print | cpio -pmduv $MDTARG
      echo "===================================================================\n"
      cd -
    fi
  fi

  if [ "$CLIPPER" != "y" -a "$CMP" = "y" ]
  then
    if [ -f $MDTARG/src_nm/config/NMcmd.cmp ]
    then
      rm -f $MDTARG/src_nm/config/NMcmd.cmp
    fi
    if [ -f $MDTARG/src_nm/config/NMcmddbg.cmp ]
    then
      rm -f $MDTARG/src_nm/config/NMcmddbg.cmp
    fi
  fi
fi

