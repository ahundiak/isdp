# Administrator Utility
# Modified for Sun version - 30.11.93
#
echo "find ..."
cd ../../
find \
bin/Nfmadmin \
config/english/commands/env.dat \
-print | cpio -ov | compress > nfmadm.sun
rcp -p nfmadm.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/nfmadm.sun
echo
