# mkmsg.sh - Does a "make" of the message source files
#
#
#    Usage       : mkmsg.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: mkmsg.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:20  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:59  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:25  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1993/05/05  19:55:56  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


#verify that all evironment variables used in this files are actually defined

# verifyenv CLIPPER LOGFILE

# if [ $? -ne 0 ]
# then
#   errrpt $0 "Some environment variables undefined"
#   exit 1
# fi

# echo "Making message/src files"
# echo "Making message/src files" >> $LOGFILE

# if [ "$CLIPPER" = "y" ]
# then
  cd ${SOURCEDIR}/config/english/messages/src
  make -rk
  if [ "$PROD" = "MODEL" ]
   then
     cd $MODEL/src_nm/config/english/messages/src
     make -rk
  fi
# fi

