# Messages

cp postinstal.sco postinstall.sh

echo "find ..."
find \
postinstall.sh \
-print | cpio -ov | compress > postinst.prod
rm postinstall.sh

rcp -p postinst.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv
rm postinst.prod
echo
