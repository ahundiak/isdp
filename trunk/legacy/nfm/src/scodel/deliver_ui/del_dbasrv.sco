# Admin Utility

echo "find ..."
cd ../../
find \
bin/dbasrv \
-print | cpio -ov | compress > dbasrv.prod

rcp dbasrv.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/dbasrv.prod
rm dbasrv.prod
echo
