# Documentation
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../../
find doc \
-print | cpio -ov | compress > nfmdoc.prod

rcp -p nfmdoc.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmdoc.prod
