# grmkcob.sh - Slic's all .sl and .t files in $GRNUC
#              NOTE : This is CLIPPER specific.
#              NOTE : Must be done BEFORE starting builds on other machines.
#
#
#    Usage       : grmkcob.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkcob.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:46  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/15  19:44:22  scott
# COMMENT : Changed make configuration to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  20:22:27  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:53  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1993/05/05  19:56:24  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

# verifyenv GRNUC CLIPPER TBLDLOG MASBLDLOG
# if [ $? -ne 0 ]
# then
#   errrpt $0 "Some environment variables are NOT defined....Exiting..."
#   exit 1
# fi

# if [ "$CLIPPER" = "y" ]
# then

  cd $GRNUC
  if [ "$UNIT_TEST" = "on" ]
  then
    SLIC_FILE_LIST="src/co/partco/make.sl"
    mkdir -p /usr/tmp/config/commands
    mkdir -p /usr/tmp/src/co/partco
    export SVGRTARG=$GRTARG
    export SVSOURCE=$SOURCE
    export GRTARG=/usr/tmp
    export SOURCE=/usr/tmp
    cp $GRNUC/src/co/partco/*.*[lt] $GRTARG/src/co/partco
    cd $GRTARG
  else
    SLIC_FILE_LIST=`find src -name 'make.sl' -print`
  fi

  for m in $SLIC_FILE_LIST
  do
    d=`dirname $m`
    necho "\n------------------$UNIT_MESS slicing $d ---------------------\n"
    cd $d
    make WHY=$WHY -rk -f make.sl > /tmp/$TBLDLOG 2>&1
    ncat /tmp/$TBLDLOG 
    cd $GRNUC
  done
# else
#   necho "\nOnly the CLIPPER slic's .sl and .t files"
# fi

if [ "$UNIT_TEST" = "on" ]
then
  ls -ong $GRTARG/`dirname $SLIC_FILE_LIST`/* >> /usr2/tmp/$MASBLDLOG
  ls -ong $GRTARG/config/commands/* >> /usr2/tmp/$MASBLDLOG
  rm -r /usr/tmp/src
  rm -r /usr/tmp/config
  export GRTARG=$SVGRTARG
  export SOURCE=$SVSOURCE
fi
