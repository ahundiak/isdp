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
#
# Revision 1.1.1.1  2001/12/17 22:40:43  hans
# Initial import to CVS
#
# Revision 340.0  1997/05/28  16:07:00  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  23:14:53  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  22:47:30  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.6  1994/10/29  04:41:14  scott
# COMMENT : Added SUNZX platform 3.2 ports
#
# Revision 240.5  1994/08/13  16:43:32  model40
# COMMENT : upgrade for v3.1 / Intel Solaris port
#
# Revision 240.4  1993/10/30  01:18:51  model20
# COMMENT : Added code to copy hsplot.{stuff} to modeldp and modelsrc
#
# Revision 240.3  1993/10/12  16:59:19  scott
# COMMENT : Removed code for SunOS 4
#
# Revision 240.2  1993/09/17  13:57:55  scott
# COMMENT : Added support for the integration and delivery of a Sparc Solaris platform
#
# Revision 240.1  1993/09/16  13:15:04  scott
# COMMENT : Added special processing for the solaris
#
# Revision 240.1  1993/04/07  17:19:44  model20
# COMMENT : copy sgi seed file to MDTARG
#
# Revision 220.6  1993/03/20  21:34:30  model22
# COMMENT : add C400 condition to copy seed files - sunit
#
# Revision 220.5  1993/03/01  19:58:13  model22
# COMMENT : copy shared newprod files to proper name
#
# Revision 220.4  1993/02/23  16:54:42  model22
# COMMENT : copy ris, .u and seed files correctly
#
# Revision 220.3  1993/02/18  20:30:44  model22
# COMMENT : fixes for freeform and modularization
#
# Revision 220.2  1993/02/16  00:01:20  model22
# COMMENT : fixes for unit testing
#
# Revision 220.1  1993/02/14  21:24:24  tim
# COMMENT : changes to unit testing
#
#


verifyenv MDTARG MODEL CLIPPER SUN5 SUNZX SGI C400 ISL
if [ "$?" != "0" ]
then
  errrpt $0 "undefined environment variable"
fi


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
