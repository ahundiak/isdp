if (test $# = 0)
        then
        echo "Need a processor argument (100 or 400)."
        exit
        fi

LIBARG=libc$1

echo "find ..."
cd ..
find \
$LIBARG/libnfmr.a \
$LIBARG/libnfmruti.a \
$LIBARG/libnfmtools.a \
$LIBARG/libfilexfer.a \
$LIBARG/libsystools.a \
$LIBARG/libnfmnet.a \
$LIBARG/libtli.a \
$LIBARG/libnfmmem.a \
$LIBARG/libnfmerr.a \
makefiles \
-print | cpio -ov | compress nfmreq.p$1
rcp -p nfmreq.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmreq.p$1

echo
