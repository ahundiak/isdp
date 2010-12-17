# NFM/dbasrv

echo "find ..."
cd ../../
find \
bin/dbasrv \
-print | cpio -ov | compress > nfmdbasrv.prod

rcp -p nfmdbasrv.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmdbasrv.prod
echo
