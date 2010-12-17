# Documentation
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find doc \
-print | cpio -ov | compress > nfmdoc.sun
rcp -p nfmdoc.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmdoc.sun
