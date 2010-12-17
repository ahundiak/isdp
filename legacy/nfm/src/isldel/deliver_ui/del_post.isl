# Post install script
# This script was adopted from the clipper version - Vasu 11.05.93

#for consistency .isl extensiion is maintained. But as newprod requires it with
# .sh extension only, we are copying it as postinstall.sh 
# - srinivas 10th oct 95

echo "find ..."
cp postinstal.isl postinstall.sh

find postinstall.sh -print | cpio -ov | compress > postinst.prod

rcp -p postinst.prod nfmy2k@redwood:/export/home/nfmy2k/intelsol/i_nfmui/postinst.prod

/bin/rm postinst.prod
/bin/rm postinstall.sh
