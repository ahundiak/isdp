# Fileserver and Daemon
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
/etc/nfmd.conf \
bin/NFMfileserver \
bin/NFMdaemon \
bin/Nfmtcpip.sh \
-print | cpio -ov | compress > nfmfls.sun
rcp -p nfmfls.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmfls.sun
echo 


