# Help

echo "find ..."
cd /usr4/nfmsrc/03040014
find \
cfg/english/help/help_file.hc \
cfg/english/help/help_info \
-print | cpio -ov | compress > nfmhlpBLU.prod
rcp -p nfmhlpBLU.prod delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmhlpBLU.prod
rm nfmhlpBLU.sco
echo


