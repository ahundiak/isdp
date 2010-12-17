LIBARG=lib
echo "sent ..."
cd ../..
find \
$LIBARG/libnfmmem.a \
$LIBARG/libnfmnet.a \
$LIBARG/libnfmsql.a \
$LIBARG/libnfmerr.a \
$LIBARG/libtli.a \
-print | cpio -ov | compress > nfmlib.prod
rcp -p nfmlib.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmdp/nfmlib.prod
echo
