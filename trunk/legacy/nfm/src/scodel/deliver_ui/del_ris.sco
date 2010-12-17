#RIS Utlitiy

echo "find ..."
cd ../../
find \
risutil \
-print | cpio -ov | compress > nfmrisut.prod
rcp -p nfmrisut.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmrisut.prod
echo
