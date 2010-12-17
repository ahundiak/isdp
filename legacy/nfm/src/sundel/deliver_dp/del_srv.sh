LIBARG=lib

echo "find ..."
cd ../../
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
$LIBARG/alter.a \
-print | cpio -ov | compress > nfmsrv.sun
rcp -p nfmsrv.sun delserv@aec:/usr5/delserv/nfm/i_nfmdp/nfmsrv.sun
echo


