# Alpha Requester
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../..
find \
bin/Nfmalpha \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov | compress > nfmalp.prod

rcp -p nfmalp.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmalp.prod
echo

