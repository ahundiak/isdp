# Converter

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ../../
find \
bin/Nfmconvert \
config/convert \
-print | cpio -ov | compress | \
fmu dur.nfmprecert send - /usr2/ws_s/precert/i_nfmsrv/nfmcvt.p$1
echo
