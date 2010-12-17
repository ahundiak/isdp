# NFM Server
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
/etc/nfmd.conf \
bin/NFMserver \
-print | cpio -ov | compress >nfmsrv.sun
rcp -p nfmsrv.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmsrv.sun
echo
