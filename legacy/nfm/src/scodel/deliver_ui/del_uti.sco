# Utilities

#if (test $# = 0)
#       then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi


echo "find ..."
cd ../../
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.prod 
rcp -p nfmuti.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui/nfmuti.prod
rm nfmuti.prod
echo 
