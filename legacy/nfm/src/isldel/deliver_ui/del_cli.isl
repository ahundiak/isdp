# Command Line Interface
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find bin/Nfmcli \
-print | cpio -ov | compress >  nfmcli.prod

rcp -p nfmcli.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmcli.prod
