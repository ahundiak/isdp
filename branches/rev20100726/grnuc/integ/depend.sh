# Script to print the dates of subproducts used to build a version
#   Tim McKee  6/30/92
#
# $Log: depend.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:27  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:08  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1995/07/31  10:04:21  grnuc32
# COMMENT : Changed to reflect new name for RISDP
#
# Revision 320.0  1994/12/12  16:56:38  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1993/09/02  20:07:50  scott
# COMMENT : Fixed rcmd lines to read DATES from various machines
#
# Revision 240.4  1993/08/02   14:47:23 scott
# COMMENT : Removed machine strip from dates list
#
# Revision 240.3  1993/04/28  12:34:42  tim
# COMMENT : generate dates for the README file on sgi
#
# Revision 240.2  1993/03/29  14:03:33  grnuc20
# COMMENT : incorporating release 2.2.0 fix
#
# Revision 220.1  1993/03/15  23:09:02  grnuc20
# COMMENT : list RIS products in dependency list
#
# Revision 220.0  1993/02/19  21:54:09  model22
# COMMENT : Moved fro /usr2/ip32/integ to /integ
#
# Revision 201.3  1992/07/23  20:47:58  tim
# COMMENT : put sun component info in clipper README
#
#


for file in ACC CFL COMPILSUP ENVIRONV ENVIRON_S FONTSERVE FORMS GPIPE HELPRT HELPDP INC IP_ODI700 LIBXC RESOURCES RIS SCREENMGR SYSTEMV UNIXBOOT UMS XFORMSRT XFORMSDP
do
 dates $file
done

echo "===============================================================================" 
