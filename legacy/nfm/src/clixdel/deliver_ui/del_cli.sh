# Command Line Interface

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find bin/Nfmcli \
-print | cpio -ov | \
compress > nfmcli.p$1
rcp -p nfmcli.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmcli.p$1
