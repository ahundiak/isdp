# grmkmess.sh - Makes the message files in $GRTARG/config/english/message/src
#               NOTE : This is CLIPPER specific.
#
#
#    Usage       : grmkmess.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grmkmess.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:50  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.1  1996/04/15  19:44:20  scott
# COMMENT : Changed make configuration to work around Solaris 2.5 bug
#
# Revision 330.0  1996/01/11  20:22:30  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:56:57  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.2  1993/05/05  19:56:14  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#

# This file is CLIPPER specific. The messages source files are compiled on the
# clipper and resulting ".h" and ".msg" linked to the correct directories. 
# The ".h" and ".msg" files are subsequently considered part of the source 
# platform, and are not generated for the SUN and SGI platforms.
#   
# This also means that the source platform on the clipper HAS to have its
# write and execute permissions set so that the ".h" files are linked correctly.


# verify that all environment variables used in this script are defined.

verifyenv GRNUC MKDOPT TBLDLOG CLIPPER MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

# if not CLIPPER platform, exit

if [ "$CLIPPER" != "y" ]
then
   cd $GRNUC/config/english/messages
   for file in `\ls *.msg`
   do
     ncp $file $GRTARG/config/english/messages >> /usr2/tmp/$MASBLDLOG
   done

#  The .msg files were arlready compiled on the CLIPPER
#  Exit from the script if we are on a SUN or SGI

   exit 0;
fi

MSG_SRC_DIR=$GRNUC/config/english/messages/src

MSG_DIR=$GRNUC/config/english/messages


# check that the makefile exists

if [ ! -f $MSG_SRC_DIR/Makefile ]
then
   errrpt $0 "Makefile does not exist in $MSG_SRC_DIR" >> /usr2/tmp/$MASBLDLOG
fi

if [ "$UNIT_TEST" = "on" ]
then
   # get name of ".mb" files to selectively compile

   FILES=`grep \^MBFILES $TESTLIST`  ## should it be $WORKDIR??
   MBFILE=`echo $FILES | cut -d' ' -f2`
   MSGFILE=`echo $FILES | cut -d' ' -f3`
   HFILE=`echo $FILES | cut -d' ' -f4`

   # backup current versions of the files if they exist

   if [ -f $MSG_DIR/$MSGFILE ]
    then
       mv $MSG_DIR/$MSGFILE $MSG_DIR/${MSGFILE}.old
   fi
   
   if [ -f $MSG_SRC_DIR/$MSGFILE ]
    then
      mv $MSG_SRC_DIR/$MSGFILE $MSG_SRC_DIR/${MSGFILE}.old
   fi

   if [ -f $MODEL/include/$HFILE ]
    then
      mv $MODEL/include/$HFILE $MODEL/include/${HFILE}.old
   fi

   if [ -f $MSG_SRC_DIR/$HFILE ]
    then
      mv $MSG_SRC_DIR/$HFILE $MSG_SRC_DIR/${HFILE}.old
   fi
fi

# if UNIT_TEST is not set, $MSGFILE is NULL and therefore, the whole directory
# compiles. Otherwise just the one file compiles.


cd $MSG_SRC_DIR

necho "\n----------$UNIT_MESS config/english/messages/src ----------\n"

make WHY=$WHY -rk -f Makefile $MSGFILE DOPT1="$MKDOPT" > /tmp/$TBLDLOG 2>&1
ncat /tmp/$TBLDLOG 

if [ "$ERRNOTI" = "on" ]
then
  make WHY=$WHY -rk -f Makefile DOPT1="$MKDOPT" > /tmp/$TBLDLOG 2>&1
  errchk /tmp/$TBLDLOG config/english/messages/src
fi


if [ "$UNIT_TEST" = "on" ]
then
   # move the files back where they belong

   if [ -f $MSG_DIR/${MSGFILE}.old ]
    then
       mv $MSG_DIR/${MSGFILE}.old $MSG_DIR/$MSGFILE
   fi

   if [ -f $MSG_SRC_DIR/${MSGFILE}.old ]
    then
      mv $MSG_SRC_DIR/${MSGFILE}.old $MSG_SRC_DIR/$MSGFILE
   fi

   if [ -f $MODEL/include/${HFILE}.old ]
    then
      mv $MODEL/include/${HFILE}.old $MODEL/include/$HFILE
   fi

   if [ -f $MSG_SRC_DIR/${HFILE}.old ]
    then
      mv $MSG_SRC_DIR/${HFILE}.old $MSG_SRC_DIR/$HFILE
   fi
fi
