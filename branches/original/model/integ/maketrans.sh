#
# maketrans.sh - make trans directory
# 
#    Usage  : maketrans.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: maketrans.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:50  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/17  14:25:43  scott
# COMMENT : Made modifications to make switches to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  23:15:41  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:48:23  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/10/29  04:41:16  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.3  1993/09/17  13:57:56  scott
# COMMENT : Added support for the integration and delivery of a Sparc Solaris platform
#
# Revision 240.2  1993/09/14  21:47:13  model20
# COMMENT : Now using grmakemake instead of makemake to define SUNOS to prevent SUNOS from getting Solaris compile options - JSD
#
# Revision 240.1  1993/03/03  17:52:28  model22
# COMMENT : baselining files from build team commando group
#
# Revision 220.4  1993/02/24  23:22:41  model22
# COMMENT : Calling grmake for MODEL/trans on Sgi to get COMPOPT ( G 0 ) - JSD
#
# Revision 220.3  1993/02/16  00:01:43  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  20:26:30  tim
# COMMENT : put in unit test code
#
# Revision 220.0  1993/02/13  23:08:08  tim
# COMMENT : changes to integration scripts to do unit testing
#

verifyenv SUNZX SUN5 SGI MODEL MDTARG 

TFILE=
   

necho "- - - - - - - Making trans directory - - - - - - - "
cd $MODEL/trans
grmakemake mdsp_proc.m $MDTARG/trans/makefile > /tmp/bldlog 2>&1
ncat /tmp/bldlog
cd $MDTARG/trans
if [ "${SGI}" = "y" ]
then
  grmake -rk -f makefile $TFILE > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ] 
  then
    grmake -rk -f makefile $TFILE > /tmp/bldlog 2>&1
    errchk /tmp/bldlog trans
  fi
else

# On the Sun we need the -PIC option set, that's why we are not using grmake
# The -PIC option is set in the makefile

  make -k -f makefile $TFILE > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ] 
  then
    make -k -f makefile $TFILE > /tmp/bldlog 2>&1
    errchk /tmp/bldlog trans
  fi
fi
