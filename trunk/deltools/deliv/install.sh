# Copyright 1992-1995 Intergraph Corporation
# Install DELTOOLS product on CLIPPER workstations

#
# Sizes of the individual modules
#
dtsize=2200
vpsize=1200
xvpsize=900

if [ -x /bin/inqcpuid ]
then
    CPU=`/bin/inqcpuid`
else
    case `uname -m` in
    2[4578]?? | 6[4678]?? )
	CPU=C400
	;;
    20?? | 6[01235]??)
	CPU=C300
	;;
    *)
	CPU=C100
	;;
    esac
fi

# user's should never see this message since newprod itself checks for
# getfile.
if [ ! -x /usr/bin/getfile ]
then
	echo "$0: Error: getfile not found. Cannot install without getfile."
	exit 2
fi


req_free=$dtsize

if [ "$DEFAULTS" != "y" ]
then
    echo "
'vprod' and 'xvprod' are graphical software distribution tools that
can perform local software delivery (like newprod) and can also
perform remote software distribution (like remote_newprod) with
additional capability to define and schedule remote deliveries.

The 'vprod' tool is based on Environ V, and requires the following
products in order to run:

    FORMS_S (SN01087)		version 02.00.02.34 or later
    ENVIRON_S (SS01073)		version 07.00.08.00 or later
    RESOURCES (SS01050)		version 07.00.04.01 or later
    
'vprod' requires an additional $vpsize blocks of disk space.
"
fi

getvp=`getanswer "Do you want the EnvironV-based 'vprod' delivery tool? (y/n)" y yesno`

if [ $getvp = y -o $getvp = Y ]
then
    req_free=`expr $req_free + $vpsize`
fi


if [ "$DEFAULTS" != "y" ]
then
    echo "
The 'xvprod' tool is based on the X Window System, and requires
the following products in order to run:

    XWINDOW (SS01096)		version 07.00.01.00 or later
    XFORMSRT (SN01253)		version 01.02.00.04 or later
    RESOURCES (SS01050)		version 07.00.04.01 or later

'xvprod' requires an additional $xvpsize blocks of disk space.
"
fi

getxvp=`getanswer "Do you want the 'X Window System'-based 'xvprod' delivery tool? (y/n)" n yesno`

if [ $getxvp = y -o $getxvp = Y ]
then
    req_free=`expr $req_free + $xvpsize`
fi

add_entries=`getanswer -c \
"\nIf you like, the /etc/services and /etc/inetd.conf files can be updated \n\
now to include the information for DELTOOLS utilities, or you may add \n\
this information yourself at a later time.\n" \
"Update services and inetd.conf files now?" y yesno`

if [ "$PREPROCESS" = "y" ]
then
    if `Free -t $DESTDIR $req_free`
    then
	Free -a $DESTDIR $req_free
	exit 0
    else
	echo "
Your selections would require $req_free blocks of free space. 
There are only `Free -f $DESTDIR` blocks of free space on this file system
"
	exit 1
    fi
fi

echo "Loading the basic delivery tools..."

getfile deltools.${CPU}| cpio -imud >$NULL 2>&1

[ $? -ne 0 ] && exit 2

#
#  It's been about four major releases since STREAMS-based networking was
#  introduced.  Probably a good time to let this stuff go.  Especially
#  since the "inqcptype" utility relies on the presence of an XNS
#  device node.  Some systems may not have any trace of XNS installed
#  (even have the drivers stripped out of the kernel).
#
#if [ "$SRCMEDIA" != -T -a "$SRCMEDIA" != -F -a "$SRCMEDIA" != -C ]
#then
#    if [ "`./inqcptype`" = IOP ]
#    then
#	echo "
#You must download the UNIXBOOT product and reboot before DELTOOLS will
#load successfuly. This new DELTOOLS requires the new kernel based
#networking interface.\n"
#	exit 255
#    fi
#fi

