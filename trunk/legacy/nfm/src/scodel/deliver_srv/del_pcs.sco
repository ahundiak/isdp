# PC Server

echo "find ..."
cd ../../
find \
bin/cnfm.exe \
bin/nfmpc.tak \
bin/ninstall.exe \
bin/PCserver \
bin/README \
-print | cpio -ov | compress > nfmpcs.prod 
rcp -p nfmpcs.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv
rm nfmpcs.prod
echo
