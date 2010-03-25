# Copyright Intergraph Corporation	1986, 1987, 1988, 1989, 1990
# Install DELTOOLS product for shared access

NULL=/dev/null

getfile deltools.prod | cpio -imud >$NULL 2>&1
[ $? -ne 0 ] && exit 2

# redirect this stuff to $NULL
(
	# Be sure $ROOT/sbin, $ROOT/tmp and $ROOT/usr/bin exist
	mkdir -p $ROOT/sbin $ROOT/tmp $ROOT/usr/bin

	# Don't deliver newprod, getmenus, getanswer or node stuff
	rm -rf newprod getmenus getanswer node

	ln -f compress decompress
	ln -f compress zcat

	# install the $ROOT/usr/bin images
	for i in dates *compress zcat Free runcd showconfig prodinfo \
	    proddata rm_pg
	do
		ln -f $i $ROOT/usr/bin >$NULL 2>&1 && continue
		mv -f $ROOT/usr/bin/$i $ROOT/usr/tmp/$i$$ && \
			ln -f $i $ROOT/usr/bin
		[ $? -ne 0 ] && mv -f $ROOT/usr/tmp/$i$$ $ROOT/usr/bin/$i
	done

	# install the $ROOT/sbin images
	cp inqlgexist inqscsi $ROOT/sbin
	cp inqrop $ROOT/sbin
	if [ $? -ne 0 ]
	then
		mv -f $ROOT/sbin/inqrop $ROOT/tmp/inqrop$$
		cp inqrop $ROOT/sbin
	fi

	for i in inqcptype inqcpuid inqfpeg inqfpen inqgra inqifb inqifbtype \
		inqiop inqmemory inqscreens inqswap inqzbuf
	do
		ln $ROOT/sbin/inqrop $ROOT/sbin/$i && continue
		mv -f $ROOT/sbin/$i $ROOT/tmp/$i$$ &&
			ln $ROOT/sbin/inqrop $ROOT/sbin/$i
		[ $? -ne 0 ] && mv -f $ROOT/tmp/$i$$ $ROOT/sbin/$i
	done

	# Create symlinks for backwards compatibility of programs using
	# hardcoded /bin/inq*
	for i in inqcptype inqcpuid inqfpeg inqfpen inqgra inqifb inqifbtype \
		inqiop inqmemory inqscreens inqswap inqzbuf inqrop
	do
		ln -s /sbin/$i $ROOT/usr/bin/$i
	done

	# remove them from here since they've been copied
	rm -f inq*
) >$NULL 2>&1

exit 0
