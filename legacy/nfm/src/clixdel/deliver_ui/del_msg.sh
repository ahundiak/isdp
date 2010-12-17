# Messages

echo "find ..."
cd ..
find \
config/language \
config/english/man \
config/english/messages \
config/nfs \
-print | cpio -ov | \
compress > nfmmsg.p
rcp -p nfmmsg.p  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmmsg.p


