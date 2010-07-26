#
#
# maketrans.sh - make the translator files
# 
#    Usage  : maketrans.sh
#    Inputs : none
#    Output : error messages
#    Return : none
#      Code   
#
# $Log: maketrans.sh,v $
# Revision 1.1.1.1  2001/12/17 22:40:07  hans
# Initial import to CVS
#
# Revision 340.1  1997/05/29  15:42:38  scott
# COMMENT : Version upgrade for 3.4
#
# Revision 340.0  1997/05/27  22:07:16  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
#
verifyenv VERSNO GRNUC

necho "- - - - - - - - - Building Translator Directories - - - - - - - - -"

ncp $GRNUC/tr/config/message_source/TR_msg.mb $GRNUC/config/english/messages/src
export TRANSLATE=$GRTARG/tr
export TRANSLATE_VERSION=03.04.00.${VERSNO}
echo
echo $TRANSLATE
echo
if [ ! -d $TRANSLATE ]
 then
  mkdir $TRANSLATE
fi
cd $GRNUC/tr
find . -print | cpio -pmudv $TRANSLATE

necho "\n...Compiling translator files"
cd $TRANSLATE
$TRANSLATE/bin/make_TRcmd.sh

if [ "$GRNUC" != "$GRTARG" ]
then
ncp $GRTARG/config/english/messages/TR_msg.msg $GRNUC/config/english/messages
fi

