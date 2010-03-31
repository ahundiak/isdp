# makesldirs.sh - loop thru all directories in sliclist and make the .sl files
#
#
#    Usage  : makesldirs.sh
#    Inputs : none
#    Output : error messages
#    Return : 0 - succeeds
#      Code   1 - fails
#
#    Tim McKee  02/13/93
# $Log: makesldirs.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:45  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:15:37  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:48:18  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1994/10/29  04:41:23  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.1  1993/03/27  00:30:19  sunit
# COMMENT : touch .sl files to ensure they get compiled everytime
#
# Revision 220.3  1993/02/16  00:01:37  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  21:24:20  tim
# COMMENT : changes to unit testing
#
#

# verify environment variables
verifyenv MDTARG MODEL CLIPPER WORKDIR MASBLDLOG
if [ "$?" != "0" ]
then
   errrpt $0 "undefined environment variable"
   exit 1
fi

cd $WORKDIR
SLICLIST=$MODEL/integ/sliclist
if [ "$CLIPPER" = "y" ]
then
  necho "Touching ALL .sl files to ensure they get compiled"
  find $MODEL -type f -name '*.sl' -exec touch {} \;
fi

# make slic directories
for file in `cat $SLICLIST`
do
  cd $file
  necho "- - - - - - - $file - - - - - - - - - "
  pwd
  grmake -rk > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ]
  then 
    grmake -rk > /tmp/bldlog 2>&1
    errchk /tmp/bldlog $file
  fi
  cd $WORKDIR
  necho " "
done

