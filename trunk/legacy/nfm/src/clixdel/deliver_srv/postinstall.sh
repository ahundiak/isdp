# postinstall.sh script for I_NFMSRV

RM=/bin/rm
LN=/bin/ln
LOGFILE=$DESTDIR/log

# get file partition
fp=`echo $DESTDIR | cut -f2 -d"/"`
deldir=/$fp/ip32/nfm

 
#  The bin directory of nfm should have rwxr-xr-x permissions
#                                 -Jujare,  18-Apr-1995
for i in $deldir/bin $deldir/config $deldir/doc $deldir/utilities \
         $deldir/cfg $deldir/forms
do
if [ -d $i ] ;then chmod 755 $i ;fi
done
 


echo ""
echo "Executing postinstall.sh script ..."

if [ -L /usr/ip32/nfm/i_nfmsrv ]
then
        echo "Removing symbolic link to /usr/ip32/nfm/i_nfmsrv ..."
	$RM -fr /usr/ip32/nfm/i_nfmsrv >>$LOGFILE 2>>$LOGFILE
	$RM -fr /usr/ip32/nfm >>$LOGFILE 2>>$LOGFILE
        echo "Establish symbolic link to /usr/ip32/nfm ..."
	$LN -fs $deldir /usr/ip32/nfm >>$LOGFILE 2>>$LOGFILE
fi

#
#  Start the I/NFM Daemon. If installing onto a partition other
#  that /usr, the link to /usr/ip32/nfm had not been established during
#  install.sh; therefore, the NFMdaemon is not running.
#

if [ -f /etc/init.d/nfm ] 
then
    /etc/init.d/nfm start_nfm; 
fi

# change owner and group of files delivered to i_nfmsrv

find $DESTDIR -exec chown root {} \;
find $DESTDIR -exec chgrp sys {} \;

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

if [ -f $deldir/remove.sh ]
then
    $RM $deldir/remove.sh >>$LOGFILE 2>>$LOGFILE
fi

if [ -f $deldir/log ]
then
    $RM $deldir/log >>$LOGFILE 2>>$LOGFILE
fi

exit 0
