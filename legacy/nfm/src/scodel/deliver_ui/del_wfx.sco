# Workflow Generator - X

#if (test $# = 0)
#       then
#      echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
bin/Nfmwffx \
config/english/icons \
config/english/messages \
config/english/menus/workflow \
config/english/forms \
-print | cpio -ov | compress > nfmwfx.prod 
rcp -p nfmwfx.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmwfx.prod
rm nfmwfx.prod
echo
