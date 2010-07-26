#$Log: make.sh,v $
#Revision 1.2  2002/02/05 20:00:55  hans
#*** empty log message ***
#
#Revision 1.1.1.1  2001/12/17 22:39:12  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  23:15:59  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/15  21:26:44  scott
# COMMENT : Modified to workaround Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  21:30:15  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:59:12  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.0  1992/12/06  23:52:55  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.3  1992/11/13  20:44:32  grnuc20
# COMMENT : fixes for fontbuilder to work on the single source platform
#
# Revision 220.2  1992/11/04  20:25:51  grnuc20
# COMMENT : fixes for single source platform implementation
#
# Revision 220.1  1992/09/24  21:12:36  grnuc20
# COMMENT : SGI Build fixes
#
# Revision 220.0  1992/08/29  06:30:57  root
# COMMENT : Corresponds to Rel201.10 in 2.0.1 RCS
#
# Revision 201.10  1992/07/13  20:42:47  tim
# COMMENT : added Log variable
#

echo "";
rm $GRTARG/src/fontbuilder/bin/GRflibconv $GRTARG/src/fontbuilder/bin/GRChFn
for name in *_src
do
  if [ "$name" != "EX_src" -a "$name" != "CF_src" ]
  then
    (
      cd $name
      echo "\n--------------- Make $name ---------------\n"
      make -rk -f $GRNUC/src/makefile
    )
  fi
done

echo "\n--------------- make EX_src ---------------"
(
  cd ${GRTARG}/src/fontbuilder/fconv/EX_src;
  grmake -rk -f makeimp
  echo ""
)

echo "\n--------------- make CF_src ---------------"
(
  cd ${GRTARG}/src/fontbuilder/fconv/CF_src
  grmake -rk -f makeimp
  echo ""
)

