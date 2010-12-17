# Help
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
config/english/admin_help/HELPFILE \
config/english/user_help/HELPFILE \
-print | cpio -ov | compress > nfmhlp.sun

rcp -p nfmhlp.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmhlp.sun
echo


