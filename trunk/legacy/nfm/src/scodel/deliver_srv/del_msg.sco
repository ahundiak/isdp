# Messages

echo "find ..."
cd ../..
find \
config/language \
config/english/messages \
config/nfs \
-print | cpio -ov | compress > nfmmsg.prod
rcp -p nfmmsg.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmmsg.prod
rm nfmmsg.sco
echo
