# Administrator Utility
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.prod
rcp -p nfmadm.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmadm.prod
echo
/bin/rm nfmadm.prod
