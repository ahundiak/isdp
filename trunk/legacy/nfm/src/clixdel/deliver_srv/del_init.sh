# Initialize

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfminit \
bin/Nfmupdate \
bin/Nfmrdlupdate \
bin/NFMmonitor \
config/initial/ris3.0.dmp \
config/workflow \
-print | cpio -ov | compress > nfmini.p$1
rcp -p nfmini.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmini.p$1

echo

