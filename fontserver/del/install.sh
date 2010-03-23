# Copyright Intergraph Corporation	1991
# Install FONTSERVE product

echo ""
echo "FONTSERVE delivers the development library /usr/lib/libFS_s.a."
echo "Deliver ENVIRON_S to install the runtime library /usr/shlib/libFS_s."
echo ""

NULL=/dev/null

mkdir	/usr/include	\
	/usr/lib	\
	/usr/lib/c100	\
	/usr/lib/c300	\
	/usr/lib/c400 >$NULL 2>&1

getfile fontserve.prod | compress -d | cpio -imud >/dev/null 2>&1 || exit $?

chown bin * c100/* c300/* c400/*
chgrp bin * c100/* c300/* c400/*

if [ -n "$SYMLINK" ]
then
    ln -f $SYMLINK $4/c100/libFS_s.a /usr/lib
    ln -f $SYMLINK $4/c100/libFS_s.a /usr/lib/c100
    ln -f $SYMLINK $4/c300/libFS_s.a /usr/lib/c300
    ln -f $SYMLINK $4/c400/libFS_s.a /usr/lib/c400
    ln -f $SYMLINK $4/c100/libXFS_s.a /usr/lib
    ln -f $SYMLINK $4/c100/libXFS_s.a /usr/lib/c100
    ln -f $SYMLINK $4/c300/libXFS_s.a /usr/lib/c300
    ln -f $SYMLINK $4/c400/libXFS_s.a /usr/lib/c400
    for i in `ls *.h`
    do
	ln -f $SYMLINK $4/$i /usr/include
    done
else
    ln c100/libFS_s.a /usr/lib
    ln c100/libFS_s.a /usr/lib/c100
    ln c300/libFS_s.a /usr/lib/c300
    ln c400/libFS_s.a /usr/lib/c400
    ln c100/libXFS_s.a /usr/lib
    ln c100/libXFS_s.a /usr/lib/c100
    ln c300/libXFS_s.a /usr/lib/c300
    ln c400/libXFS_s.a /usr/lib/c400
    for i in `ls *.h`
    do
	ln $i /usr/include
    done
fi >$NULL 2>&1

exit 0

# remove old stuff
rm -rf $DESTDIR/c400safe >/dev/null 2>&1
rm -f /usr/lib/c400safe/libXFS_s.a >/dev/null 2>&1
