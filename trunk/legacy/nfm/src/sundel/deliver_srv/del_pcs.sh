# PC Server

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ../../
find \
bin/cnfm.exe \
bin/nfmpc.tak \
bin/ninstall.exe \
bin/PCserver \
bin/README \
-print | cpio -ov | \
compress | fmu dur.nfmprecert send - /usr2/ws_s/precert/i_nfmsrv/nfmpcs.p$1