(
    ln -f newprod getfile
    ln -f newprod makenode
    ln -f compress uncompress
    ln -f compress zcat

    for i in catalog compress dates Free getanswer getfile getmenus \
	     getcdkeys makenode newprod proddata prodinfo rm_pg \
	     runcd uncompress zcat
    do
	ln -f $i /usr/bin
	if [ $? -ne 0 ]
	then
	    mv -f /usr/bin/$i /usr/tmp/$i$$ && ln -f $i /usr/bin
	    [ $? -ne 0 ] && mv -f /usr/tmp/$i$$ /usr/bin/$i 
	fi
    done


    if [ `inqsecure` = 0 ]
    then
	chown bin /usr/bin/Free
	chgrp backup /usr/bin/Free
	chmod 2111 /usr/bin/Free
    fi

    #
    # Set up showconfig in /bin
    #
    cp showconfig /bin
    if [ $? -ne 0 ]
    then
	mv -f /bin/showconfig /tmp/showconfig$$ 
	cp showconfig /bin
    fi
    ln -s /bin/showconfig /usr/bin/showconfig
    if [ $? -ne 0 ]
    then
	rm /usr/bin/showconfig
	ln -s /bin/showconfig /usr/bin/showconfig
    fi
    
    #
    # Set up showconfig.dat, netboards in /etc
    #
    mv -f showconfig.dat /etc
    mv -f netboards /etc


    cp inqlgexist inqscsi inqnativex /bin
    chmod 755 /bin/inqlgexist /bin/inqscsi /bin/inqnativex

    cp inqrop /bin
    if [ $? -ne 0 ]
    then
	mv -f /bin/inqrop /tmp/inqrop$$
	cp inqrop /bin
    fi

    for i in inqcptype inqcpuid inqfpeg inqfpen inqgra inqifb inqifbtype \
	    inqiop inqmemory inqscreens inqsecure inqswap inqzbuf
    do
	ln /bin/inqrop /bin/$i
	if [ $? -ne 0 ]
	then
	    mv -f /bin/$i /tmp/$i$$ && ln /bin/inqrop /bin/$i
	    [ $? -ne 0 ] && mv -f /tmp/$i$$ /bin/$i 
	fi
    done

    # remove inq tools from here since they've been copied to / (takes up
    # disk space.)
    rm -f inq*
    rm -f /tmp/inq*

    mv -f fixes.com README
    rm -f features.com certnote.com
    rm -f /newprod* /bin/getfile* /bin/newprod* /usr/bin/newprod2 $4/newprod2 $4/scroll.pu
    rm -rf $4/defaults

    # Get rid of old, outdated cdprof utility
    [ -f $DESTDIR/cdprof ] && rm -f $DESTDIR/cdprof
    [ -f /usr/bin/cdprof ] && rm -f /usr/bin/cdprof

    mv -f /usr/ip32/util/newprod* /usr/tmp
) >$NULL 2>&1



#
# Check for valid Internet address
#

set `netaddr | grep Internet`
ipaddr=$3
if [ "$ipaddr" = "0.0.0.0" ]
then
    echo "Your machine does not have an Internet address assigned to it."
    echo "Without an Internet address, you will not be able to connect to"
    echo "remote Sun workstations or Intergraph workstations using TCP/IP to"
    echo "perform software delivery.  Contact your system administrator to"
    echo "obtain an address for your machine, and set it by using the"
    echo "'/etc/tcpconfig' utility"
fi  

#
# Set up TCP/IP data for newprod
#
case $add_entries in
[Yy]*)
    /usr/bin/ypwhich > /dev/null 2>&1
    if [ $? = 0 ]
    then
	nismaster=`ypwhich -m services`
	#
	# Machine is using NIS
	# See if "newprod" is already in the services map
	#
	echo "Checking for newprod service in NIS services map..."
	ypcat services | grep newprod > /dev/null 2>&1
	if [ $? != 0 ]
	then
	    # Not found.  Are we a Master?
	    if [ $nismaster = `hostname` ]
	    then
		echo "This system acts as an NIS master for the services map."
		echo "The following information should be added to this system's"
		echo "/etc/services file:"
echo "newprod		608/tcp			# INGR network s/w delivery"
		echo "The NIS services map should then be pushed to all nodes"
		echo "served by this master"
	    else
		echo "The newprod service is not in the NIS services database."
		echo ""
		echo "This machine is not an NIS master; it depends upon the machine named"
		echo "'$nismaster' for its services database."
		echo "Please contact the system administrator for $nismaster and ask them to add"
		echo "the following entry to the services map:"
		echo
