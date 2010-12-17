# Forms UI - X

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmfix \
config/english/forms \
config/english/icons \
config/language \
config/english/menus \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | \
compress  > nfmffx.p$1
rcp -p nfmffx.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmffx.p$1

cd bin

