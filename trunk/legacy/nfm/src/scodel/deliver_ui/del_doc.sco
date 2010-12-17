echo "find ..."
cd ../../
find doc \
-print | cpio -ov | compress > nfmdoc.prod
rcp -p nfmdoc.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmdoc.prod
rm nfmdoc.prod
echo
