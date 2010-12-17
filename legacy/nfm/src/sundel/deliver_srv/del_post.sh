# Postinstall.sh
# Modified for Sun version - 30.11.93
#

echo "find ..."
find \
postinstall.sh \
-print | cpio -ov | \
compress > postinst.sun
rcp -p postinst.sun delserv@aec:/usr5/delserv/nfm/i_nfmsrv/postinst.sun
