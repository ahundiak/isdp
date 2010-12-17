# Messages

echo "find ..."
cd /usr/nfmsrc/03040014
find \
cfg \
-print | cpio -ov | compress >  nfmmsgBLU.prod
rcp -p nfmmsgBLU.prod delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmmsgBLU.prod
