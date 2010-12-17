# Bulkloader
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmbulk \
config/english/commands/bulk.dat \
-print | cpio -ov | compress > nfmblk.sun

rcp -p nfmblk.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmblk.sun
echo
