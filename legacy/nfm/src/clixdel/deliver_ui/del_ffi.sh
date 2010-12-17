# Forms UI

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmfi \
config/english/forms \
config/english/icons \
config/language \
config/english/menus \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | \
compress > nfmffi.p$1
rcp -p nfmffi.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmffi.p$1

