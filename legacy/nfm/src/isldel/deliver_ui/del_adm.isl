# Admin Utility
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.prod
rcp -p nfmadm.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmadm.prod
echo
