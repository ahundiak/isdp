# Alpha Combined
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../../bin
mv Nfmalpha Nfmalpha_c
mv Nfmalphas Nfmalpha
cd ..
find \
/etc/rc2.d/S99nfm \
/etc/nfmd.conf \
bin/Nfmalpha \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov | \
compress > nfmacc.prod
cd bin
mv Nfmalpha Nfmalphas
mv Nfmalpha_c Nfmalpha
cd ..
rcp -p nfmacc.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/nfmacc.prod
echo
