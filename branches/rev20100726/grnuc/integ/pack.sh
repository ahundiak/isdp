# pack.sh - Does the final packaging of the build
#
#
#    Usage       : pack.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
# Revision 240.?  1993/09/02   scw
# COMMENT : Added Machine strip to logfile
#
# Revision 240.?  1993/04/28
# COMMENT : Change interogator to model24@model
#
# Log: pack.sh,v $
# Revision 240.1  1993/03/11  15:17:46  grnuc20
# COMMENT : incorporating release 2.2.0 fix
#
# Revision 220.3  1993/02/21  15:44:34  grnuc20
# COMMENT : changes to verify packaging
#


#make sure that all environment variables used here are actually defined

verifyenv CLIPPER LOGFILE TARGETDIR SOURCEDIR PACKFILE PROD

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variable(s) undefined. Existing..."
  exit 1
fi

MAILER=Mail

if [ "$SGI" = "y" ]
then
  echo "=== Sgi Irix ==================================================================" | tee -a $LOGFILE
fi

if [ "$ISL" = "y" ]
then
  echo "=== Intel Solaris =============================================================" | tee -a $LOGFILE
fi

if [ "$SUN5" = "y" ]
then
  echo "=== Sparc Solaris =============================================================" | tee -a $LOGFILE
fi

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  MAILER=elm
  echo "=== Clipper ==================================================================="  | tee -a $LOGFILE
fi

depend.sh 2>&1 | tee -a $LOGFILE

if [ "$CLIPPER" = "y" ]
then
  cd $SOURCEDIR
  export COMMON=y
# check for packaging regression
  chkpackreg.sh

  chgprot.sh $SOURCEDIR -toroot
  package.sh -n $PACKFILE 2>&1 | tee -a $LOGFILE
  chgprot.sh $SOURCEDIR -toself
  export COMMON=n
fi


cd $TARGETDIR

# check for packaging regression
chkpackreg.sh

chgprot.sh $TARGETDIR -toroot
# export CLIPPER=y if on the XVERSION since they package the same files
if [ "$XVERSION" = "y" ]
 then
   export CLIPPER=y
fi
package.sh -n $PACKFILE 2>&1 | tee -a $LOGFILE
if [ "$XVERSION" = "y" ]
 then
   export CLIPPER=n
fi

chgprot.sh $TARGETDIR -toself

$MAILER -s "$PROD Build Finished" $BUILDER < /dev/null
