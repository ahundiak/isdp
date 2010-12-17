# Workflow Generator

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmwff \
config/english/icons \
config/english/messages \
config/english/menus/workflow \
config/english/forms \
-print | cpio -ov | compress > nfmwfg.p$1
rcp -p nfmwfg.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmwfg.p$1

echo
