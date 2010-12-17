# postinstall.sh script for I_NFMUI  - Sun Version

RM=/bin/rm
LN=/usr/5bin/ln

# get file partition
#fp=`echo $DESTDIR | cut -f2 -d"/"`
for i in 1 2 3 4 5
do
   dir=`echo $DESTDIR | cut -f$i -d"/"`
   if [ "$dir" = "ip32" ]
   then
      let j=$i-1
      fp=`echo $DESTDIR | cut -f1-$j -d"/"`
      break
   fi
done

deldir=/$fp/ip32/nfm

LOGFILE=$deldir/log

echo ""
echo "Executing postinstall.sh script ..."

if [ -L /usr/ip32/nfm/i_nfmui ]
then
        echo "Removing symbolic link to /usr/ip32/nfm/i_nfmui ..."
	$RM -fr /usr/ip32/nfm/i_nfmui >>$LOGFILE 2>>$LOGFILE
	$RM -fr /usr/ip32/nfm >>$LOGFILE 2>>$LOGFILE
        echo "Establish symbolic link to /usr/ip32/nfm ..."
	$LN -fs $deldir /usr/ip32/nfm >>$LOGFILE 2>>$LOGFILE
fi

#
#  Start the I/NFM Daemon. If installing onto a partition other
#  that /usr, the link to /usr/ip32/nfm had not been established during
#  install.sh; therefore, the NFMdaemon is not running.
#

/usr/ip32/nfm/bin/NFMdaemon &

# change owner and group of files delivered to i_nfmui

find $DESTDIR -exec chown root {} \;
#find $DESTDIR -exec chgrp sys {} \;

# remove existing README, product.def, and remove.sh from OLD delivery
# directory (/usrx/ip32/nfm) - only if they are there!

if [ -f $deldir/README ]
then
    $RM $deldir/README >>$LOGFILE 2>>$LOGFILE
fi

if [ -f $deldir/product.def ]
then
    $RM $deldir/product.def >>$LOGFILE 2>>$LOGFILE
fi

if [ -f $deldir/remove.isl ]
then
    $RM $deldir/remove.isl >>$LOGFILE 2>>$LOGFILE
fi

if [ -f $deldir/log ]
then
    $RM $deldir/log >>$LOGFILE 2>>$LOGFILE
fi

exit 0
