# Utilities

echo "find ..."
cd ../..
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.sun
rcp -p nfmuti.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmuti.sun
echo 
