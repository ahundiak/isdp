# linkspec.sh - Removes spec files from master spec directory and re-links 
#               all spec files to it from the source directories.
#
#
#    Usage       : linkspec.sh
#    Inputs      : none
#    Output      : none
#    Return code : 1 - error
#                                                             
#$Log: linkspec.sh,v $
#Revision 1.1.1.1  2001/12/17 22:40:07  hans
#Initial import to CVS
#
# Revision 340.0  1997/05/27  22:07:12  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  20:22:51  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.1  1994/12/22  07:35:03  grnuc32
# COMMENT : Fix for .S files after total RCS pull
#
# Revision 320.0  1994/12/12  16:57:17  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.1  1993/05/05  19:56:06  tim
# COMMENT : corrected Log variable used to pull in RCS history with each checkin
#


# verify that all environment variables used in this script are actually 
# defined.

# verifyenv CLIPPER SOURCEDIR LOGFILE PROD
# if [ $? -ne 0 ]
# then
#    errrpt $0 "Some environment variables are NOT defined"
#    exit 1
# fi

# if [ "$CLIPPER" = "y" ]
# then

    #
    # Remove spec files before re-link from source spec directories
    # ------------------------------------------------------------
    #

    echo "Removing all .S files"
    echo "Removing all .S files" >> $LOGFILE

    cd ${SOURCEDIR}/spec

    # In the event of doing a total source pull from RCS,
    # the spec directory is empty.  We need at least one dummy
    # file to exist.   This seemed easier that testing of the
    # directory was empty.  As you will notice, this dummy
    # file will be removed.

    touch removeme.S
    chmod 777 *.S

    if [ $? -ne 0 ]
    then
     errrpt $0 "Could not change protection on spec file(s). Exiting.."
     exit 1
    fi

    for file in `\ls *.S`
    do
      nrm $file  # "nrm" removes file and verifies the remove
    done

    echo "Linking *.S to "${SOURCEDIR}"/spec"
    echo "Linking *.S to "${SOURCEDIR}"/spec" >> $LOGFILE


    #
    # Link MODEL spec files
    # ---------------------
    #

    if [ $PROD = MODEL ]
    then
      find ${SOURCEDIR}/src_* -type f -name '*.S' -depth -print \
                      -exec ln {} $SOURCEDIR/spec \;
      ln ${SOURCEDIR}/ve/src/spec/*.S $SOURCEDIR/spec
      ln ${SOURCEDIR}/hsurf/src/spec/*.S $SOURCEDIR/spec    
    fi

    #
    # Link GRNUC spec files
    # ---------------------
    #

    if [ $PROD = GRNUC ]
    then
      find ${SOURCEDIR}/src* -type f -name '*.S' -depth -print \
                      -exec ln {} ${SOURCEDIR}/spec \;
    fi

# fi
