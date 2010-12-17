
LIBARG=scolib
echo "find ..."
cd ../..
find \
$LIBARG/libnfmmem.a \
$LIBARG/alter.a \
$LIBARG/libnfmnet.a \
$LIBARG/libnfmsql.a \
$LIBARG/libnfmerr.a \
$LIBARG/libtli.a \
-print | cpio -ov | compress > nfmlib.prod
rcp -p nfmlib.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmdp/nfmlib.prod
rm nfmlib.prod
echo
