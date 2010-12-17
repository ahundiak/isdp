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
-print | cpio -ov | compress > nfmffx.sun

rcp -p nfmffx.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmffx.sun
cd bin

