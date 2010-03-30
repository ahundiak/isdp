# NAME
#
#   deliver -- make and deliver a version of EMS/MODEL/GRNUC.
#
# SYNOPSIS
#
#   deliver20
#
#
################################################################################
#                                                                              #
# This file is the main driver for the build. It prompts the user for various  #
# information about different steps in the build, and gathers a bunch of other #
# information from files etc. and in the end, kicks off different shell scripts#
# based on the input above.                                                    #
#                                                                              #
# MUST HAVES:                                                                  #
#                                                                              #
# 1.  The interation machine MUST have the following writable directories:     #
#     /tmp, /usr/tmp, /usr2/tmp                                                #
#                                                                              #
# 2.  The integration login MUST have the following file in $HOME/integ:       #
#     "integ.env"                                                              #
#                                                                              #
#     This file is used to export all necessary variables for the build        #
#                                                                              #
# NOTE:                                                                        #
#     The net address of the system is required for exported display           #
#         The path for xterm on Solaris systems is $OPENWINHOME/bin            #
#         The path for winterm on IRIX systems is /usr/sbin                    #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
# Variables exported in this file are listed below. Keep the list uptodate.    #
#                                                                              #
#  LOGDIR  LOGFILE MAKEFILE PACKFILE                                           #
#                                                                              #
################################################################################


################################################################################
#                                                                              #
#  Make sure that ALL environment variables needed for the build are defined   #
#  If not, exit from script.                                                   #
#                                                                              #
################################################################################

checkvars.sh

if [ $? -ne 0 ]
then
  exit 1;
fi

