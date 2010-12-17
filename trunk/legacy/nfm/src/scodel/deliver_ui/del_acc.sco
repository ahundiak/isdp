# Alpha Combined for SCO.

echo "find ..."

cd ../../
cd bin
mv Nfmalpha Nfmalpha_c
mv Nfmalphas Nfmalpha

cd ..

find \
/etc/rc2.d/S99nfm \
bin/Nfmalpha \
config/nfmd.conf \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov | compress  > nfmacc.prod 
rcp -p nfmacc.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui

rm nfmacc.prod

cd bin
mv Nfmalpha Nfmalphas
mv Nfmalpha_c Nfmalpha
 
echo
