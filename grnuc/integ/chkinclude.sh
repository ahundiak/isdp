#
# chkinclude.sh - checks include directories for duplicate include files
# 
#    Usage  : chkinclude
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: chkinclude.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:21  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:02  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:32  root
# *** empty log message ***
#
# Revision 240.0  1993/03/04  14:22:05  grnuc20
# COMMENT : baselining fixes made by the build commandos
#
# Revision 220.0  1993/02/14  15:20:03  tim
# COMMENT : report newfiles fetched/establish file to note the ownership of files in WORKDIR
#
#

verifyenv WORKDIR EXNUC MODEL GRNUC PROD SUN

cd $WORKDIR/include
\ls -t > /tmp/inc$$
for file in `cat /tmp/inc$$`
do
  IDIRLIST="/usr/include $BS/include $EXNUC/include"
  if [ "$SUN" = "y" ]
   then 
    IDIRLIST="$IDIRLIST /usr/5include"
  fi
  if [ "$PROD" = "MODEL" ]
   then
     IDIRLIST="$IDIRLIST $GRNUC/include"
  fi
  for IDIR in $IDIRLIST
   do
     ls -l $IDIR/$file 1> /tmp/inc.out$$ 2>/dev/null
     if [ -s /tmp/inc.out$$ ]
      then
        echo "$file is also in $IDIR"
     fi
  done
done
rm /tmp/inc$$

cd $WORKDIR/spec
\ls -t > /tmp/spec$$
SDIRLIST="$EXNUC/spec"
if [ "$PROD" = "MODEL" ]
 then 
   SDIRLIST="$SDIRLIST $GRNUC/spec"
fi
for file in `cat /tmp/spec$$`
do
  for SDIR in $SDIRLIST
   do
    ls -al $SDIR/$file 1> /tmp/spec.out$$ 2>/dev/null
     if [ -s /tmp/spec.out$$ ]
      then
        echo "$file is also in $SDIR"
     fi
  done
done
rm /tmp/spec$$
