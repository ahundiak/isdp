# Bulkloader
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmbulk \
config/english/commands/bulk.dat \
-print | cpio -ov | compress > nfmblk.prod

rcp -p nfmblk.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmblk.prod
echo
