# Combined Forms - X

#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
cd bin
mv Nfmfix Nfmfi_cx
mv Nfmfisx Nfmfix
cd ..
find \
/etc/rc2.d/S99nfm \
bin/Nfmfix \
config/nfmd.conf \
config/english/icons \
config/english/menus \
config/english/forms \
-print | cpio -ov | compress > nfmfcx.prod
rcp -p nfmfcx.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmfcx.prod
rm nfmfcx.prod

cd bin
mv Nfmfix Nfmfisx
mv Nfmfi_cx Nfmfix
echo
