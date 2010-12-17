# Initialize

echo "find ..."
cd ../..
find \
bin/dattoclh \
-print | cpio -ov | compress > nfmdat.prod
rcp -p nfmdat.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmdat.prod
echo
/bin/rm nfmdat.prod
