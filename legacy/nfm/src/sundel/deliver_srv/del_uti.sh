# Utilities
# Modified for Sun version - 30.11.93
#

echo "find ..."
cd ../../
find \
bin/Nfmutil \
-print | cpio -ov | compress > nfmuti.sun
rcp -p nfmuti.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmuti.sun
echo 
