# Alpha Combined
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."
cd ../../bin
mv Nfmalpha Nfmalpha_c
mv Nfmalphas Nfmalpha
cd ..
find \
/etc/nfmd.conf \
bin/Nfmalpha \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov | \
compress > nfmacc.sun

rcp -p nfmacc.sun delserv@aec:/usr5/delserv/nfm/i_nfmui/nfmacc.sun

cd bin
mv Nfmalpha Nfmalphas
mv Nfmalpha_c Nfmalpha
echo
