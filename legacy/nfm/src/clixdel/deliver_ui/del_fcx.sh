# Combined Forms - X

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ../bin
mv Nfmfix Nfmfi_cx
mv Nfmfisx Nfmfix
cd ..
find \
/etc/rc2.d/S99nfm \
/etc/nfmd.conf \
bin/Nfmfix \
config/english/icons \
config/english/menus \
config/english/forms \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | \
compress > nfmfcx.p$1
rcp -p nfmfcx.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmfcx.p$1


cd bin
mv Nfmfix Nfmfisx
mv Nfmfi_cx Nfmfix
echo
