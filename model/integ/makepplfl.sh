#
# makepplfl.sh - make the ppl/cisrc directory and other ppl directories
#		 if a new directory is to be compiled - add it to PPLDIRLIST 
#
#    Usage  : makepplfl.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: makepplfl.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:41  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/17  14:25:48  scott
# COMMENT : Made modifications to make switches to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  23:15:32  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/06/26  06:46:47  model32
# COMMENT : Made changes to integrate revise assembly
#
# Revision 240.1  1993/03/03  17:52:14  model22
# COMMENT : baselining files from build team commando group
#
# Revision 220.3  1993/02/16  00:01:35  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  20:26:25  tim
# COMMENT : put in unit test code
#
# Revision 220.0  1993/02/13  23:07:59  tim
# COMMENT : changes to integration scripts to do unit testing
#
#

verifyenv MDTARG MODEL COMPILER COMPOPT 
if [ "$?" != "0" ]
 then
   errrpt $0 "undefined environment variable"
fi

PPLDIRLIST="ppl/cisrc src_assem/ppl"

for file in $PPLDIRLIST
do
  cd $MDTARG/$file
  necho "Making ppl files .... $file ..."

  if [ "$UNIT_TEST" = "on" ]
   then
     echo "\n\nTesting $0"
     PPLFILE=`grep \^PPL $MODEL/integ/atp/testlist | cut -d' ' -f2`
     mv $PPLFILE old.$PPLFILE
  else
     PPLFILE=
  fi

  make -rk -f $MODEL/$file/Makefile $PPLFILE CC="$COMPILER" COPT="$COMPOPT" > /tmp/bldlog 2>&1
  ncat /tmp/bldlog
  if [ "$ERRNOTI" = "on" ]
   then
    make -rk -f $MODEL/$file/Makefile $PPLFILE CC="$COMPILER" COPT="$COMPOPT" > /tmp/bldlog 2>&1
    errchk /tmp/bldlog ppl/cisrc
  fi
done

if [ "$UNIT_TEST" = "on" ]
 then
   mv old.$PPLFILE $PPLFILE
fi
