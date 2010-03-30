# checkvars.sh - Check the $HOME/integ/integ.env file in the current integrator
#                login and verify that ALL the variables in there have been
#                exported with a NON-NULL value.
#
#
#    Usage       : checkvars.sh
#    Inputs      : none
#    Output      : none
#    Return code : 0  - success
#                  1  - failure

#$Log: checkvars.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:17  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:21:58  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:28  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:44:37  tim
# COMMENT : corrected Log keyword for RCS history
#

# check to see that all the environment variables used in this file are 
# actually defined.

verifyenv HOME 

if [ $? -ne 0 ]
then
  errrpt $0 "Environment variable HOME is not defined"
  exit 1
fi

# get all variables from $HOME/integ/integ.env and make sure that all of them 
# are defined. If ANY one of them is not defined, exit with error. Consequently,
# there should be NO exported variable in integ.env that is NOT used in the
# deliver scripts or NOT NEEDED for the particular platform. This should be 
# checked on a regular basis.

ENV_VAR_FILE="$HOME/integ/integ.env"
ENV_VAR_FILE=$ISDP_SOURCE/grnuc/integ/grnuc.env

echo " checking build environment...."
for var in `cat ${ENV_VAR_FILE} | grep \^export | cut -d= -f1 | cut -d " " -f2` 
do
  # "verifyenv" checks if "$var" has been exported with NON-NULL value
  verifyenv $var 
  if [ $? -ne 0 ]
  then
     errrpt $0 "Cannot continue...Exiting..."
     exit 1  # return error code
  fi

done

exit 0      # if ALL is well...
