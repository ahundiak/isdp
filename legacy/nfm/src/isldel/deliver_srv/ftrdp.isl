#!/bin/sh

# Installation script added to products install.isl file to load 
# the I/FTR Libraries

export PATH=$PATH:$INGRHOME/bin

if (test ! -d $INGRHOME/tmp)
then
mkdir -p $INGRHOME/tmp 2>/dev/null
fi
chmod 777 $INGRHOME/tmp


if [ -f $TMPDIR/product.def ]
then
  . $TMPDIR/product.def
else
  IDname=junk
  IDnumber=SR05096
  IDtitle="I/Full Text Retrieval"
  DELsize=500
fi


UNIX_dir=`dirname $4`/ftrrt



chmod 777 $UNIX_dir
LOGFILE=$TMPDIR/log


if [ "$PREPROCESS" != "y" ]
then
  INTRO_MESSAGE="Installing ${IDtitle} (version ${IDversion}) in $DESTDIR"
else
  INTRO_MESSAGE="Preprocessing ${IDtitle} (version ${IDversion})"
  rm -f $LOGFILE
fi



REMOVEOLD="n"
oldftr1=`proddata +%p I_FTRRT`
oldftr2=`proddata +%p $IDname`
oftrv=`proddata +%v I_FTRRT`
echo "oldftr1=$oldftr1"
echo "oldftr2=$oldftr2"
if [ "$oldftr1" != "" ] ;then
  ftrfound=y
else
  ftrfound=n
fi
if [ "$oldftr2" != "" ] ;then
  if (test  -d $UNIX_dir)
  then
    ftrfound=y
  else
    ftrfound=n
  fi
else
  ftrfound=n
fi
if (test ! -d $UNIX_dir)
then
  mkdir -p $UNIX_dir 2>/dev/null
fi
if [ "$ftrfound" != "n" ]
then
  if [ "$5" = "-y" ]
  then
    REMOVEOLD="y"
  else
    REMOVEOLD="h"
    while [ "$REMOVEOLD" = "h" ]
    do
      REMOVEOLD=`getanswer -c "" "Remove version $oftrv of I_FTRRT ? (y/n/h)" y`
      REMOVEOLD=`echo $REMOVEOLD|tr 'YNH' 'ynh'`
      if [ "$REMOVEOLD" = "h" ]
      then
        echo "It is recommended that the currently installed product be removed"
        echo "before installing version $IDversion of $IDname. Installing a"
        echo "product on top of another may result in wasted disk space, especially"
        echo "if the installation options change."
      fi
    done
  fi
fi


if [ "$5" = "-y" ]
then
   UPDATESYSFILES="y"
else
   UPDATESYSFILES="h"
   while [ "$UPDATESYSFILES" = "h" ]
   do
     UPDATESYSFILES=`getanswer -c "" "Update system files ? (y/n/h)" y`
     UPDATESYSFILES=`echo $UPDATESYSFILES|tr 'YNH' 'ynh'`
     if [ "$UPDATESYSFILES" = "h" ]
     then
       echo "Some installation options require editing of system files such"
       echo "as /etc/inetd.conf and /etc/services. This can be done"
       echo "automatically by the installation script, or can be manually"
       echo "edited later using information provided in the README file."
     fi
   done

   if [ "$UPDATESYSFILES" != "y" ]
   then
     echo "See the README file for instructions on how to manually update"
     echo "the system files."
  fi
fi
export UPDATESYSFILES     # for the benefit of the remove script



INSTALLHELP="n"
FTSERVERPATH=""
FTSERVERUSER=""



if [ "$PREPROCESS" = "y" ]
then
  exit 0
fi


olddir1=`proddata +%p I_FTRRT`
olddir2=`proddata +%p $IDname`/../ftrrt
if [ "$olddir1" != "" ]
then
  cd $olddir1/bin;
  ./CLdeconfig.sh
  rc=$?
  cd -
  if [ $rc -ne 0 ]
  then
    echo "CLdeconfig.sh:$rc:I_FTRCL cannot be successfully DECONFIGURED"
    exit 1
  fi
else
 if [ "$olddir2" != "/../ftrrt" ]
 then
  cd $olddir2/bin;
  ./CLdeconfig.sh
  rc=$?
  cd -
  if [ $rc -ne 0 ]
  then
    echo "CLdeconfig.sh:$rc:I_FTRCL cannot be successfully DECONFIGURED"
    exit 1
  fi
 fi
fi



  mkdir -p $UNIX_dir 2>/dev/null

cd $UNIX_dir

  getfile client.ps4 | compress -d | cpio -imud 2>>$LOGFILE
  retstatus=$?
  if [ $retstatus -ne 0 ]
  then
    exit $retstatus
  fi




# If user selected to update the system files
if [ $UPDATESYSFILES = y ]
then
	# Run configure with appropriate command line options
	Nflag=
else
	Nflag=-n
fi

export IDnumber

(cd bin; ./CLconfig.sh $Nflag $FTSERVERPATH $FTSERVERUSER)

find . -print | xargs chown root
find . -print | xargs chgrp sys

exit 0
