# NFM/DBA Server

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/dbasrv \
-print | cpio -ov | compress > nfmdbasrv.p$1
rcp -p nfmdbasrv.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmdbasrv.p$1
echo
