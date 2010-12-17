# Forms UI - X
#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
bin/Nfmfix \
config/english/forms \
config/english/icons \
config/language \
config/english/menus \
-print | cpio -ov | compress > nfmffx.prod 
rcp -p nfmffx.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmffx.prod
echo

