# Command Line Interface
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find bin/Nfmcli \
-print | cpio -ov | compress >  nfmcli.sun

rcp -p nmfcli.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmcli.sun
