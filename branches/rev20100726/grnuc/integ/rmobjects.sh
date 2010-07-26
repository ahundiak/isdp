# rmobjects.sh - Removes all object (binary) files in the product
#
#    Usage       : rmobjects.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: rmobjects.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:39  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/10/09  15:44:18  grnuc33
# COMMENT : Removed UNIT_TEST stuff
#
# Revision 330.0  1996/01/11  20:23:17  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:44  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:44:46  tim
# COMMENT : corrected Log keyword for RCS history
#


#verify that all environment variables used in this script are defined

verifyenv TARGETDIR PROD LOGFILE

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined"
  exit 1
fi


echo Removing the object files:
echo Removing the object files: >> $LOGFILE

if [ "${PROD}" = "GRNUC" ]
  then
    # "nrm" verifies the remove
    ${timex} find ${TARGETDIR}/src -name '*.[oe]' -print > /tmp/obj.$$
    for file in `cat /tmp/obj.$$`
     do 
       nrm -q $file
    done
    rm /tmp/obj.$$
  else
    if [ "${PROD}" = "MODEL" ]
    then
      # "nrm" verifies the remove
      ${timex} find ${TARGETDIR}/src_* -name '*.[oe]' -print > /tmp/obj.$$
      ${timex} find ${TARGETDIR}/ve -name '*.[oe]' -print >> /tmp/obj.$$
      ${timex} find ${TARGETDIR}/hsurf -name '*.[oe]' -print >> /tmp/obj.$$
      ${timex} find ${TARGETDIR}/hplot -name '*.[oe]' -print >> /tmp/obj.$$
      for file in `cat /tmp/obj.$$`
      do 
        nrm -q $file
      done
      rm /tmp/obj.$$
    fi
fi
