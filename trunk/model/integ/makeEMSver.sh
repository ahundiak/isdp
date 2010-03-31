#
# makeEMSver.sh - make the ems version.c file
# 
# Usage  : makeEMSver.sh APPLID RUN_NAME PRODUCT_NUMBER filename
# Inputs : $1 application id $2 run name $3 product number $4 version # filename
# Output : error messages
# Return : 0 - succeeds
#    Code  1 - fails  
#
#    Tim McKee  02/13/93
# $Log: makeEMSver.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.1  1997/07/10  14:03:01  scott
# COMMENT : Modified to conform to new integration configuration
#
# Revision 340.0  1997/05/28  16:07:30  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#

verifyenv VERSNO

if [ "$#" != "4" ]
 then
   errrpt $0 "incorrect number of arguments"
   exit 1
fi

APPLID=$1
RUNAME=$2
PRODNUM=$3
VERSFILE=$4

if [ -f $VERSFILE ] 
  then
  if [ ! -w $VERSFILE ] 
   then 
     errrpt $0 "$VERSFILE not writable"
     exit 1
  fi
fi

VERSNUM="03.04.00.$VERSNO"

echo "#include \"version.h\"" > $VERSFILE
echo "INGR_S_PRODUCT_DEF ${APPLID}_appl_version_id =" >> $VERSFILE
echo "                   {" >> $VERSFILE
echo "                      \"I/$RUNAME $VERSNUM\"," >> $VERSFILE
echo "                    0," >> $VERSFILE
echo "                      \"$PRODNUM\"," >> $VERSFILE
echo "                      \" $VERSNUM \"," >> $VERSFILE
echo "    		 };" >> $VERSFILE

