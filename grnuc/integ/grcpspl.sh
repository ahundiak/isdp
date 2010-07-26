# grcpspl.sh - Copies special files from $GRNUC to $GRTARG.
#              NOTE : Need to verify if the find really gets all the extra
#                     non-generated makefiles to $GRTARG (like Makefile.sun)
#              NOTE : Need to evaluate if all these copies and links are needed.
#              NOTE : Some of these are CLIPPER and SUN specific
#
#
#    Usage       : grcpspl.sh
#    Inputs      : none
#    Outputs     : none
#    Return code : 1 - error
#
#$Log: grcpspl.sh,v $
#Revision 1.2  2002/02/05 20:19:07  hans
#*** empty log message ***
#
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:06:41  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:22  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.2  1995/11/29  16:06:17  scott
# COMMENT : Kludge to deliver Xforms fix within Grnuc
#
# Revision 320.1  1994/12/22  06:25:39  grnuc32
# COMMENT : Taken care of ver nums for 3.2
#
# Revision 320.0  1994/12/12  16:56:50  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.20  1994/11/21  20:22:13  scott
# COMMENT : Added profile configuration files for Intel Solaris platform
#
# Revision 240.19  1994/11/10  08:14:17  grnuc40
# COMMENT : Added userdata/SOLPC.Xdefault for ISL
#
# Revision 240.17  1994/08/18  22:22:38  grnuc40
# COMMENT : upgrade for Intel Solaris
#
# Revision 240.16  1994/02/07  16:06:27  dodd
# COMMENT : New userdata files supplied by Rick C. - JSD
#
# Revision 240.15  1994/01/08  00:42:34  grnuc20
# COMMENT : Copy cci.com from SOURCE to TARGET in GRNUC/bin - JSD
#
# Revision 240.14  1993/12/17  15:32:45  grnuc20
# COMMENT : Do not copy ppl/examples to TARGET, we package them from SOURCE - JSD
#
# Revision 240.13  1993/10/14  21:12:35  dodd
# COMMENT : Removing lg, gde, and gpipe references from Solaris and Irix5 builds - JSD
#
# Revision 240.12  1993/10/13  15:19:52  grnuc20
# COMMENT : Removed all references to SunOS 4
#
# Revision 240.11  1993/09/24  16:15:12  dodd
# COMMENT : Change from 2.4 to 3.0 and change from SunOS to Solaris - JSD
#
# Revision 240.10  1993/09/17  19:30:16  scott
# COMMENT : No change to file needed for file deletion
#
# Revision 240.9  1993/09/17  19:22:16  scott
# COMMENT : Added support for SPARC SOLARIS
#
# Revision 240.8  1993/05/05  19:56:19  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are defined.

verifyenv GRNUC GRTARG SUN CLIPPER ISL MASBLDLOG
if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables are NOT defined....Exiting..."
  exit 1
fi

necho "\n----------$UNIT_MESS copying special files ----------\n"


# These files are copied to all target machines (SUN, SGI, CLIPPER)

cd $GRNUC
find . \( -name Makefile -o -name make.ppl \) -print | cpio -dpvmu $GRTARG

# copy ppl .u files to TARGET directory
find . -name '*.u' -print | grep -v "ppl/examples" | cpio -dpvmu $GRTARG

# copy looking glass lgshell
if [ "${CLIPPER}" = "y" -o "${C400}" = "y" ]
then
  ncp $GRNUC/bin/lgshell $GRTARG/bin/.lgshell
fi

ALL_CP_LIST="ppl/bin/in_angle_list
             ppl/bin/in_chan_list
             ppl/bin/in_fast_list
             ppl/bin/in_ibeam_list
             ppl/bin/in_tee_list
             ppl/bin/mm_angle_list
             ppl/bin/mm_chan_list
             ppl/bin/mm_fast_list
             ppl/bin/mm_ibeam_list
             ppl/bin/mm_tee_list
             ppl/bin/updim.sh
             OMprodinit.C
             APP_main.C
             exvers.c
             bin/echopath
             bin/cci.com
             bin/cisetup"
             
for FILE in $ALL_CP_LIST
do
  ncp $GRNUC/$FILE $GRTARG/$FILE >> /usr2/tmp/$MASBLDLOG
done

# These files are copied only to the CLIPPER

