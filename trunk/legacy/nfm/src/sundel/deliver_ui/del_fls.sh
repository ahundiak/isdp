# Fileserver and Daemon
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
/etc/nfmd.conf \
bin/NFMfileserver \
bin/NFMdaemon \
bin/Nfmtcpip.sh \
-print | cpio -ov | compress > nfmfls.sun

rcp -p nfmfls.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmfls.sun
echo 


