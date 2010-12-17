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
-print | cpio -ov | compress > nfmfcx.sun
rcp -p nfmfcx.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmfcx.sun

cd bin
mv Nfmfix Nfmfisx
mv Nfmfi_cx Nfmfix
echo
