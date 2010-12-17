# Administrator Utility

echo "find ..."
cd ../..
find \
bin/dbasrv \
-print | cpio -ov | compress > dbasrv.prod
rcp -p dbasrv.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/dbasrv.prod
rm dbasrv.sco
echo