if [ "$CLIPPER" = "y" -o "$C400" = "y" ]
then
  CLIP_CP_LIST="APP_main.C
                bin/HPGLOF.b
                bin/hpglof.db
                bin/igds2hpgl
                bin/ploterr.msg
                bin/igdserr.msg
                bin/stroke.msg
                bin/igds2hpgl.doc"

  for FILE in $CLIP_CP_LIST
  do
    ncp $GRNUC/$FILE $GRTARG/$FILE >> /usr2/tmp/$MASBLDLOG
  done

  ln $GRNUC/newprod/grnuc/install.sh $GRNUC/newprod/grnuc/install.sgi >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnuc/install.sh $GRNUC/newprod/grnuc/install.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnuc/install.sh $GRNUC/newprod/grnuc/install.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/install.sh $GRNUC/newprod/grnucdp/install.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/install.sh $GRNUC/newprod/grnucdp/install.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/install.sh $GRNUC/newprod/grnucdp/install.sgi >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/install.sh $GRNUC/newprod/grnucsrc/install.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/install.sh $GRNUC/newprod/grnucsrc/install.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/install.sh $GRNUC/newprod/grnucsrc/install.sgi >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnuc/remove.sh $GRNUC/newprod/grnuc/remove.sgi >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnuc/remove.sh $GRNUC/newprod/grnuc/remove.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnuc/remove.sh $GRNUC/newprod/grnuc/remove.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/remove.sh $GRNUC/newprod/grnucdp/remove.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/remove.sh $GRNUC/newprod/grnucdp/remove.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucdp/remove.sh $GRNUC/newprod/grnucdp/remove.sgi >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/remove.sh $GRNUC/newprod/grnucsrc/remove.ssl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/remove.sh $GRNUC/newprod/grnucsrc/remove.isl >> /usr2/tmp/$MASBLDLOG 2>&1
  ln $GRNUC/newprod/grnucsrc/remove.sh $GRNUC/newprod/grnucsrc/remove.sgi >> /usr2/tmp/$MASBLDLOG 2>&1

# copy uom_table.eng to uom_table on clipper - it is a Common file
  ncp $GRNUC/config/uom_table.eng $GRNUC/config/uom_table >> /usr2/tmp/$MASBLDLOG
fi

# These files are copied only to the SUN

if [ "${SUN5}" = "y" -o "${SUNZX}" = "y" ]
then
  SUN_LIST="env
            profile
            emsprofile
            xinitrc
            mwmrc"

  for FILE in $SUN_LIST
  do
    ncp $GRNUC/userdata/$FILE $GRTARG/userdata/.$FILE >> /usr2/tmp/$MASBLDLOG
  done

  ncp $GRNUC/userdata/SUN.README $GRTARG/userdata >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/SUN.Xdefaults $GRTARG/userdata/.Xdefaults >> /usr2/tmp/$MASBLDLOG

  # copy dynamically loadable X-forms fix to dload directory
  ncp $GRNUC/config/dload/init/gad_sym.ssl $GRTARG/config/dload/init/gad_sym.so >> /usr2/tmp/$MASBLDLOG
fi

if [ "${SGI}" = "y" ]
then
  ncp $GRNUC/userdata/SGI.Xdefaults $GRTARG/userdata/SGI.Xdefaults >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/SGI.README $GRTARG/userdata/SGI.README >> /usr2/tmp/$MASBLDLOG

  # copy dynamically loadable X-forms fix to dload directory
  ncp $GRNUC/config/dload/init/gad_sym.sgi $GRTARG/config/dload/init/gad_sym.so >> /usr2/tmp/$MASBLDLOG
fi

if [ "${ISL}" = "y" ]
then
  ncp $GRNUC/userdata/ISL.Xdefaults  $GRTARG/userdata/.Xdefaults  >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/ISL.env        $GRTARG/userdata/.env        >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/ISL.profile    $GRTARG/userdata/.profile    >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/ISL.emsprofile $GRTARG/userdata/.emsprofile >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/ISL.xinitrc    $GRTARG/userdata/.xinitrc    >> /usr2/tmp/$MASBLDLOG
  ncp $GRNUC/userdata/ISL.mwmrc      $GRTARG/userdata/.mwmrc      >> /usr2/tmp/$MASBLDLOG

  # copy dynamically loadable X-forms fix to dload directory
  # Does not exist anywhere anymore ?!?!?
  #ncp $GRNUC/config/dload/init/gad_sym.isl $GRTARG/config/dload/init/gad_sym.so >> /usr2/tmp/$MASBLDLOG
fi
