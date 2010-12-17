# Fileserver and Daemon
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
/etc/nfmd.conf \
/etc/rc2.d/S99nfm \
bin/NFMfileserver \
bin/NFMdaemon \
bin/dattoclh \
bin/Nfmtcpip.sh \
-print | cpio -ov | compress > nfmfls.prod
rcp -p nfmfls.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmfls.prod
echo 
/bin/rm nfmfls.prod
