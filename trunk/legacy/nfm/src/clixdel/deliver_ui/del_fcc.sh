# Combined Forms

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ../bin
mv Nfmfi Nfmfi_c
mv Nfmfis Nfmfi
cd ..
find \
/etc/rc2.d/S99nfm \
/etc/nfmd.conf \
bin/Nfmfi \
config/english/icons \
config/english/menus \
config/english/forms \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | \
compress > nfmfcc.p$1
rcp -p nfmfcc.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmfcc.p$1


cd bin
mv Nfmfi Nfmfis
mv Nfmfi_c Nfmfi
echo
