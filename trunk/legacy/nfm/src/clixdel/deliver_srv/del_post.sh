# Messages

echo "find ..."
find \
postinstall.sh \
-print | cpio -ov | \
compress > postinst.prd
rcp -p postinst.prd  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/postinst.prd
/bin/rm postinst.prd

