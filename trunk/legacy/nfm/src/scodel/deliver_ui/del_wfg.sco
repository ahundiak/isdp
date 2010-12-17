# Workflow Generator

#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
bin/Nfmwff \
config/english/icons \
config/english/messages \
config/english/menus/workflow \
config/english/forms \
-print | cpio -ov | compress > nfmwfg.prod 
rcp -p nfmwfg.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmwfg.prod
rm nfmwfg.prod
echo
