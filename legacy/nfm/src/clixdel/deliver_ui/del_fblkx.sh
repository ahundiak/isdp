# Forms BLUbulkloader UI - X

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/DataEntryx.exe \
bin/BLUbulkload \
forms \
cfg \
cfg/english/help/help_file.hc \
-print | cpio -ov | \
compress > nfmfblkx.p$1
rcp -p nfmfblkx.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmfblkx.p$1



