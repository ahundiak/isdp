LIBARG=lib

echo "find ..."
cd ../..
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
$LIBARG/libalter.a \
-print | cpio -ov | compress > nfmreq.prod
rcp -p nfmreq.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmdp/nfmreq.prod
echo
