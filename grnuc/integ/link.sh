# link.sh - This script links all the object libraries to make the executable
#
#    Usage       : link.sh
#    Inputs      : None
#    Output      : None
#    Return code : 1 - error
#
#$Log: link.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:11  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:50  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  16:57:16  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1993/12/09  19:21:47  dodd
# COMMENT : Changed canvas.cmp to cmdraster2.cmd, added RASTER message files to message_file, added RASTER class_defns stuff to class_defns, changed ownership and group to be like MODEL - JSD
#
# Revision 240.3  1993/10/06  14:06:50  dodd
# COMMENT : Added support for MODEL on C100/C400 simultaneous newprodability - JSD
#
# Revision 240.2  1993/09/28  13:42:35  grnuc20
# COMMENT : More changes to support simultaneous C100/C400 newprod - JSD
#
# Revision 240.1  1993/05/05  19:56:05  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#

# Make sure that ALL environment variables used in this script are defined.

verifyenv PROD TARGETDIR LOGFILE GRNUC CPUTYPE

if [ $? -ne 0 ]
then
  errrpt $0 "Some environment variables undefined"
  exit 1
fi

if [ "$PROD" = "MODEL" ]
then
    cd $TARGETDIR
    rm main.o
    rm APP_main.[co]

    echo "Getting APP_main.C via cpio -p"
    echo "Getting APP_main.C via cpio -p" >> $LOGFILE

    # Get APP_main.C from $GRNUC

    cd ${GRNUC}
    pwd
    /bin/ls APP_main.C | cpio -pvdmlu ${TARGETDIR}
    
    # check if file actually got copied over

    cd ${TARGETDIR}

    /bin/ls APP_main.C

    if [ $? -ne 0 ]
    then
      errrpt $0 "Could not copy APP_main.C from  ${GRNUC}"
      exit 1
    fi
fi

\ls ${TARGETDIR}/archlib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/archlib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/archlib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/archlib/*.[oa] ${TARGETDIR}/archlib/${CPUTYPE}
fi

\ls ${TARGETDIR}/lib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/lib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/lib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/lib/*.[oa] ${TARGETDIR}/lib/${CPUTYPE}
fi

\ls ${TARGETDIR}/src_lib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/src_lib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/src_lib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/src_lib/*.[oa] ${TARGETDIR}/src_lib/${CPUTYPE}
fi

\ls ${TARGETDIR}/ve/lib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/ve/lib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/ve/lib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/ve/lib/*.[oa] ${TARGETDIR}/ve/lib/${CPUTYPE}
fi

\ls ${TARGETDIR}/hsurf/lib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/hsurf/lib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/hsurf/lib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/hsurf/lib/*.[oa] ${TARGETDIR}/hsurf/lib/${CPUTYPE}
fi

\ls ${TARGETDIR}/src_nm/lib/*.[oa] >/dev/null 2>&1
if [ $? = 0 ]
then
  if [ ! -d ${TARGETDIR}/src_nm/lib/${CPUTYPE} ]
  then
    mkdir ${TARGETDIR}/src_nm/lib/${CPUTYPE}
  fi
  mv ${TARGETDIR}/src_nm/lib/*.[oa] ${TARGETDIR}/src_nm/lib/${CPUTYPE}
fi

echo "Linking the image:"
echo "Linking the image:" >> $LOGFILE

cd ${TARGETDIR}

${timex} make 2>&1 | tee -a $LOGFILE

