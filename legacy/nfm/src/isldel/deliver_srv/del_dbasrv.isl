# Administrator Utility

echo "find ..."
cd ../..
find \
bin/dbasrv \
-print | cpio -ov | compress > nfmdbasrv.prod
rcp -p nfmdbasrv.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmdbasrv.prod
echo
/bin/rm nfmdbasrv.prod