# make sure all integration scripts are executable
if [ "$CLIPPER" = "y" ]
 then
   chmod +x $SOURCEDIR/integ/*
fi

# Make the firectory struture
grnuc_make_dirs.sh

################################################################################
#									       #
#  Run chgprot.sh -toself if $WORKDIR/PROTECTED exist                          #
#                                                                              #
################################################################################
 
if [ -f $TARGETDIR/PROTECTED ]
 then
   necho
   necho "Ownership of files is incorrect..changing ownership to $LOGNAME"
   chgprot.sh $TARGETDIR -toself > /tmp/bldlog 2>&1
   ncat /tmp/bldlog
   necho
fi
if [ "$CLIPPER" = "y" ]
 then
  if [ -f $SOURCEDIR/PROTECTED ]
   then
     necho
     necho "Ownership of files is incorrect..changing ownership to $LOGNAME"
     chgprot.sh $SOURCEDIR -toself > /tmp/bldlog 2>&1
     ncat /tmp/bldlog
     necho
  fi
fi


################################################################################
#									       #
#  Display varible that generates a TOTAL recompile                            #
#                                                                              #
################################################################################

necho "ENABLE_RECOMPILE: "$ENABLE_RECOMPILE
necho "UNIT_TEST: "$UNIT_TEST
necho "Deliver "$PROD

################################################################################
#                                                                              #
# Set up log directory and filename.                                           #
# (The version number of the log file increments by one for each re-run of     #
#  deliver20 during the build.)                                                #
#                                                                              #
################################################################################

if [ "${CLIPPER}" = "y" ]
 then
 if [ ! -f $SOURCEDIR/versinfo ]
  then
    echo '0' > $SOURCEDIR/versinfo
 fi
fi


OVERSNO=`cat $SOURCEDIR/versinfo`
#VERSNO=`expr $OVERSNO + 1`
if [ $OVERSNO -lt 10 ]
 then
   OVERSNO=0$OVERSNO
fi

echo "Building $PROD version 340.$OVERSNO"
#ead VERSNO; : ${VERSNO:=$OVERSNO}
export VERSNO=$OVERSNO

if [ ! -d ${HOME}/buildlog ]
 then
   mkdir -p ${HOME}/buildlog
fi

LOGDIR=buildlog/`echo $PROD | cut -c1-3 | tr "[A-Z]" "[a-z]"`340.${VERSNO}

if [ -d ${HOME}/${LOGDIR} ]
then
   OLOGNUM=`cat ${HOME}/${LOGDIR}/lognumber`
   LOGNUM=`expr ${OLOGNUM} + 1`
   echo "${LOGNUM}" > ${HOME}/${LOGDIR}/lognumber
else
   mkdir ${HOME}/${LOGDIR}
   echo "1" > ${HOME}/${LOGDIR}/lognumber
   LOGNUM=`cat ${HOME}/${LOGDIR}/lognumber`
fi

if [ $LOGNUM -lt 10 ]
 then
  LOGFILE=${HOME}/${LOGDIR}/buildlog0${LOGNUM}
else
  LOGFILE=${HOME}/${LOGDIR}/buildlog${LOGNUM}
fi

export LOGDIR LOGFILE

echo "Started $0 at `date` for 340.$VERSNO" >> $LOGFILE
echo "Building version 340.$VERSNO" >> $LOGFILE

#########################################################################
#									#
# 				Begin Prompts				#
#									#
#########################################################################


################################################################################
#									       #
# Get the integrators mail address to notify errors during the build           #
# (This info is a MUST)                                                        #
#                                                                              #
################################################################################

# Set in env file
# export BUILDER=ahundiak@ingr.com
# M=$BUILDER
# while [ "${M}" = "h" ]
# do
#  echo "Integrator Mail address  -> \c"
#  echo "Integrator Mail address  -> \c" >> $LOGFILE
#  read M;
#  if [ "${M}" = "h" ]
#  then
#   help.sh \
#   "This node will be notified via mail of errors during the build."
# else
#   if [ "${M}" = "" ]
#   then
#     echo "*** You MUST enter a mail address ***"
#     M=h
#   else
#     export BUILDER=$M
#   fi
# fi
# done


################################################################################
#									       #
# Check if fixes have to be retrieved from RCS for this build based on the     #
# fixes forms which have been submitted.                                       #
#                                                                              #
################################################################################

# if [ "${CLIPPER}" = "y" ]
# then
#   PREFIX=h
#   while [ "${PREFIX}" != "y" -a "${PREFIX}" != "n" ]
#   do
#     echo "Get fixes                                       [y] ---> \c"
#     read PREFIX; : ${PREFIX:=y}
#     if [ "${PREFIX}" = "h" ]
#     then
#       help.sh \
#       "This option retrieves source from the source management database based"\
#       "on the files listed in the fixes forms"
#     fi
#   done
# else
#   PREFIX=n
# fi


################################################################################
#									       #
# Get the Hplot libraries?                                                     #
#                                                                              #
################################################################################

HPLOTLIB=n


################################################################################
#									       #
# Recompile everything from scratch?                                           #
#                                                                              #
################################################################################

echo
if [ "${ENABLE_RECOMPILE}" = "on" ]
then
    RECOMPILE=h
    while [ "${RECOMPILE}" != "y" -a "${RECOMPILE}" != "n" ]
    do
        echo "Recompile all source?                           [y] ---> \c"
        echo "Recompile all source?                           [y] ---> " >> $LOGFILE
        read RECOMPILE; : ${RECOMPILE:=y}
        if [ "${RECOMPILE}" = "h" ]
        then
          help.sh \
          "This option will remove all source and object files. It will then "\
          "procede as if you responded yes to: 'Compile?', 'Get source from "\
          "RCS?', 'Compile using dependencies?', and 'Remake makefiles?'"
        fi
    done

    # Even if we started with a TOTAL RECOMPILE, we do NOT want to re-start
    # next time with a TOTAL RECOMPILE when we stop to fix any compile errors.
    # (If we WANT to, then the integrator has to re-export the ENABLE_RECOMPILE
    # variable to "on"). Therefore, here, we export the ENABLE_RECOMPILE
    # variable to "off"

    export ENABLE_RECOMPILE=off

    echo $RECOMPILE >> $LOGFILE
else
  RECOMPILE=n
fi


################################################################################
#									       #
# If "recompile everyting", then set related variables. Otherwise user is      #
# prompted for selective recompile of various directories.                     #
#                                                                              #
################################################################################

if [ "${RECOMPILE}" = "y" ]
then
   #
   #  Recompile everything, so don't ask for compilation details.
   #  ----------------------------------------------------------
   #
   RCS=y
   MSGBUILD=y
   COMPILE=y
   REMAKES=y
   RMCONFIG=y
   if [ "$PROD" = "MODEL" ]
    then
      DEPEND=y
   fi


   #
   #  Remake all makefiles from spec.m
   #  --------------------------------
   #
   if [ "${CLIPPER}" = "y" ] && [ "$PROD" = "MODEL" ]
   then
      necho "MODEL will run checkspec_all.sh"
      echo > $WORKDIR/newdelfiles
   fi


else


   #
   #  Compile? 
   #  --------
   #
   COMPILE=h
   while [ "${COMPILE}" != "y" -a "${COMPILE}" != "n" ]
   do
     echo "Compile?                                        [n] ---> \c"
     echo "Compile?                                        [n] ---> \c" >> $LOGFILE
     read COMPILE; : ${COMPILE:=n}
     if [ "${COMPILE}" = "h" ]
     then
     help.sh \
     "This option will initiate compilation. Any makefiles that are missing " \
     "will be generated. .mb files will be compiled, and slic files will be " \
     " 'slic'ed."
     fi
   done
   echo $COMPILE >> $LOGFILE

   if [ "${COMPILE}" = "y" ]
   then
     if [ "${PROD}" = "GRNUC" ] || [ "${PROD}" = "MODEL" ] 
     then 

       #
       # Remove (remake) config/commands?
       # -------------------------------
       #

       RMCONFIG=h
       while [ "${RMCONFIG}" != "y" -a "${RMCONFIG}" != "n" ]
       do
         echo '     Remove config/commands?                    [y] ---> \c' 
         echo '     Remove config/commands?                    [y] ---> \c' >> $LOGFILE
         read RMCONFIG; : ${RMCONFIG:=y}
       done

       echo $RMCONFIG >> $LOGFILE

       #
       # Remove (remake) PPL.
       # -------------------
       #

       RMPPLDOTE=h
       while [ "${RMPPLDOTE}" != "y" -a "${RMPPLDOTE}" != "n" ]
       do
         echo '     Remove ppl .e files?                       [y] ---> \c' 
         echo '     Remove ppl .e files?                       [y] ---> \c' >> $LOGFILE
         read RMPPLDOTE; : ${RMPPLDOTE:=y}
       done

       echo $RMPPLDOTE >> $LOGFILE

       #
       # Remake dictionary from scratch?
       # ------------------------------
       #

       if [ "${SUN}" = "y" ] || [ "${SGI}" = "y" ]
       then
	 REMAKEDICT=h
         while [ "${REMAKEDICT}" != "y" -a "${REMAKEDICT}" != "n" ]
         do
	   echo '     Total remake of dictionary files           [y] ---> \c' 
	   echo '     Total remake of dictionary files           [y] ---> \c' >> $LOGFILE
	   read REMAKEDICT; : ${REMAKEDICT:=y}
         done

         echo $REMAKEDICT >> $LOGFILE

       else

         REMAKEDICT=n   ## for CLIPPER

       fi

       #
       # Compile using dependencies? (MODEL only)
       # ---------------------------------------
       #

       if [ "$PROD" = "MODEL" ]
       then
         #DEPEND=h

         ## CURRENTLY SETTING $DEPEND to "y" UNCONDITIONALLY FOR DEPENDENCY MAKE

         DEPEND=y

         while [ "${DEPEND}" != "y" -a "${DEPEND}" != "n" ]
         do
           echo "     Compile using dependancies?                [y] ---> \c"
           echo "     Compile using dependancies?                [y] ---> \c" >> $LOGFILE
           read DEPEND; : ${DEPEND:=y}
           if [ "${DEPEND}" = "h" ]
           then
             help.sh \
             "This option causes compilation to take file dependencies into "\
             "consideration. (Specification files will always be compiled with"\
             " dependencies.)"
           fi
         done


         echo $DEPEND >> $LOGFILE
       fi

       #
       # Remake the makefiles?
       # --------------------
       #

       REMAKES=h
       while [ "${REMAKES}" != "y" -a "${REMAKES}" != "n" ]
       do
         echo "     Remake the makefiles?                      [${RMPPLDOTE}] ---> \c"
         echo "     Remake the makefiles?                      [${RMPPLDOTE}] ---> \c" >> $LOGFILE
         read REMAKES; : ${REMAKES:=$RMPPLDOTE}
         if [ "${REMAKES}" = "h" ]
         then
           help.sh \
           "This option will remove all makefiles, causing them to regenerate."
         fi
       done
       echo $REMAKES >> $LOGFILE
        
       if [ $PROD = MODEL ]
       then
         CHKSPEC=y
       fi

     else

       # if !GRNUC and !MODEL

       REMAKES=n
       RMCONFIG=n
       RMPPLDOTE=n

     fi  # if $PROD is GRNUC or MODEL

   fi # if $COMPILE is "y"

fi # if $RECOMPILE != "y"


################################################################################
#									       #
#  Link the image?                                                             #
#                                                                              #
################################################################################

if [ "${PROD}" = "MODEL" ] || [ "${PROD}" = "GRNUC" ] || [ "${PROD}" = "MDS" ] 
then
  echo
  LINK=h
  while [ "${LINK}" = "h" ]
  do
    echo "Link the image?                                 [y] ---> \c"
    echo "Link the image?                                 [y] ---> \c" >> $LOGFILE
    read LINK; : ${LINK:=y}
    if [ "${LINK}" = "h" ]
    then
      help.sh \
      "This option causes an image to be generated."
    fi
  done
else
  LINK="n"
fi
echo $LINK >> $LOGFILE

################################################################################
#									       #
# If MODEL make the EMS applications?                                          #
#                                                                              #
################################################################################


if [ "${PROD}" = "MODEL" ]
then
  echo
  EMSPACK=h
  while [ "${EMSPACK}" = "h" ]
  do
    echo "Build the ems applications?                     [y] ---> \c"
    echo "Build the ems applications?                     [y] ---> \c" >> $LOGFILE
    read EMSPACK; : ${EMSPACK:=y}
    if [ "${EMSPACK}" = "h" ]
    then
      help.sh \
      "This option causes the ems applications to be generated."
    fi
  done
else
  EMSPACK="n"
fi
echo $LINK >> $LOGFILE

################################################################################
#									       #
# Verify packaging?                                                            #
#                                                                              #
################################################################################

VERYPACK=h
while [ "${VERYPACK}" = "h" ]
do
  echo
  echo "Verify package definition file ?                [y] ---> \c"
  echo "Verify package definition file ?                [y] ---> \c" >> $LOGFILE
  read VERYPACK; : ${VERYPACK:=y}
  if [ "${VERYPACK}" = "h" ]
  then
    help.sh \
    "This option will list files that are in the package definition file, but"\
    "not on the integration platform."
  fi
done
echo $VERYPACK >> $LOGFILE


################################################################################
#									       #
# Update product.def & README?                                                 #
# (ONLY on the clipper).                                                       #
#                                                                              #
################################################################################

if [ "${CLIPPER}" = "y" ]
then
  echo 
  SUFFIX=h
  while [ "${SUFFIX}" = "h" ]
  do
    echo "Update product.def & README                     [y] ---> \c"
    echo "Update product.def & README                     [y] ---> \c" >> $LOGFILE
    read SUFFIX; : ${SUFFIX:=y} 
    if [ "${SUFFIX}" = "h" ]
    then
      help.sh \
      "This option will prepare the product.def and README for release."
    fi
  done
  echo $SUFFIX >> $LOGFILE
else
  SUFFIX="n"
fi


################################################################################
#									       #
#  Package the platform?                                                       #
#                                                                              #
#  (There are various options, where user can either use the default package   #
#   file, create a new one or use an existing one).                            #
#                                                                              #
################################################################################

PACK=h
while [ "${PACK}" = "h" ]
do
  echo
  echo "Package the $PROD platform ? <y/n/m/f>          [y] ---> \c"
  echo "Package the $PROD platform ? <y/n/m/f>          [y] ---> \c" >> $LOGFILE
  read PACK; : ${PACK:=y}
  if [ "${PACK}" = "h" ]
  then
    help.sh \
    "This option will package the source platform. Some manual steps must be"\
    "performed to make the new product available in newprod. These steps are"\
    "documented in the delivery document."
  fi
done
echo $PACK >> $LOGFILE

if [ "${PACK}" = "m" ]
then
   #
   # Create and use alternate package.def
   # ------------------------------------
   #
   echo "Modify package.def file "
   cp $SOURCEDIR/package.def $TARGETDIR/p.def
   ${EDITOR} $TARGETDIR/p.def
   PACKFILE=$TARGETDIR/p.def
   PACK=y
else 
   if [ "${PACK}" = "f" ]
   then
      #
      # Use existing alternate package.def
      # ----------------------------------
      #
      echo  
      echo "Input package file (absolute path must be used) ---> \c"
      echo "Input package file (absolute path must be used) ---> \c" >> $LOGFILE
      read PACKFILE; : ${PACKFILE:=y}
      echo $PACKFILE >> $LOGFILE
      PACK=y
   else
     if [ "${PACK}" = "y" ]
     then
       #
       # Use the default package.def
       # ---------------------------
       #
       PACKFILE=$SOURCEDIR/package.def
     fi
   fi
fi 

export PACKFILE


# Ask the user if he is executing from a remote system for disconnect
REMOTE=h
while [ "${REMOTE}" = "h" ]
   do
    echo
    echo "Terminate connection after starting the build?  [y] ---> \c"
    echo "Terminate connection after starting the build?  [y] ---> \c" >> $LOGFILE
  read REMOTE; : ${REMOTE:=y}
  if [ "${REMOTE}" = "h" ]
  then
    help.sh \
    "This option will execute the remainder of the script in a vterm/xterm"\
    "created on the integration system. This enables you to log out after"\
    "the target directory structure is rebuilt."
  fi
done
echo $REMOTE >> $LOGFILE

################################################################################
#									       #
#  START THE ACTUAL BUILD PROCESS.........                                     #
#                                                                              #
################################################################################

if [ "$UNIT_TEST" = "on" ]
 then
   necho "BUILD TEST BEGINING - You may not cntrl-c to insure original" 
   necho "the environment is necho preserved"
   trap "" 2
fi

################################################################################
#									       #
# Make the ver.c file                                                          #
#                                                                              #
################################################################################

# if $WORKDIR/NEWFILES exist report an error
if [ -s $WORKDIR/NEWFILES ] && [ "$CLIPPER" = "y" ]
 then
   errrpt $0 "NEW Files exist, they must be considered for packaging"
   necho
   cat $WORKDIR/NEWFILES | sort -u > /tmp/bldlog
   cp /tmp/bldlog $WORKDIR/NEWFILES
   errchk /tmp/bldlog "NEW Files exist, they must be considered for packaging"
   cp $WORKDIR/NEWFILES /tmp/bldlog
   ncat /tmp/bldlog
fi


################################################################################
#									       #
# Get the fixes forms                                                          #
#                                                                              #
################################################################################

if [ "$PREFIX" = "y" ]
then
  #
  #  Announce the RCS pull to the developers only if complete recompile
  #
  if [ "$RECOMPILE" = "y" ]
  then
    echo "The RCS pull for $PROD version 340.$VERSNO took place `date`" \
       | elm -s "RCS pull of $PROD" buildgrp@gator.b17d.ingr.com
  fi
  prefix.sh $WORKDIR 2>&1 | tee -a $LOGFILE
fi

# make sure all integration scripts are executable after fetching fixes
if [ "$CLIPPER" = "y" ]
 then
   chmod +x $SOURCEDIR/integ/*
fi

################################################################################
#									       #
#  Remove all object files if required.                                        #
#                                                                              #
################################################################################
if [ "${RECOMPILE}" = "y" ]
then
  if [ "${CLIPPER}" = "y" ]
  then
    grtouchmbs.sh
  fi
  if [ "${SOURCEDIR}" = "${TARGETDIR}" ]
  then
    # just remove the .o's from the platform
    rmobjects.sh
    if [ $? -ne 0 ]
    then
      errrpt $0 "Exit the build - rmobjects.sh failed"
      exit 1
    fi
  else
    # remove the entire TARGETDIR platform
    grclrtarg.sh
    if [ $? -ne 0 ]
    then
      errrpt $0 "Exit the build - grclrtarg.sh failed"
      exit 1
    fi
  fi
fi

################################################################################
#									       #
# Compile all files, removing old object files as required.                    #
#                                                                              #
# The steps here are:                                                          #
#                                                                              #
#   1. Remove files in config/commands directory if required                   #
#   2. Remove ".e" files if required                                           #
#   3. Remove intermdediate libraries (every time for a compile verification)  #
#   4. Remake dict directory if required                                       #
#   5. Link spec files to master spec directory (if recompile ONLY)            #
#   6. Remake the makefiles if required                                        #
#   7. Make all the source directories                                         #
#                                                                              #
################################################################################



#
# If COMPILE is true then perform needed operations to compile.
# -------------------------------------------------------------
#
if [ "${COMPILE}" = "y" ]
then

  #
  # Remove files in config/commands directory if required
  # -----------------------------------------------------
  #
  if [ "$RMCONFIG" = "y" ]
  then
    if [ "${CLIPPER}" = "y" ]
    then
      rmcfgcomm.sh
    fi
  fi

  # 
  # Remove ".e" files if required
  # -----------------------------
  # 
  if [ "${RECOMPILE}" = "n" ]
  then
    if [ "$RMPPLDOTE" = "y" ]
    then
      rmdote.sh
    fi
  fi

  #
  # Always rebuild the libraries (insure proper compilation)
  # --------------------------------------------------------
  #
  if [ "${RECOMPILE}" = "n" ]
  then
    rmintlib.sh
  fi

  #
  # Remake dict dictionary if required
  # ----------------------------------
  #
  if [ "${RECOMPILE}" = "n" ]
  then
    if [ "$REMAKEDICT" = "y" ]
    then
      remkdict.sh
    fi
  fi

  #
  # Link spec files to master spec directory (if recompile ONLY)
  # ------------------------------------------------------------
  #
  if [ "${RECOMPILE}" = "y" ] && [ "${CLIPPER}" = "y" ]
  then
    linkspec.sh
  fi

 
  #
  # Make message files
  # --------------------------------
  #

  if [ "$CLIPPER" = "y" -a "$PROD" != "MDS" ]
    then
      mkmsg.sh
  fi

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
