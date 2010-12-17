# Post install script
# This script was adopted from the clipper version - Vasu 11.05.93

echo "find ..."

cp postinstal.sun postinstall.sh

find postinstall.sh -print | cpio -ov | compress > postinst.prod

/bin/rm -rf postinstall.sh

rcp -p postinst.prod  delserv@aec:/usr5/delserv/nfm/i_nfmui/

/bin/rm -rf postinst.prod
