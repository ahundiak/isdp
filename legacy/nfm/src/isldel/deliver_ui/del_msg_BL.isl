# Messages
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
cfg \
-print | cpio -ov | compress > nfmmsgBLU.sun

rcp -p nfmmsgBLU.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmmsgBLU.sun
