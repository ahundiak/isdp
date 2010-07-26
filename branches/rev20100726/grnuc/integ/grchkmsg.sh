#
# errchk - check for compile errors
# 
#    Usage  : errchk logfile [directory_name]
#    Inputs : $1=logfile $2=directory_name
#    Output : error messages/mail
#    Return : none
#      Code   
#
#    Tim McKee  06/27/93
# $Log: grchkmsg.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:39  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:20  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:47  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/08/24  14:43:44  grnuc20
# COMMENT : look for duplicates in *msg.mb and *message.mb files
#
# Revision 240.0  1993/06/29  15:22:27  grnuc20
# COMMENT : check for duplicate messages in build process
#

verifyenv GRNUC GRTARG MASBLDLOG SOURCEDIR 

if [ "$CLIPPER" = "y" ]
 then
  necho ".....Checking for Duplicate messages"
  cd ${SOURCEDIR}/config/english/messages/src
  ${GRTARG}/bin/find_msg -d ${GRNUC}/src/util/find_msg/duplicates *msg.mb *message.mb > /tmp/bldlog.$$
  if [ -s /tmp/bldlog.$$ ]
   then
    cat /tmp/bldlog.$$
    cat /tmp/bldlog.$$ >> /usr2/tmp/$MASBLDLOG
    errchk /tmp/bldlog.$$ "Duplicate messages"
  else
    necho "          No duplicate messages"
  fi
fi
