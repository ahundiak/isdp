if (test $# = 0)
        then
        echo "Need a processor argument (100 or 400)."
        exit
        fi

LIBARG=libc$1
echo "find ..."
cd ..
find \
$LIBARG/libnfmmem.a \
$LIBARG/libnfmnet.a \
$LIBARG/libnfmsql.a \
$LIBARG/libnfmerr.a \
$LIBARG/libtli.a \
-print | cpio -ov | compress > nfmlib.p$1
rcp -p nfmlib.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmlib.p$1

echo
