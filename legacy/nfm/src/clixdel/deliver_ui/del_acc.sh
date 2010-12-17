# Alpha Combined

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ../bin
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
compress > nfmacc.p$1

rcp -p nfmacc.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmacc.p$1

cd bin
mv Nfmalpha Nfmalphas
mv Nfmalpha_c Nfmalpha
echo
