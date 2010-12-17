# Administrator Utility

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.p$1
rcp -p nfmadm.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmadm.p$1

echo
