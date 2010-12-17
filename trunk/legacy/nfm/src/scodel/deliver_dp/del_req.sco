
LIBARG=scolib

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
make \
-print | cpio -ov | compress > nfmreq.prod
rcp -p nfmreq.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmdp/nfmreq.prod
rm nfmreq.sco
echo
