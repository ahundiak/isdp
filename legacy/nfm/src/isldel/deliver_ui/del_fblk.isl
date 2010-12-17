# Forms BLUBulkloader UI


echo "find ..."
cd ../..
find \
bin/BLUbulkload \
config/english/messages/BLums.txt \
config/english/messages/BLums.msg \
cfg/english/help/help_file.hc \
-print | cpio -ov | compress > nfmfblk.prod

rcp -p nfmfblk.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmfblk.prod
echo
#cd bin

