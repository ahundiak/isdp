# grcpspl.sh - Copies Intergraph extension header files to $GRNUC
#
#    Usage       : gringrsys.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: gringrsys.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:44  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:24  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:51  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/01/28  05:47:35  dodd
# COMMENT : Copy tools.h from /usr/include to /ingrsys ONLY ON CLIPPER C100 - JSD
#
# Revision 240.0  1993/06/11  20:49:26  grnuc20
# COMMENT : added INGRHOME/include to the include path
#
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC CLIPPER MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

if [ "$CLIPPER" = "y" ]
then
  necho "\n------ copying Intergraph include files to $GRNUC/ingrsys -------\n"
  ncp /usr/include/tools.h $GRNUC/ingrsys/tools.h >> /usr2/tmp/$MASBLDLOG
  echo "\nTouching the date of $GRNUC/ingrsys/tools.h to 01/01/01 1970\n"
  touch 0101010101 $GRNUC/ingrsys/tools.h
fi

