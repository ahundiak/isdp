# rmcfgcomm.sh - Removes files in config/commands directory of product and 
#                "touch"es all ".sl" files in the source.
#
#    Usage       : rmcfgcomm.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: rmcfgcomm.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:34  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:23:12  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:39  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1993/05/05  19:44:41  tim
# COMMENT : corrected Log keyword for RCS history
#


#verify that all environment variable used in this script are actually defined

verifyenv SOURCEDIR LOGFILE CLIPPER

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined"
  exit 1
fi

if [ "$CLIPPER" = "y" ]
then

  if [ ! -d ${SOURCEDIR}/config/commands ]
  then
    mkdir -p ${SOURCEDIR}/config/commands
  fi
  cd ${SOURCEDIR}/config/commands

  echo 'Removing config/commands'
  echo 'Removing config/commands' >> $LOGFILE

  if [ "$UNIT_TEST" = "on" ]
   then
     CFILE=`grep \^COMM $WORKDIR/integ/atp/testlist | cut -d' ' -f2`
     echo $CFILE > /tmp/cmds.$$
     mv $CFILE old.$CFILE
     cp old.$CFILE $CFILE
  else
     find ${SOURCEDIR}/config/commands -type f -print > /tmp/cmds.$$
  fi

  for file in `cat /tmp/cmds.$$`
  do 
    nrm $file  # "nrm" removes and verifies the remove
  done

  if [ "$UNIT_TEST" = "on" ]
   then 
    mv old.$CFILE $CFILE
  else
    echo 'Touching .sl files'
    echo 'Touching .sl files' >> $LOGFILE
    cd $SOURCEDIR
    find . -type f -name \*.sl -print | fgrep -v make.sl | xargs touch
  fi
fi
