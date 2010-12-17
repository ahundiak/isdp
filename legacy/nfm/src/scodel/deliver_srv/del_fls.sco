# Fileserver and Daemon

echo "find ..."
cd ../..
find \
/etc/rc2.d/S99nfm \
bin/NFMfileserver \
bin/NFMdaemon \
bin/dattoclh \
/etc/nfmd.conf \
-print | cpio -ov | compress > nfmfls.prod 
rcp -p nfmfls.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv/nfmfls.prod
rm nfmfls.sco
echo 
