# PC Server


echo "find ..."
cd ../../
find \
bin/cnfm.exe \
bin/nfmpc.tak \
bin/ninstall.exe \
bin/PCserver \
bin/README \
-print | cpio -ov | \
compress | fmu frammetd.delserv.del123 send - /usr2/delserv/intelsol/i_nfmsrv/nfmpcs.isl
