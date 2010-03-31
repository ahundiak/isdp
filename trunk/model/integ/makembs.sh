# makembs.sh - make .mb files
#
#
#    Usage  : makembs.sh
#    Inputs : none
#    Output : error messages
#    Return : 0 - succeeds
#      Code   1 - fails
#
#    Tim McKee  02/13/93
# $Log: makembs.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:39  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:15:31  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:48:12  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1994/10/29  04:41:22  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.2  1993/03/08  14:33:23  model22
# COMMENT : incorporating release 2.2.0 fix
#
# Revision 220.3  1993/02/16  00:01:33  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  20:26:22  tim
# COMMENT : put in unit test code
#
# Revision 220.0  1993/02/13  23:07:57  tim
# COMMENT : changes to integration scripts to do unit testing
#
#

# verify environment variables
verifyenv MDTARG MODEL CLIPPER 
if [ "$?" != "0" ]
then
   errrpt $0 "undefined environment variable"
   exit 1
fi

# make messages/src directories
cd $MODEL/config/english/messages/src
grmake -rk $MSGFILE > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
then
  grmake -rk $MSGFILE > /tmp/bldlog 2>&1
  errchk /tmp/bldlog config/english/messages/src
fi

if [ "$SGI" != "y" ]
then
  cd $MODEL/src_nm/config/english/messages/src
  grmake -rk > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ]
  then
    grmake -rk > /tmp/bldlog 2>&1
    errchk /tmp/bldlog src_nm/config/english/messages/src
  fi
fi

