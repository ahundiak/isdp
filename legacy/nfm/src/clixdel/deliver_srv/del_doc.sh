echo "find ..."
cd ..
find doc \
-print | cpio -ov | \
compress > nfmdoc.p
rcp -p nfmdoc.p  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmdoc.p

