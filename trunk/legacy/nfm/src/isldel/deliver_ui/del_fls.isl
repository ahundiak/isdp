# Fileserver and Daemon
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
/etc/nfmd.conf \
/etc/rc2.d/S99nfm \
bin/NFMfileserver \
bin/NFMdaemon \
bin/Nfmtcpip.sh \
bin/dattoclh \
-print | cpio -ov | compress > nfmfls.prod

rcp -p nfmfls.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmfls.prod
echo 


