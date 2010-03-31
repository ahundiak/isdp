#
# maketoolong.sh - make files with dependency list that are too long
# 
#    Usage  : maketoolong.sh  <file ...>
#    Inputs : filelist
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: maketoolong.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:49  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/17  14:25:49  scott
# COMMENT : Made modifications to make switches to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  23:15:40  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:48:22  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1994/10/29  04:41:25  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.0  1993/03/26  21:30:56  model22
# COMMENT : initial checkin
#
# Revision 220.2  1993/02/16  00:01:40  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  21:24:15  tim
# COMMENT : changes to unit testing
#
#


verifyenv MDTARG 


if [ "$#" = "0" ]
then
  errrpt $0 "not enough arguments"
  exit 1
fi

while [ $# -gt 0 ] 
do
  cd $MDTARG/`dirname $1`
  nrm `basename $1`
  grmake -rk -f makefile `basename $1`
  if [ "$ERRNOTI" = "on" ] 
  then
    grmake -rk -f makefile `basename $1`
  fi
  shift
done

