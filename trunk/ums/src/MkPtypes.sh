#  MkPtypes.sh

# 02-12-92  sml    Written, drawing liberally on similar
#                  scripts from XFORMS and HELP
# 02/12/92  dmb    Made some minor adjustments to work in build
#                  platform with symbolic links and multiple users.
#
#  This shell script creates 3 prototype files for UMS
#    --for all functions        (pums_all.h)
#    --for private functions    (pums_pri.h)
#    --for public functions     (pums_pub.h)

#set -x

# dmb:02/12/92:Added to prevent empty file problem.
# NOTE: the action on trap must be NULL ('') for the signal to be eaten.
# Setting the action to DO_NOTHING_SUCCESSFULLY (':') seems to let it 
# pass on to the child procecsses which can also result in empty files.
# Also note sh doesn't know how to handle symbolic references to signals,
# so we will hard code 2 instead of INT.
trap '' 2 3 15

TMPLIST=umslist.$$

#  Get all functions
\ls [UCg]*.c > /usr/tmp/$TMPLIST
mkptypes -e -A `cat /usr/tmp/$TMPLIST` >/usr/tmp/pums_all.h$$

#  Get private functions
egrep -e '_UMS|UMC|getopt|/\*' /usr/tmp/pums_all.h$$ >/usr/tmp/pums_pri.h$$

#  set up public file header
cat pub_hdr > /usr/tmp/pums_pub.h$$

#  Get public functions
egrep -v -e '_UMS|UMC|UMSgetopt' /usr/tmp/pums_all.h$$ |
    egrep -e 'extern' >> /usr/tmp/pums_pub.h$$

#  Set up public file footer
cat pub_ftr >> /usr/tmp/pums_pub.h$$


#  Fix up pums_all.h for use internally
cat all_hdr /usr/tmp/pums_all.h$$ all_ftr > /usr/tmp/tums_all.h$$
mv /usr/tmp/tums_all.h$$ /usr/tmp/pums_all.h$$

#
#  Update existing prototype files, if necessary
#
echo "Checking private interface changes" 
if cmp /usr/tmp/pums_pri.h$$ $UMS/include/pums_pri.h >/dev/null 2>&1
then
  echo 'No interface changes for private functions (pums_pri.h)'
  rm -f /usr/tmp/pums_pri.h$$
else
  echo 'Interface changes have occurred for private functions (pums_pri.h)'
  mv $UMS/include/pums_pri.h $UMS/include/OLD_PROTO/pums_pri.h
  mv /usr/tmp/pums_pri.h$$ $UMS/include/pums_pri.h
fi

echo "Checking public interface changes"
if cmp /usr/tmp/pums_pub.h$$ $UMS/include/pums_pub.h >/dev/null 2>&1
then
  echo 'No interface changes for public functions (pums_pub.h)'
  rm -f /usr/tmp/pums_pub.h$$
else
  echo 'Interface changes have occurred for public functions (pums_pub.h)'
  mv $UMS/include/pums_pub.h $UMS/include/OLD_PROTO/pums_pub.h
  mv /usr/tmp/pums_pub.h$$ $UMS/include/pums_pub.h
fi

echo "Checking all interface changes"
if cmp /usr/tmp/pums_all.h$$ $UMS/include/pums_all.h >/dev/null 2>&1
then
  echo 'No interface changes for all functions (pums_all.h)'
  rm -f /usr/tmp/pums_all.h$$
else
  echo 'Interface changes have occurred for all functions (pums_all.h)'
  mv $UMS/include/pums_all.h $UMS/include/OLD_PROTO/pums_all.h
  mv /usr/tmp/pums_all.h$$ $UMS/include/pums_all.h
fi

rm -f /usr/tmp/$TMPLIST
