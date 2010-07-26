#
# chkpackreg.sh - check for packaging regression
# 
#    Usage  : chkpackreg.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
#    Tim McKee  02/18/93
#
# $Log: chkpackreg.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.1  1997/11/11  09:48:04  bharikri
# COMMENT : Removed the log file, as the same file is used to log for both GRNUC and MODEL and each not able to over-write the other resulting in an error on stdout.
#
# Revision 340.0  1997/05/27  22:06:22  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:03  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:33  root
# *** empty log message ***
#
# Revision 240.1  1993/12/23  16:29:38  grnuc20
# COMMENT : Move thispackage to lastpackage so the next package can diff this package - JSD
#
# Revision 240.0  1993/03/04  14:22:07  grnuc20
# COMMENT : baselining fixes made by the build commandos
#
# Revision 220.0  1993/02/21  15:44:30  grnuc20
# COMMENT : changes to verify packaging
#
 
package.sh -r $PACKFILE > thispackage 2>triedtopackage

if [ ! -s lastpackage ]
 then
   errrpt $0 "lastpackage file not found"
   echo "\n These files where in package.def but could not be packaged"
   echo "-----------------------------------------------------------"
   cat triedtopackage
else
   echo "\n Differences between this package and last package"
   echo "--------------------------------------------------"
   diff lastpackage thispackage  > /usr2/tmp/diffs
   if [ -s /usr2/tmp/diffs ]
    then
     cat /usr2/tmp/diffs
     errchk /usr2/tmp/diffs "Differences between this package and last package"
   fi
   echo "\n\n\n"
   echo "\n These files where in package.def but could not be packaged"
   echo "-----------------------------------------------------------"
   cat triedtopackage
fi
rm triedtopackage
mv thispackage lastpackage
rm /usr2/tmp/diffs
