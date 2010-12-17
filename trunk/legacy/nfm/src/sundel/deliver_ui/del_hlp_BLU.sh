# Help
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
cfg/english/help/help_file.hc \
cfg/english/help/help_info \
-print | cpio -ov | \
compress > nfmhlpBLU.sun

rcp -p nfmhlpBLU.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmhlpBLU.sun
echo


