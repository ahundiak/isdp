# help.sh - Print outs help messages. Each input string will be displayed on a
#           new line. 
#
#
#    Usage       : help.sh "<string1>" "<string2>" "<string3>" ........
#    Inputs      : Strings to be displayed
#    Output      : Strings printed to screen in help format.
#    Return code : none 
#
#$Log: help.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:08  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:47  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:13  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:56:00  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


echo;
echo '***********************************  HELP  *************************************';echo;
while [ $# -gt 0 ]
do
echo $1; shift;
done
echo;
echo '***********************************  HELP  *************************************';echo;
echo;
