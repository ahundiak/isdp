# Forms UI - X
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmfix \
config/english/forms \
config/english/icons \
config/language \
config/english/menus \
config/english/admin_help/HELPINFO \
config/english/user_help/HELPINFO \
-print | cpio -ov | compress > nfmffx.prod
rcp -p nfmffx.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmffx.prod
/bin/rm nfmffx.prod
cd bin

