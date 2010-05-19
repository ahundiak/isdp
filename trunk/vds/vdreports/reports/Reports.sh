# $Id: Reports.sh,v 1.1.1.1 2001/01/04 21:09:07 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdreports/reports/Reports.sh 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: Reports.sh,v $
#	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
#	Initial import to CVS
#	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

#
#
#    This script is invoked to compile all the reports 
#    with a new DATABASE name.
#

tput clear

unalias ls
unalias rm

export olddb=nfm
echo "\n\n\n\n\n"
echo "\t All the reports executables are compiled with "
echo "\t the database name of NFM. If you wish to compile"
echo "\t the reports with new database name please specify"
echo "\t the new name at the prompt after selecting the "
echo "\t default database as NFM for the old database." 
echo "\t If you already have compiled the reports earlier"
echo "\t with another database name, please specify that"
echo "\t as the old database name."


ls fgl/*.4gl > tmp
ls lib/*.4gl >> tmp
ls per/*.per >> tmp


echo "\n\n\n\n\n\n\tGIVE THE OLD DATABASE NAME [$olddb] : \c"
read olddbname
if [ -z "$olddbname" ]; then
   olddbname=$olddb
fi

echo "\n\n\tGIVE THE NEW DATABASE NAME[$olddb] : \c"
read newdbname
if [ -z "$newdbname" ]; then
   newdbname=$olddb
fi

echo "\n\n"
if [ "$olddbname" = "$newdbname" ]; then
   echo "\tOld database name[$olddbname] same as New database name[$newdbname]"
echo "\n\n\n\n\n"
   exit 1
fi

echo "\n\n"

list=`cat tmp`

for args in $list
do
echo $args
ed $args <<%
g/$olddbname$/s//$newdbname/g
w
%
done
rm tmp

make
