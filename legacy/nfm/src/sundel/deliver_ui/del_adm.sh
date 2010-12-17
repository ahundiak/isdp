# Admin Utility
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.sun
rcp -p nfmadm.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmadm.sun
echo
