# Initialize
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
bin/Nfminit \
bin/Nfmupdate \
bin/NFMmonitor \
bin/NFMdmdftr.sh \
config/initial/ris3.0.dmp \
config/workflow \
-print | cpio -ov | compress > nfmini.prod
rcp -p nfmini.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmini.prod
echo
/bin/rm nfmini.prod

