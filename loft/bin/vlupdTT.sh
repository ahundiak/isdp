# $Id: vlupdTT.sh,v 1.1.1.1 2001/01/04 21:11:03 cvs Exp $
#!/bin/ksh
#***********************************************************************
# I/LOFT
#
# File:         bin/vlupdTT.sh
#
# Description:
#	Shell script to update TranstTable of STRUCT with the TransTable
#	of LOFT.
#	This script saves transtable of struct to TTable.struct and then
#	appends the entries of loft's transtable to struct's transtable.
#
#       sample invocation:      updTTable.sh
#
#	Note :  This script must be executed in superuser mode.
#
# Dependencies:
#
# Revision History
#       $Log: vlupdTT.sh,v $
#       Revision 1.1.1.1  2001/01/04 21:11:03  cvs
#       Initial import to CVS
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.1  1996/05/29  11:27:44  pinnacle
# Created: bin/vlupdTT.sh by msbraju for loft
#
#

#
# Check if we are in the super-user mode.
#
uid=`id|awk '{print $1'}`
if [ "$uid" != "uid=0(root)" ] ; then
        echo "\n\tSorry: must be super-user to execute $0"
        exit 0 ;
fi


# I/STRUCT transition table enhanced with I/LOFT elements
  Ttable="/config/TransTable"
  Mtable="/config/TTable.loft"
  Stable="/config/TTable.struct"

  LOFT_path=`echopath LOFT ${INGRHOME}/product_data $0`

  if STRUCT_path=`echopath STRUCT ${INGRHOME}/product_data $0` ; then
     if [ -f $STRUCT_path$Ttable ]; then
       if [ ! -f $STRUCT_path$Stable ]; then
         cp $STRUCT_path$Ttable $STRUCT_path$Stable
       fi
       chmod +w $STRUCT_path$Ttable
       cp $STRUCT_path$Stable $STRUCT_path$Ttable
       cat ${LOFT_path}$Mtable >> $STRUCT_path$Ttable
       if [ $? = 0 ] ; then
	 echo "I_STRUCT's Transition Table is updated with LOFT's entries"
       else
	 echo "Error updating I_STRUCT's Transition Table"
       fi
       chmod -w $STRUCT_path$Ttable
     else
      cp ${LOFT_path}$Mtable ${UNIXDIR}$Ttable
      if [ $? = 0 ] ; then
	echo "I/LOFT's Transition Table is copied to $STRUCT/config"
      else
	echo "Error copying I/LOFT's Transition Table to $STRUCT/config"
      fi
     fi
  else
     echo "\nCannot update I/STRUCT transition table"
  fi
