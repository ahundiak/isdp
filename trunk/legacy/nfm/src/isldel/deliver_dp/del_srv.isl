LIBARG=lib

echo "find ..."
cd ../..
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
$LIBARG/libalter.a \
$LIBARG/libnfmftr.a \
-print | cpio -ov | compress > nfmsrv.prod
rcp -p nfmsrv.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmdp/nfmsrv.prod
echo


