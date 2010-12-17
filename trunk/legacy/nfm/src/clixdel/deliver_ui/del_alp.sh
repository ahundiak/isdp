# Alpha Requester

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
bin/Nfmalpha \
config/english/commands/alpha.dat \
config/english/commands/user.dat \
config/english/commands/pipcmdgrp.dat \
config/english/commands/pipcmds.dat \
-print | cpio -ov | \
compress > nfmalp.p$1
rcp -p nfmalp.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmalp.p$1

echo

