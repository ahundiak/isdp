# grmkarch.sh - Makes the archives for $GRTARG (libGRcoar.a and libGRgrar.a)
#               NOTE: Currently, Unit testing only looks for existance of the
#                     appropriate makefiles and whether the final archive 
#                     directory exists and is writable
#
#    Usage       : grmkarch.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkarch.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:45  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/15  19:44:21  scott
# COMMENT : Changed make configuration to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  20:22:26  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:52  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/10/16  21:53:19  grnuc20
# COMMENT : Support of C100/C400 simultaneous newprod for Grnuc archives - JSD
#
# Revision 240.2  1993/05/05  19:56:21  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#

# verify that all environment variables used in this script are defined.

# verifyenv GRNUC GRTARG TBLDLOG MASBLDLOG ERRNOTI
# if [ $? -ne 0 ]
# then
#   errrpt $0 "Some environment variables are NOT defined...Exiting..."
#   exit 1
# fi

necho "\n----------------$UNIT_MESS src/archlib -------------------\n"
if [ "$UNIT_TEST" = "on" ]
then
  nls $GRTARG/src/archlib/cosrc/Makefile >> /usr2/tmp/$MASBLDLOG
  nls $GRTARG/src/archlib/grsrc/Makefile >> /usr2/tmp/$MASBLDLOG
  if [ -f $GRTARG/src/archlib/cosrc/Makefile ]
  then
    necho "$GRTARG/src/archlib/cosrc/Makefile is ready"
  else
    errrpt $0 "$GRTARG/src/archlib/cosrc/Makefile not found" >> /usr2/tmp/$MASBLDLOG
  fi
  if [ -f $GRTARG/src/archlib/grsrc/Makefile ]
  then
    necho "$GRTARG/src/archlib/grsrc/Makefile is ready"
  else
    errrpt $0 "$GRTARG/src/archlib/grsrc/Makefile not found" >> /usr2/tmp/$MASBLDLOG
  fi
  touch $GRTARG/lib/unittest
  if [ -f $GRTARG/lib/unittest ]
  then
    rm $GRTARG/lib/unittest
    necho "$GRTARG/lib is writable"
  else
    errrpt $0 "$GRTARG/lib is not writable" >> /usr2/tmp/$MASBLDLOG
  fi
else
  if [ -f $GRTARG/lib/*.[ao] ]
  then
    echo "\nMoving libraries from $GRTARG/lib to $GRTARG/lib/$CPUTYPE\n"
    mv $GRTARG/lib/*.[ao] $GRTARG/lib/$CPUTYPE
  fi
  cd $GRTARG/src/archlib/cosrc
  necho "\n------------------ src/archlib/cosrc ---------------------\n"
  cp $GRNUC/src/archlib/cosrc/Makefile .
  make WHY=$WHY -rk > /tmp/$TBLDLOG 2>&1
  ncat /tmp/$TBLDLOG 
  if [ "$ERRNOTI" = "on" ]
  then
    make WHY=$WHY -rk > /tmp/$TBLDLOG 2>&1
    errchk /tmp/$TBLDLOG src/archlib/cosrc
  fi

  cd $GRTARG/src/archlib/grsrc
  necho "\n------------------ src/archlib/grsrc ---------------------\n"
  cp $GRNUC/src/archlib/grsrc/Makefile .
  make WHY=$WHY -rk -f Makefile > /tmp/$TBLDLOG 2>&1
  ncat /tmp/$TBLDLOG 
  if [ "$ERRNOTI" = "on" ]
  then
    make WHY=$WHY -rk -f Makefile > /tmp/$TBLDLOG 2>&1
    errchk /tmp/$TBLDLOG src/archlib/grsrc
  fi
fi
