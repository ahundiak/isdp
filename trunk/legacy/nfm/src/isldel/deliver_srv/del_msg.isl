# Messages
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
config/language \
config/english/man \
config/english/messages \
config/nfs \
-print | cpio -ov | \
compress > nfmmsg.prod
rcp -p nfmmsg.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmmsg.prod
echo
/bin/rm nfmmsg.prod
