#
# makeris.sh - make the ris.a file
# 
#    Usage  : makeris.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/13/93
# $Log: makeris.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:48  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  17:02:31  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/12  00:06:18  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/07/28  11:17:12  model32
# COMMENT : changed the path to risdp
#
# Revision 320.0  1994/12/12  23:44:58  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.11  1994/09/23  11:34:23  model40
# COMMENT : modelconf.sgi shd link to src; ris stubs for SSL ISL - samuel
#
# Revision 240.9  1993/10/06  16:27:50  model20
# COMMENT : Support for C100/C400 simultaneous newprod for MODEL - JSD
#
# Revision 240.8  1993/03/08  19:22:49  model22
# COMMENT : incorporating release 2.2.0 fixes
#
# Revision 220.10  1993/03/01  19:34:51  model22
# COMMENT : fixed ris build problem on sun and packaging problem
#
# Revision 220.9  1993/02/15  17:47:18  model22
# COMMENT : fixes for unit testing
#
# Revision 220.8  1993/02/14  20:26:37  tim
# COMMENT : put in unit test code
#
#

verifyenv CLIPPER SGI MDTARG MODEL SUN5 ISL SUNZX

if [ "$UNIT_TEST" = "on" ]
 then
   echo "no unit test for makeris.sh"
   exit 0
fi

if [ "$CLIPPER" = "y" ]
then
  echo "Copy ris.a from ris area"
  ncp /usr/ip32/ris/risdp/lib/c100/ris.a $MDTARG/src_lib/ris/ris.a
else
  if [ "$C400" = "y" ]
   then
     echo "Copy ris.a from ris area"
     ncp /usr/ip32/ris/risdp/lib/c400/ris.a $MDTARG/src_lib/ris/ris.a
  else
    if [ "$SGI" = "y" ] || [ "$SUN5" = "y" ] || [ "$ISL" = "y" ] || [ "$SUNZX" = "y" ]
    then
      echo "Making dummy file for ris.o (non-clix platforms)"
      ${COMPILER} ${COMOPT} -c ${MODEL}/src_lib/ris/ris_stub.c
      ld -r -o $MDTARG/src_lib/ris.o ris_stub.o
      ls -l $MDTARG/src_lib/ris.o
      nrm ris_stub.o
      exit 
    else
      echo "Copy ris.a from ris area"
      ncp /usr/ip32/ris/rispsuc/lib/ris.a $MDTARG/src_lib/ris/ris.a
    fi
  fi
fi

if [ ! -d $MDTARG/src_lib/ris/ristmp ]
then
  mkdir -p $MDTARG/src_lib/ris/ristmp
fi
cd $MDTARG/src_lib/ris/ristmp
pwd

echo "Extracting all objects from ris.a"
ar -xv $MDTARG/src_lib/ris/ris.a

echo "Removing comc2pw.o from list"
rm $MDTARG/src_lib/ris/ristmp/comc2pw.o

echo "Building ris.o from all extracted files"
ld -r -o $MDTARG/src_lib/ris.o *.o
rm *.o

cd $MDTARG
ls -l $MDTARG/src_lib/ris.o
pwd
