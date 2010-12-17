# Help

echo "find ..."
cd ../../
find \
config/english/admin_help/HELPFILE \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPFILE \
config/english/user_help/HELPINFO \
-print | cpio -ov | compress > nfmhlp.prod 
rcp -p nfmhlp.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmhlp.prod
echo



