# Bulkloader for SCO

echo "find ..."
cd ../../
find \
bin/Nfmbulk \
bin/BLUbulkload \
config/english/commands/bulk.dat \
-print |cpio -ov |compress >nfmblk.prod

rcp -p nfmblk.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmblk.prod
echo
