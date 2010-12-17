# Initialize
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
bin/Nfminit \
bin/Nfmupdate \
bin/NFMmonitor \
config/initial/ris3.0.dmp \
config/workflow \
-print | cpio -ov | compress > nfmini.sun
rcp -p nfmini.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmini.sun
echo

