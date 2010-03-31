#
# checkspec_all.sh - check spec.m's and update them if needed
# 
#    Usage  : checkspec_all.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: checkspec_all.sh,v $
# Revision 1.1  2002/01/11 20:43:14  hans
# *** empty log message ***
#
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:06:57  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:14:51  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:47:28  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/10/29  04:41:21  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.0  1993/03/26  21:26:33  model22
# COMMENT : initial checkin
#
# Revision 220.6  1993/02/16  00:01:18  model22
# COMMENT : fixes for unit testing
#
# Revision 220.4  1993/02/14  20:26:23  tim
# COMMENT : put in unit test code
#
# Revision 220.3  1993/02/13  23:07:42  tim
# COMMENT : changes to integration scripts to do unit testing
#
#

verifyenv WORKDIR SOURCEDIR

MAKELIST=$WORKDIR/integ/makelist

cd $WORKDIR
necho "- - - - - - - Running checkspec_all- - - - - - - - - "
for file in `cat $MAKELIST` src_stub
do
  cd $file
  echo "$file -- \c" > /tmp/bldlog 2>&1
  checkspec.sh >> /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  cd $WORKDIR
done
rm -f $WORKDIR/newdelfiles

