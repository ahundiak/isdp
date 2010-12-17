# NFM Server

echo "find ..."
cd ../../
find \
/etc/rc2.d/S99nfm \
bin/NFMserver \
bin/NFMdmdftr.sh \
/etc/nfmd.conf \
-print | cpio -ov | compress > nfmsrv.prod
rcp -p nfmsrv.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmsrv
rm nfmsrv.prod
echo
