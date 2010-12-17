# Initialize

#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
bin/Nfminit \
bin/NFMdmdftr.sh \
bin/Nfmupdate \
config/initial/ris3.0.dmp \
config/workflow \
risutil \
-print | cpio -ov | compress > nfmini.prod 

rcp -p nfmini.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmini.prod
rm nfmini.prod
echo
