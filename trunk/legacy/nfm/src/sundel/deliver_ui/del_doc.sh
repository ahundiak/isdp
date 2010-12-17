# Documentation
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find doc \
-print | cpio -ov | compress > nfmdoc.sun

rcp -p nfmdoc.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmdoc.sun
