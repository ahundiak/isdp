# Utilities
# Modified for Sun version - 30.11.93
#

echo "find ..."
cd ../../
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.prod
rcp -p nfmuti.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmuti.prod
echo 
/bin/rm nfmuti.prod
