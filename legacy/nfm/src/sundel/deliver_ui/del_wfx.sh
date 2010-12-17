# Workflow Generator - X
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmwffx \
config/english/icons \
config/english/messages \
config/english/menus/workflow \
config/english/forms \
-print | cpio -ov | compress > nfmwfx.sun

rcp -p nfmwfx.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmwfx.sun
echo
