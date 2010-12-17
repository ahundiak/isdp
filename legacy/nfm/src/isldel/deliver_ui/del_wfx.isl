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
-print | cpio -ov | compress > nfmwfx.prod

rcp -p nfmwfx.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmwfx.prod
echo
