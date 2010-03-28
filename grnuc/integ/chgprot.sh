#
# chgprot.sh - change protections to root or self
# 
#    Usage  : chgprot.sh directory [ -toroot | -toself ]
#    Inputs : $1=directory $2 username switch
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: chgprot.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.1  1997/07/25  20:16:03  scott
# COMMENT : Changed syntax for conform with new permissions scheme
#
# Revision 340.0  1997/05/27  22:06:19  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

verifyenv WORKDIR


  echo 'Changing ownership and protection '`echo $2 | sed 's/to/to /'`
  USAGE="chgprot.sh directory [ -toroot | -toself ]\n"

  if [ -d "$1" ] 
  then
  
     cd $1
  
     case $2 in
  
        -toroot)
              echo > ${1}/PROTECTED
              rootsetuid find . -exec chown sys {} \;
              rootsetuid find . -exec chgrp bin {} \;
              echo "$1 's ownership has been changed to root"
              ;;
        -toself)
              rootsetuid find . -exec chown $LOGNAME {} \;
              rootsetuid find . -exec chgrp 500 {} \;
              echo "$1 's ownership have been changed to $LOGNAME"
              nrm ${1}/PROTECTED
              ;;
        *)
              echo $USAGE
              exit
              ;;
     esac

  else
     echo $USAGE
  fi
