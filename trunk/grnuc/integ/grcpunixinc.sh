# grcpunixinc.sh - Copies $GRNUC/unix_include files to $GRTARG/unix_include
#
#    Usage       : grcpunixinc.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grcpunixinc.sh,v $
#Revision 1.2  2002/02/05 19:57:07  hans
#Disabled section "Verifying files in unix_include" (uses SCfetch)
#
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.1  1997/05/29  15:42:32  scott
# COMMENT : Version upgrade for 3.4
#
# Revision 340.0  1997/05/27  22:06:42  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#


# verify that all environment variables used in this script are defined.

verifyenv GRTARG GRNUC BUILDER CPUTYPE
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  MAILER=elm
else
  MAILER=Mail
fi

necho "\n------------$UNIT_MESS copying files to unix_include ------------\n"

cd $GRNUC
find unix_include -depth -print | cpio -pmduv $GRTARG

# Forget about "Verifying files in unix_include"

exit 0

necho "\n------------ Verifying files in unix_include ------------\n"

cd $GRNUC/unix_include/$CPUTYPE
for file in $(find . -depth -type f -print)
do
  cd /tmp
  SCfetch -v 340.0 unix_include/$CPUTYPE/$file
  diff $(basename $file) /usr/include/$file > unixinc.dif 2>&1
  if [ "$CPUTYPE" = "sgi" ]
  then
    grep -v "\$Revision:" unixinc.dif > unixinc.diff
  else
    grep -v "\$Id:" unixinc.dif > unixinc.diff
  fi
  grep ">" unixinc.diff > /dev/null 2>&1
  if [ "$?" = "0" ]
  then
    necho "INVALID FILE : $GRNUC/unix_include/$CPUTYPE/$file"
    if [ ! -f /tmp/unixinc.$CPUTYPE ]
    then
      echo "  \n" >> /tmp/unixinc.$CPUTYPE
      echo "This is the list of invalid unix_include files on `uname -n`\n" >> /tmp/unixinc.$CPUTYPE
    fi
    echo "INVALID FILE : $GRNUC/unix_include/$CPUTYPE/$file" >> /tmp/unixinc.$CPUTYPE
  fi
  rm -f $(basename $file) unixinc.dif unixinc.diff
  cd -
done

if [ -f /tmp/unixinc.$CPUTYPE ]
then
  $MAILER -s "Invalid Unix Inc Files" $BUILDER < /tmp/unixinc.$CPUTYPE 
  rm -f /tmp/unixinc.$CPUTYPE
fi
