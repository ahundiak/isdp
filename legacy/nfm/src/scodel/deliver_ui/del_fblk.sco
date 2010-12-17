# Forms BLUBulkloader UI


echo "find ..."
cd ../..
find \
bin/BLUbulkload \
cfg/english/help/help_file.hc \
-print | cpio -ov | compress > nfmfblk.prod

rcp -p nfmfblk.prod nfmcert@moorer:/usr2/nfmcert/solaris/i_nfmui/nfmfblk.prod
rm nfmfblk.prod
echo
