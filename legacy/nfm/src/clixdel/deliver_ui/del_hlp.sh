# Help

echo "find ..."
cd ..
find \
config/english/admin_help/HELPFILE \
config/english/user_help/HELPFILE \
-print | cpio -ov | \
compress > nfmhlp.p
rcp -p nfmhlp.p  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmhlp.p

echo


