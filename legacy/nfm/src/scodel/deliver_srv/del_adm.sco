# Administrator Utility

echo "find ..."
cd ../..
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.prod
rcp -p nfmadm.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmadm.prod
rm nfmadm.sco
echo


