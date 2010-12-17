# Documentation
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find doc \
-print | cpio -ov | compress > nfmdoc.prod
rcp -p nfmdoc.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/nfmdoc.prod
echo
/bin/rm nfmdoc.prod
