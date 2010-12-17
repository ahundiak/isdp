# Command Line Interface for SCO.

echo "find ..."

cd ../../
find \
bin/Nfmcli \
-print | cpio -ov | compress  > nfmcli.prod 
rcp -p nfmcli.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmcli.prod
echo
