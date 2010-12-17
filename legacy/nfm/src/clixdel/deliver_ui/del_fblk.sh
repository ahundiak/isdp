# Forms BLUBulkloader UI

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/DataEntry.exe \
bin/BLUbulkload \
forms \
cfg \
cfg/english/help/help_file.hc \
-print | cpio -ov | compress > nfmfblk.p$1
rcp -p nfmfblk.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmfblk.p$1
