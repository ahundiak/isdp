# Converter 
# REQUIRED FOR CONVERTING NFM 2.0 TO NFM 3.x. NOT REQUIRED ANY MORE AS NFM 2.0
# TO NFM3.0 MIGRATION IS NOT REQUIRED CURRENTLY - PS 1 APR 96.

echo "find ..."
cd ../../
find \
bin/Nfmconvert \
config/convert \
-print | cpio -ov | compress | \
fmu frammetd.delserv.del123 send - /usr2/delserv/intelsol/i_nfmsrv/nfmcvt.isl
echo
/bin/rm nfmcvt.isl
