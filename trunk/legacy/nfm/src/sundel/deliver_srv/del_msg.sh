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
compress > nfmmsg.sun
rcp -p nfmmsg.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmmsg.sun
