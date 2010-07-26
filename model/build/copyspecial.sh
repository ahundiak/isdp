# copyspecial.sh - copy files from $MODEL to $MDTARG for make and package
#                  purposes
#
#
#    Usage  : copyspecial.sh
#    Inputs : none
#    Output : files copied to MDTARG
#    Return : 0 - succeeds
#      Code   1 - fails
#
#    Tim McKee  02/13/93
# $Log: copyspecial.sh,v $
# Revision 1.2  2002/02/12 23:42:16  hans
# Updated to Solaris ; copy special seed-files ISL

cd $MODEL
necho "- - - copying special files to local - - -"

# copy files needed to make image
ncp $MODEL/Makefile $MDTARG
ncp $MODEL/OMprodinit.C $MDTARG
ncp $MODEL/exvers.c $MDTARG
ncp $MODEL/exvers.h $MDTARG


# copy .u files
cd $MODEL/ppl/cisrc

cd $MODEL
find src_lib/ris -print | cpio -pudvml $MDTARG
find  . -name '*.u' -print > /tmp/ppllst.$$
cat /tmp/ppllst.$$ | cpio -pudvml $MDTARG

# verify .u files made it
for file in `cat /tmp/ppllst.$$`
do
  ls $file > /tmp/ppl.ls.$$
  if [ ! -s /tmp/ppl.ls.$$ ]
  then
    errrpt $0 "$file did not get copied from $MODEL"
  fi
done
rm /tmp/ppllst.$$ /tmp/ppl.ls.$$

# copy seed files to MDTARG
necho "- - - copying seed files to local - - -"
if [ "$CLIPPER" = "y" ]
then
  ls /usr3/acct/seed/Ems/* > /tmp/c.$$
  for file in `cat /tmp/c.$$`
  do
    ncp $file $MDTARG/config
  done
fi

if [ "$C400" = "y" ]
then
  ls /MODELSRC/acct/seed/Ems/* > /tmp/c.$$
  for file in `cat /tmp/c.$$`
  do
    ncp $file $MDTARG/config
  done
fi

if [ "$SGI" = "y" ]
then
  ls /MODELSRC/acct/seed/Ems_sgi/* > /tmp/c.$$
  for file in `cat /tmp/c.$$`
  do
    ncp $file $MDTARG/config
  done
fi

if [ "$SUN5" = "y" -o "$SUNZX" = "y" ]
then
  ls /MODELSRC/acct/seed/Ems_ssl/* > /tmp/c.$$
  for file in `cat /tmp/c.$$`
  do
    ncp $file $MDTARG/config
  done
fi

if [ "$ISL" = "y" ]
then
#  ls /MODELSRC/acct/seed/Ems_isl/* > /tmp/c.$$
  ls $MODEL/config/seed* > /tmp/c.$$
  for file in `cat /tmp/c.$$`
  do
    ncp $file $MDTARG/config
  done
fi
rm /tmp/c.$$

if [ "${CLIPPER}" = "y" ]
then
  necho "- - - copying newprod files to proper name - - -"
  cd $MODEL
  ncp newprod/model/hsplot.install newprod/modeldp/hsplot.install
  ncp newprod/model/hsplot.assign  newprod/modeldp/hsplot.assign
  ncp newprod/model/hsplot.mls     newprod/modeldp/hsplot.mls
  ncp newprod/model/hsplot.install newprod/modelsrc/hsplot.install
  ncp newprod/model/hsplot.assign  newprod/modelsrc/hsplot.assign
  ncp newprod/model/hsplot.mls     newprod/modelsrc/hsplot.mls

  ncp newprod/model/install.sh newprod/model/install.isl
  ncp newprod/model/install.sh newprod/model/install.sgi
  ncp newprod/model/install.sh newprod/model/install.ssl
  ncp newprod/modeldp/install.sh newprod/modeldp/install.isl
  ncp newprod/modeldp/install.sh newprod/modeldp/install.sgi
  ncp newprod/modeldp/install.sh newprod/modeldp/install.ssl
  ncp newprod/modelsrc/install.sh newprod/modelsrc/install.isl
  ncp newprod/modelsrc/install.sh newprod/modelsrc/install.sgi
  ncp newprod/modelsrc/install.sh newprod/modelsrc/install.ssl
  ncp newprod/model/remove.sh newprod/model/remove.isl
  ncp newprod/model/remove.sh newprod/model/remove.sgi
  ncp newprod/model/remove.sh newprod/model/remove.ssl
  ncp newprod/modeldp/remove.sh newprod/modeldp/remove.isl
  ncp newprod/modeldp/remove.sh newprod/modeldp/remove.sgi
  ncp newprod/modeldp/remove.sh newprod/modeldp/remove.ssl
  ncp newprod/modelsrc/remove.sh newprod/modelsrc/remove.isl
  ncp newprod/modelsrc/remove.sh newprod/modelsrc/remove.sgi
  ncp newprod/modelsrc/remove.sh newprod/modelsrc/remove.ssl
fi
