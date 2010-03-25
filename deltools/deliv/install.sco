# Copyright 1992-1995 Intergraph Corporation
# Install DELTOOLS product on SCO UNIX systems
#
# Sizes of the individual modules
#
dtsize=3500

# user's should never see this message since newprod itself checks for
# getfile.
if [ ! -x /usr/bin/getfile ]
then
	echo "$0: Error: getfile not found. Cannot install without getfile."
	exit 2
fi


req_free=$dtsize
getxvp=n
if [ ! -x /usr/bin/Free ]
then
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
getfile deltools.sco | compress -d | cpio -imud >$NULL 2>&1

[ $? -ne 0 ] && exit 2

(
	ln -f newprod getfile
	ln -f newprod makenode

	for i in catalog dates Free getanswer getfile getcdkeys makenode \
		 netaddr newprod proddata prodinfo rm_pg runcd 
	do
	    if [ -f $i ]
	    then
		ln -f -s $DESTDIR/$i /usr/bin
		if [ $? -ne 0 ]
		then
		    mv -f /usr/bin/$i /usr/tmp/$i$$ && ln -f -s $DESTDIR/$i /usr/bin
		    [ $? -ne 0 ] && mv -f /usr/tmp/$i$$ /usr/bin/$i 
		fi
            fi
	done
) >$NULL 2>&1


# remove old, outdated "cdprof" utility

[ -f $DESTDIR/cdprof ] && rm -f $DESTDIR/cdprof > $NULL 2>&1
[ -f /usr/bin/cdprof ] && rm -f /usr/bin/cdprof > $NULL 2>&1


if [ $add_entries = "y" -o $add_entries = "Y" ]
then
    #
    # Set up TCP/IP data for newprod
    #
#    if [ -x /usr/bin/ypwhich  -a /usr/bin/ypwhich ]
#    then
#      nismaster=`ypwhich -m services > $NULL 2>&1`
#      if [ $? = 0 ]
#      then
#	#
#	# Machine is using NIS
#	# See if "newprod" is already in the services database
#	#
#	echo "Checking for newprod service in NIS services database..."
#	ypcat services | grep newprod > $NULL 2>&1
#	if [ $? != 0 ]
#	then
#	  # Not found.  Are we a Master?
#	  if [ $nismaster = `hostname` ]
#	  then
#	    echo "Adding newprod service to NIS services database"
#echo "newprod		608/tcp				# INGR network s/w delivery" >> /etc/services
#	    echo "The NIS services database needs to be rebuilt now."
#	  else
#	    echo "The newprod service is not in the NIS services database."
#	    echo ""
#	    echo "This machine is not an NIS master; it depends upon the machine named"
#	    echo "'$nismaster' for its services database."
#	    echo "Please contact the system administrator for $nismaster and ask them to add"
#	    echo "the following entry to the services database:"
#	    echo
#echo "newprod		608/tcp				# INGR network s/w delivery"
#	    echo ""
#	  fi
#	else
#	  echo "'newprod' service is already in the services database."
#	fi
#      else
#	#
#	# Machine is NOT using NIS.  If 'newprod' isn't already in /etc/services
#	# We can just tack our entry on the end and be done.
#	#
#	grep newprod /etc/services > $NULL 2>&1
#	if [ $? = 0 ]
#	then
#	    echo "'newprod' service already present in /etc/services"
#	else
#	    echo "Adding newprod service to /etc/services database"
#echo "newprod		608/tcp				# INGR network s/w delivery" >> /etc/services
#	    echo "'newprod' service has been added."
#	fi
#      fi
#    else
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
#    fi

    #
    #  Add delserve entry to /etc/inetd.conf if it isn't there already.
    #
    echo ""
    echo "Checking for delserve daemon entry in /etc/inetd.conf"
    grep delserve /etc/inetd.conf > $NULL 2>&1
    if [ $? = 0 ]
    then
	echo "'delserve' daemon entry already present in /etc/inetd.conf"
    else
	echo "Adding 'delserve' daemon entry in /etc/inetd.conf"
echo "newprod		stream	tcp nowait root /usr/ip32/deltools/delserve delserve -t" >> /etc/inetd.conf
	echo "Issuing SIGHUP signal to inetd to force re-initialization"
	ps -ef | grep inetd | grep -v grep | cut -c9-15 | xargs kill -HUP
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

    newprod        stream  tcp nowait root /usr/ip32/deltools/delserve delserve -t

The inetd daemon must then be reinitialized, either by issuing the SIGHUP
signal or rebooting the system."
fi

#
#  If we got this far, then everything is cool.
#  Say bye-bye!
#

exit 0
