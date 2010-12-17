LIBARG=lib

echo "find ..."
cd ../../
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
$LIBARG/alter.a \
make \
-print | cpio -ov | compress > nfmreq.sun
rcp -p nfmreq.sun delserv@aec:/usr5/delserv/nfm/i_nfmdp/nfmreq.sun
echo