echo "newprod		608/tcp			# INGR network s/w delivery"
		echo ""
	    fi
	else
	    echo "'newprod' service is already in the services map."
	fi
    else
	#
	# Machine is NOT using NIS.  If 'newprod' isn't already in /etc/services
	# We can just tack our entry on the end and be done.
	#
	grep newprod /etc/services > /dev/null 2>&1
	if [ $? = 0 ]
	then
	    echo "'newprod' service already present in /etc/services"
	else
	    echo "The newprod service to needs/etc/services file"
echo "newprod		608/tcp			# INGR network s/w delivery" >> /etc/services
	    echo "'newprod' service has been added."
	fi
    fi

    #
    #  Add delserve entry to /etc/inetd.conf if it isn't there already.
    #
    echo ""
    echo "Checking for delserve daemon entry in /etc/inetd.conf"
    grep delserve /etc/inetd.conf > /dev/null 2>&1
    if [ $? = 0 ]
    then
	echo "'delserve' daemon entry already present in /etc/inetd.conf"
	cat /etc/inetd.conf | sed "/^newprod/s/deltools\/delserve -t/deltools\/delserve delserve -t/" > /tmp/inetd.c.new
	mv /etc/inetd.conf /etc/inetd.conf.bak
	mv /tmp/inetd.c.new /etc/inetd.conf
	echo "Issuing SIGHUP signal to inetd to force re-initialization"
	ps -ef | grep inetd | grep -v grep > /dev/null 2>&1
	if [ $? = 0 ]
	then
	    set `ps -ef | grep inetd | grep -v grep`
	    KPID=$2
	    kill -HUP $KPID
	fi
    else
	echo "Adding 'delserve' daemon entry in /etc/inetd.conf"
	cp /etc/inetd.conf /etc/inetd.conf.bak
	echo "newprod		stream	tcp nowait root /usr/ip32/deltools/delserve delserve -t" >> /etc/inetd.conf
	echo "Issuing SIGHUP signal to inetd to force re-initialization"
	ps -ef | grep inetd | grep -v grep > /dev/null 2>&1
	if [ $? = 0 ]
	then
	    set `ps -ef | grep inetd | grep -v grep`
	    KPID=$2
	    kill -HUP $KPID
	fi
    fi
    ;;
*)
    echo \
"Before 'newprod' can be used to install software from a remote delivery
node, the following information must be added to your machine's services
list (either the /etc/services file, or the NIS services map):

    newprod        608/tcp

Before this machine can be used as a delivery node or have remotely-controlled
delivery sessions performed on it, the following information must be added to
the /etc/inetd.conf file:

 newprod        stream  tcp nowait root /usr/ip32/deltools/delserve delserve -t

The inetd daemon must then be reinitialized, either by issuing the SIGHUP
signal or rebooting the system."
    ;;
esac


if [ $getvp = y -o $getvp = Y ]
then
    echo "Loading the EnvironV 'vprod' tool..."
    getfile vprod.$CPU | compress -d | cpio -imud >$NULL 2>&1
    if [ $? = 0 ]
    then
	ln -s $DESTDIR/vprod/vprod /usr/bin/vprod >$NULL 2>&1
	if [ $? != 0 ]
	then
	    mv -f /usr/bin/vprod /usr/tmp/vprod$$ && ln -s $DESTDIR/vprod/vprod /usr/bin
	    [ $? -ne 0 ] && mv -f /usr/tmp/vprod$$ /usr/bin/vprod
	fi
    else
	echo "Error occurred while loading 'vprod'"
	exit 1
    fi
fi

if [ $getxvp = y -o $getxvp = Y ]
then
    echo "Loading the X Window System 'xvprod' tool..."
    getfile xvprod.$CPU | compress -d | cpio -imud >$NULL 2>&1
    if [ $? = 0 ]
    then
	ln -s $DESTDIR/vprod/xvprod /usr/bin/xvprod >$NULL 2>&1
	if [ $? != 0 ]
	then
	    mv -f /usr/bin/xvprod /usr/tmp/xvprod$$ && ln -s $DESTDIR/vprod/xvprod /usr/bin
	    [ $? -ne 0 ] && mv -f /usr/tmp/xvprod$$ /usr/bin/xvprod
	fi
    else
	echo "Error occurred while loading 'xvprod'"
	exit 1
    fi
fi


#
#  If we got this far, then everything is cool.
#  Say bye-bye!
#

exit 0
