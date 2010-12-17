# PC Server

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/cnfm.exe \
bin/nfmpc.tak \
bin/ninstall.exe \
bin/PCserver \
bin/README \
-print | cpio -ov | \
compress > nfmpcs.p$1
rcp -p nfmpcs.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmpcs.p$1

