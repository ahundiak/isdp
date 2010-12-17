# Utilities

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi


echo "find ..."
cd ../
find \
bin/Nfmutil \
bin/VAXutil \
bin/get_util.com \
bin/NFMV_Server \
-print | cpio -ov | compress > nfmuti.p$1
rcp -p nfmuti.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmuti.p$1

echo 
