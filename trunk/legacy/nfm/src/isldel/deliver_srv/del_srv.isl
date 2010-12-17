# NFM Server
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
/etc/nfmd.conf \
bin/NFMserver \
-print | cpio -ov | compress >nfmsrv.prod
rcp -p nfmsrv.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmsrv.prod
echo
/bin/rm nfmsrv.prod
