# Messages

echo "find ..."

cp postinstal.sco postinstall.sh

find \
postinstall.sh \
-print | cpio -ov | compress > postinst.prod
rm postinstall.sh

rcp -p postinst.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm postinst.prod
echo
