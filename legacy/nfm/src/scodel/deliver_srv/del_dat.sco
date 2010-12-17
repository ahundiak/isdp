# Initialize

echo "find ..."
cd ../..
find \
bin/dattoclh \
risutil \
-print | cpio -ov | compress > nfmini.prod
rcp -p nfmini.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmini.prod
rm nfmini.sco
echo

