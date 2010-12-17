# Bulkloader

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmbulk \
bin/BLUbulkload \
bin/BLUconfig \
bin/BLUdataentry \
config/english/commands/bulk.dat \
-print | cpio -ov | compress > nfmblk.p$1
rcp -p nfmblk.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmblk.p$1

echo
