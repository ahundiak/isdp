# grmkdict.sh - Make the dictionary files.
#               NOTE : This is SUN and SGI specific.
#               NOTE : This script uses a couple of other scripts to help
#                      in the process of building the dictionary.  Also, the
#                      makefile is generated in this script, not in mkmkfiles.sh
#
#
#    Usage       : grmkdict.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkdict.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:47  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:28  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:54  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1994/08/09  13:14:15  grnuc40
# COMMENT : upgrade for v3.1
#
# Revision 240.2  1993/05/05  19:56:23  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC GRTARG SUN SGI TBLDLOG MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

if [ "$SUN" = "y" ] || [ "$SGI" = "y" ]
then
  if [ "$UNIT_TEST" = "on" ]
  then
    FIND_LIST="GRgr*.S"
    export SVGRTARG=$GRTARG
    export GRTARG=/usr/tmp
    mkdir $GRTARG/config $GRTARG/dict
    ncp $GRNUC/dict/mkmkdict.sh $GRTARG/dict/mkmkdict.sh >> /usr2/tmp/$MASBLDLOG 2>&1
  else
    FIND_LIST="*.S"
    nrm $GRTARG/config/class_defns
  fi

  necho "\n------------------$UNIT_MESS dict ---------------------\n"
  cd $GRNUC/spec
  find $FIND_LIST -print | cpio -pml $GRTARG/dict >> /tmp/$TBLDLOG 2>&1
  ncat /tmp/$TBLDLOG

  cd $GRNUC/dict
  if [ ! -f `\ls *.T` ]
  then
    errrpt $0 "Can not find $GRNUC/dict/*.T"
  fi
  for file in `\ls *.T`
  do
    ncp $file $GRTARG/dict >> /usr2/tmp/$MASBLDLOG
  done

  cd $GRTARG/dict
  for file in `ls CO*`
  do
    nrm $file
  done
  if [ -s $GRNUC/dict/REMLIST ]
  then
    for file in `cat $GRNUC/dict/REMLIST`
    do
      nrm $file
    done
  fi
  mkmkdict.sh > /tmp/$TBLDLOG 2>&1
  makemake ${MKMKOPT} grdict.m $GRTARG/dict/makefile >> /tmp/$TBLDLOG 2>&1
  make >> /tmp/$TBLDLOG 2>&1
  ncat /tmp/$TBLDLOG 

  if [ "$UNIT_TEST" = "on" ]
  then
    ls -slt /usr/tmp/config /usr/tmp/dict >> /usr2/tmp/$MASBLDLOG
    rm -r /usr/tmp/config /usr/tmp/dict
    export GRTARG=$SVGRTARG
  fi
else
  necho "\nLittle Endian Boxes do not have a dictionary"
fi
