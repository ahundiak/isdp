# Alpha Requester for SCO

echo "find ..."
cd ../../
find \
bin/Nfmalpha \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov |compress >nfmalp.prod

rcp -p nfmalp.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmalp.prod
echo

