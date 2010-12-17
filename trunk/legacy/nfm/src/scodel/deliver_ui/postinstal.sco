# postinstall script for I_NFMUI

RM=/bin/rm
LN=/bin/ln
LOGFILE=$DESTDIR/log

# get file partition
fp=`echo $DESTDIR | cut -f2 -d"/"`
deldir=/$fp/ip32/nfm

echo ""
echo "Executing postinstall script ..."

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
#  install.sco; therefore, the NFMdaemon is not running.
#

if [ -f /etc/init.d/nfm ] 
then
    chmod +x /etc/init.d/nfm
    echo "postinstall: Starting the NFM Daemon"
    /etc/init.d/nfm start_nfm; 
fi

# change owner and group of files delivered to i_nfmui

find $DESTDIR -exec chown root {} \;
find $DESTDIR -exec chgrp sys {} \;

exit 0
