# Initialize

echo "find ..."
cd ../..
find \
bin/Nfminit \
bin/Nfmupdate \
bin/NFMmonitor \
bin/NFMdmdftr.sh \
config/initial/ris3.0.dmp \
config/workflow \
risutil \
-print | cpio -ov | compress > nfmini.prod
rcp -p nfmini.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmini.prod
rm nfmini.sco
echo

