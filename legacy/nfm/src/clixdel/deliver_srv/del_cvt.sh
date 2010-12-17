# Converter

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmconvert \
config/convert \
-print | cpio -ov | compress > nfmcvt.p$1
rcp -p nfmcvt.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmcvt.p$1

echo
