# Messages

echo "find ..."
cd ..
find \
cfg \
-print | cpio -ov | \
compress > nfmmsgBLU.p
rcp -p nfmmsgBLU.p  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmmsgBLU.p

