# Postinstall.sh
# Modified for Sun version - 30.11.93
#
#for consistency .isl extension is maintained. But as newprod requires it with
# .sh extension only, we are copying it as postinstall.sh
# - srinivas 10th oct 95

cp postinstal.isl postinstall.sh

echo "find ..."
find \
postinstall.sh \
-print | cpio -ov | \
compress > postinst.prod
rcp -p postinst.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmsrv/postinst.prod
echo
/bin/rm postinst.prod
/bin/rm postinstall.sh
