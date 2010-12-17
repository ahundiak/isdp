if (test $# = 0)
        then
        echo "Need a processor argument (100 or 400)."
        exit
        fi

LIBARG=libc$1

echo "find ..."
cd ..
find \
$LIBARG/libnfmcuti.a \
$LIBARG/librisinit.a \
$LIBARG/libnfms.a \
$LIBARG/libnfmsuti.a \
$LIBARG/libnfmwf.a \
$LIBARG/libnfma.a \
$LIBARG/libnfmu.a \
$LIBARG/libnfmlists.a \
$LIBARG/libnfmsac.a \
$LIBARG/libcmdtools.a \
$LIBARG/libdbtools.a \
$LIBARG/libnfmsql.a \
$LIBARG/libsystools.a \
$LIBARG/libnfmftr.a \
-print | cpio -ov | compress > nfmsrv.p$1
rcp -p nfmsrv.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmsrv.p$1

echo


