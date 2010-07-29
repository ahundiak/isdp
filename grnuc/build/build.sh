# Make the directory struture
grnuc_make_dirs.sh
linkspec.sh
mkmsg.sh
grmkcob.sh
grmkmk.sh
grmksrc.sh
grmkarch.sh

# make.all

exit 0

# export LOGDIR LOGFILE

# Rebuild everything including Model
RECOMPILE=n
RCS=y
MSGBUILD=y
COMPILE=y
REMAKES=y
RMCONFIG=y
DEPEND=y
LINK=y
EMSPACK=y
VERYPACK=n
PREFIX=n
SUFFIX=n
PACK=n
REMOTE=n
UNIT_TEST=off




#
# If COMPILE is true then perform needed operations to compile.
# -------------------------------------------------------------
#
if [ "${COMPILE}" = "y" ]
then

  #
  # Remake the makefiles if required 
  # --------------------------------
  #

  if [ "${REMAKES}" = "y" ]
  then
    # check include files
     
    chkinclude.sh >> $LOGFILE    # REDIRECT INSIDE THE SCRIPT ?????
     
    if [ "${RECOMPILE}" = "n" ]
    then

      # Remove makefiles 
    
      rmmake.sh
    fi

    # Relink spec files 

    linkspec.sh

  fi

  #
  # Make each directory
  # -------------------
  #

  echo "Compiling:"
  if [ "${DEPEND}" = "y" ]
  then
    export MAKEFILE=makefile.m
  else
    export MAKEFILE=makefile
  fi

  #  Call THE make script to beat all make scripts
  make.all

  ### CAN WE NOT HAVE A VARIABLE FOR "/usr2/tmp/$MASHBLDLOG" ????? ???????????


  cat /usr2/tmp/$MASBLDLOG >> $LOGFILE
  rm /usr2/tmp/$MASBLDLOG 


  echo "Finished making" >> $LOGFILE

fi ## from -> if [ "${COMPILE}" = "y" ]
exit 1



################################################################################
#									       #
# The image is linked here.                                                    #
#                                                                              #
################################################################################

if [ "${LINK}" = "y" ]
then
  link.sh
  necho "setup test environment, so we can test what we linked"
  $SOURCEDIR/integ/setup.test
fi

################################################################################
#									       #
# Make version number                                                          #
#                                                                              #
################################################################################
if [ "$PROD" != "MDS" ]
then
  cd $TARGETDIR
  cp $SOURCEDIR/*ver.c $TARGETDIR

  if [ "${SUN}" = "y" ]
  then
     makever.sh $TARGETDIR $PROD "03.04.00.$VERSNO" `date +"%d-%h-%y"`
  else
     makever.sh $TARGETDIR $PROD "03.04.00.$VERSNO" `date +"%d-%b-%Y"`
  fi
fi

################################################################################
#									       #
# Build ems applications and ems version numbers                               #
#                                                                              #
################################################################################

if [ "${EMSPACK}" = "y" ]
then
   makeemspack.sh
fi

  
################################################################################
#									       #
# Verify TARGETDIR with the snapshot from before the build                     #
#                                                                              #
################################################################################


if [ "${RECOMPILE}" = "y" ]
then
  if [ "${SOURCEDIR}" != "${TARGETDIR}" ]
  then
    grvertarg.sh
  fi
fi


################################################################################
#									       #
# Run suffix.sh (WHAT DOES THIS DO????)                                        #
#                                                                              #
################################################################################

if [ "$SUFFIX" = "y" ]
then
  cd ${SOURCEDIR}
  suffix.sh 2>&1 | tee -a $LOGFILE
fi


################################################################################
#									       #
#  Verify packaging                                                            #
#                                                                              #
################################################################################

if [ "$VERYPACK" = "y" ]
then
  cd $TARGETDIR
  verypack.sh $PACKFILE
fi


################################################################################
#									       #
# Do the packaging                                                             #
#                                                                              #
################################################################################

if [ "$PACK" = "y" ]
then 
  pack.sh
fi
