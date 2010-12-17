LIBARG=lib
echo "find ..."
cd ../../
find \
$LIBARG/libnfmmem.a \
$LIBARG/libnfmnet.a \
$LIBARG/libnfmsql.a \
$LIBARG/libnfmerr.a \
$LIBARG/libtli.a \
-print | cpio -ov | compress > nfmlib.sun
rcp -p nfmlib.sun delserv@aec:/usr5/delserv/nfm/i_nfmdp/nfmlib.sun
echo
