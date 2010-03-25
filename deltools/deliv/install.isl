# Copyright 1992-1995 Intergraph Corporation
# Install DELTOOLS product on Intel workstations running Solaris 2.x

# INGRHOME variable indicates location of shared bin, lib and include
# directories.

INGRHOME=${INGRHOME%%:*}

#
# Sizes of the individual modules
#
dtsize=3500

# user's should never see this message since newprod itself checks for
# getfile.
if [ ! -x /usr/bin/getfile -a ! -x $INGRHOME/bin/getfile ]
then
    echo "$0: Error: getfile not found. Cannot install without getfile."
    exit 2
fi

req_free=$dtsize

if [ ! -x /usr/bin/Free -a ! -x $INGRHOME/bin/Free ]
then
    virgin=y
    getxvp=n
    add_entries=n

    if [ "$PREPROCESS" = "y" ]
    then
        exit 0
    fi
else
    add_entries=`getanswer -c \
"\nIf you like, the /etc/services and /etc/inetd.conf files can be updated \n\
now to include the information for DELTOOLS utilities, or you may add \n\
this information yourself at a later time.\n" \
"Update services and inetd.conf files now?" y yesno`

fi

if [ "$PREPROCESS" = "y" ]
then
    if [ "$virgin" = "y" ]
    then
	exit 0
    elif `Free -t $DESTDIR $req_free`
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
getfile deltools.isl | compress -d | cpio -icmud >$NULL 2>&1
[ $? -ne 0 ] && exit 2

(
	ln newprod getfile
	ln newprod makenode

	for i in catalog dates delserve Free getanswer getfile getcdkeys \
		 makenode newprod proddata prodinfo remove rm_pg runcd
	do
	    if [ -f $i ]
	    then
		ln -s $DESTDIR/$i $INGRHOME/bin/$i > $NULL 2>&1
		if [ $? -ne 0 ]
		then
		    mv -f $INGRHOME/bin/$i /usr/tmp/$i$$ && ln -s $DESTDIR/$i $INGRHOME/bin/$i
		    [ $? -ne 0 ] && mv -f /usr/tmp/$i$$ $INGRHOME/bin/$i 
		fi
            fi
	done
) >$NULL 2>&1


# get rid of old, outdated cdprof utility

[ -f $DESTDIR/cdprof ] && rm -f $DESTDIR/cdprof >$NULL 2>&1
[ -f $INGRHOME/bin/cdprof ] && rm -f $INGRHOME/bin/cdprof >$NULL 2>&1
[ -h $INGRHOME/bin/cdprof ] && rm -f $INGRHOME/bin/cdprof >$NULL 2>&1

#
# Check for valid Internet address
#

if [ -x /usr/ucb/hostname ]
then
    hostname=`/usr/ucb/hostname`
else
    hostname=`uname -n`
fi

if [ $add_entries = "y" -o $add_entries = "Y" ]
then
    #
    # Set up TCP/IP data for newprod
    #
    ypwhich > $NULL 2>&1
    if [ $? = 0 ]
    then
	nismaster=`ypwhich -m services`
	#
	# Machine is using NIS
	# See if "newprod" is already in the services database
	#
	echo "Checking for newprod service in NIS services database..."
	ypcat services | grep newprod > $NULL 2>&1
	if [ $? != 0 ]
	then
	    # Not found.  Are we a Master?
	    if [ "$nismaster" = "`hostname`" ]
	    then
		echo "Adding newprod service to /etc/services"
echo "newprod		608/tcp				# INGR network s/w delivery" >> /etc/services
		echo "The NIS services database must now be rebuilt."
		echo
	    else
		echo "The newprod service is not in the NIS services database."
		echo ""
		echo "This machine is not an NIS master; it depends upon the machine named"
		echo "'$nismaster' for its services database."
		echo "Please contact the system administrator for $nismaster and ask them to add"
		echo "the following entry to the services database:"
		echo
echo "newprod		608/tcp				# INGR network s/w delivery"
		echo ""
	    fi
	else
	    echo "'newprod' service is already in the services database."
	fi
    else
	#
	# Machine is NOT using NIS.  If 'newprod' isn't already in /etc/services
	# We can just tack our entry on the end and be done.
	#
	grep newprod /etc/services > $NULL 2>&1
	if [ $? = 0 ]
	then
	    echo "'newprod' service already present in /etc/services"
	else
	    echo "Adding newprod service to /etc/services database"
echo "newprod		608/tcp				# INGR network s/w delivery" >> /etc/services
	    echo "'newprod' service has been added."
	fi
    fi

    #
    #  Add delserve entry to /etc/inetd.conf if it isn't there already.
    #
    echo ""
    echo "Checking for delserve daemon entry in /etc/inetd.conf"
    grep delserve /etc/inetd.conf > $NULL 2>&1
    if [ $? = 0 ]
    then
	echo "'delserve' daemon entry already present in /etc/inetd.conf"
	cat /etc/inetd.conf | sed "/^newprod/s/deltools\/delserve -t/deltools\/delserve delserve -t/" > /tmp/inetd.c.new
	mv /etc/inetd.conf /etc/inetd.conf.save
	mv /tmp/inetd.c.new /etc/inetd.conf
	chmod 0644 /etc/inetd.conf
	echo "Issuing SIGHUP signal to inetd to force re-initialization"
	ps -ef | grep inetd | grep -v grep > $NULL 2>&1
	if [ $? = 0 ]
	then
	    set `ps -ef | grep inetd | grep -v grep`
	    KPID=$2
	    kill -HUP $KPID
	fi
    else
	echo "Adding 'delserve' daemon entry in /etc/inetd.conf"
echo "newprod		stream	tcp nowait root $DESTDIR/delserve delserve -t" >> /etc/inetd.conf
	echo "Issuing SIGHUP signal to inetd to force re-initialization"
	ps -ef | grep inetd | grep -v grep > $NULL 2>&1
	if [ $? = 0 ]
	then
	    set `ps -ef | grep inetd | grep -v grep`
	    KPID=$2
	    kill -HUP $KPID
	fi
    fi
else
    echo \
"Before 'newprod' can be used to install software from a remote delivery
node, the following information must be added to your machine's services
list (either the /etc/services file, or the NIS services map):

    newprod        608/tcp

Before this machine can be used as a delivery node or have remotely-controlled
delivery sessions performed on it, the following information must be added to
the /etc/inetd.conf file:

    newprod        stream  tcp nowait root $DESTDIR/delserve delserve -t

The inetd daemon must then be reinitialized, either by issuing the SIGHUP
signal or rebooting the system."
fi

#
#  If we got this far, then everything is cool.
#  Say bye-bye!
#

exit 0
