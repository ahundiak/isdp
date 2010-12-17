# Utilities

echo "find ..."
cd ../..
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.prod
rcp -p nfmuti.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmuti.prod
rm nfmuti.prod
echo 
