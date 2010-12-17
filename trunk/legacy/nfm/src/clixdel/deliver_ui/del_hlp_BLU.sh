# Help

echo "find ..."
cd ..
find \
cfg/english/help/help_file.hc \
cfg/english/help/help_info \
-print | cpio -ov | \
compress > nfmhlpBLU.p
rcp -p nfmhlpBLU.p  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmhlpBLU.p

echo


