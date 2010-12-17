
LIBARG=scolib

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
$LIBARG/libnfmftr.a \
-print | cpio -ov | compress > nfmsrv.prod
rcp -p nfmsrv.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmdp/nfmsrv.prod
rm nfmsrv.sco
echo


