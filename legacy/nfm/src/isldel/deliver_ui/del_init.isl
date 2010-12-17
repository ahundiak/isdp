# Initialize
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfminit \
bin/NFMdmdftr.sh \
config/initial/ris3.0.dmp \
config/workflow \
-print | cpio -ov | compress > nfmini.prod

rcp -p nfmini.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmini.prod
echo

