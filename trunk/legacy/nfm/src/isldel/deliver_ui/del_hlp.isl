# Help
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../../
find \
config/english/admin_help/HELPFILE \
config/english/user_help/HELPFILE \
-print | cpio -ov | compress > nfmhlp.prod

rcp -p nfmhlp.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmhlp.prod
echo


