# Combined Forms - X

echo "find ..."
cd ../../
cd bin
mv Nfmfix Nfmfi_cx
mv Nfmfisx Nfmfix
cd ..
find \
/etc/nfmd.conf \
bin/Nfmfix \
config/english/icons \
config/english/menus \
config/english/forms \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | compress > nfmfcx.prod

cd bin
mv Nfmfix Nfmfisx
mv Nfmfi_cx Nfmfix
cd ..
rcp -p nfmfcx.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmfcx.prod
/bin/rm nfmfcx.prod
echo
