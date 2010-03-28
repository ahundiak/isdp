#
# grtouchmbs.sh - touch all .mb files to force regeneration of .msg and .h
# 
#    Usage  : grtouchmbs.sh
#    Inputs : 
#    Output : error messages
#    Return : none
#      Code   
#
#    Jimmy Dodd  03/29/93
# $Log: grtouchmbs.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:06  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:45  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:11  root
# *** empty log message ***
#
# Revision 240.0  1993/03/29  19:12:41  grnuc20
# COMMENT : Fix for touching .sl and .mb files on total recompile to force regeneration of .msg and .h files and command files - JSD
#
#
#

verifyenv SOURCEDIR
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

necho "Touching .mb files"

cd $SOURCEDIR
find $SOURCEDIR -name "*.mb" -print | xargs touch
