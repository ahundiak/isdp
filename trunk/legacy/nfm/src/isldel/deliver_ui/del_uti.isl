# Utilities

echo "find ..."
cd ../..
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.prod
rcp -p nfmuti.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmuti.prod
echo 
