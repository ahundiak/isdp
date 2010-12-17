# Initialize
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfminit \
bin/Nfmupdate \
config/initial/ris3.0.dmp \
config/workflow \
-print | cpio -ov | compress > nfmini.sun

rcp -p nfmini.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmini.sun
echo

