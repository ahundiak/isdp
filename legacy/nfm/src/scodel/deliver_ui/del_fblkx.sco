# Forms BLUbulkloader UI - X

#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
bin/DataEntryx.exe \
forms \
cfg \
cfg/english/help/help_file.hc \
cfg/english/help/help_info \
-print | cpio -ov | compress > nfmfblkx.prod
rcp -p nfmfblkx.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmfblkx.prod
rm nfmfblkx.prod
echo


