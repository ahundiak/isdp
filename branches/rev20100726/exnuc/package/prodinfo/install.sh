#============================================================
# install.sh
# 10-Nov-1997 14:37 SCW Added lib installation to Solaris platforms
# 30-Oct-1997 15:07 SCW Added libfpstub.so support
# 30-Oct-1997 15:07 SCW Changed default Irix INGRHOME
# 11-Feb-1997 13:34 SCW Added IRIX 6.X support.
# 01-Sep-1993 14:15 JWW Added Solaris delivery fixes(INGRHOME);
#                       removed DISKLESS support.
# 16-Jul-1993 10:15 JWW Added SunOS check for Solaris delivery.
# 17-Feb-1993 10:45 JWW Added Bspmath to product_data info.
# 11-Feb-1993 14:25 JWW Added dlhelper fixup near end of script.
# 10-Feb-1993 11:05 JWW Removed chmod & chown @ end of script.
# 08-Oct-1992 14:15 JWW Fixed for 2.2.0 SGI support
# 27-May-1992 10:15 JWW Fixed for 2.1.0,removed shlib fixed archlib.
# 18-Feb-1992 09:35 JWW Added Usel check for no selections.
# 27-Jan-1992 13:45 JWW Added "approximately" to prompts;misc cleanup
# 22-Jan-1992 14:10 JWW Fixed misc copy & moving problems
# 09-Dec-1991 13:35 JWW Changed getanswer prompts to (y/n/h)
# 19-Nov-1991 09:30 JWW Added BOM support
#============================================================
if [ -f /usr/tmp/BOM -a $VARIANT = "rt" ]
then
  BOM=y
  SVPRODNAME=$PRODNAME
  PRODNAME=MDEMBOM
  DEFAULTS=y
  EMSPATH=/usr/tmp
  getmsg () {
            grep $1 $EMSPATH/prompts.eng | cut -d' ' -f2- | tr -d "\""
            }
fi

#============================================================
# install.sh
#(FUNCTION NAME: getfsf
# ABSTRACT:
#   The purpose of this function is to determine the exact file system
#   name where a particular file is located.
#
# CALLING SEQUENCE:    getfsf( $1 )
#
#            where:
#                      $1 is a filename
# )
getfsf()
{
  if [ "$TARGET_OS" = "SunOS" ]
  then
     filesys=`df | cut -f6 -d" " | sed '/^\/$/d' `
  else
     filesys=`df | cut -f1 -d" " | sed '/^\/$/d' `
  fi
  filename=$1
  firchar=`echo $1 | sed 's/\(.\).*/\1/'`
  if [ "$firchar" != "/" ]
  then
    filename=$PWD/$filename
  fi

  fs="/`echo $filename | cut -f2 -d/`"

  for i in $filesys
  do
    if [ "$fs" = "$i" ]
    then
      echo $i
      return 0
    fi
  done
  echo "/"
  return 0
} # End of getfsf
#(FUNCTION NAME: update_pdataf
# ABSTRACT:
#   The purpose of this function is to add the Product entry to the
#   product_data file.
#
# CALLING SEQUENCE:
#
#       update_pdataf $PDkey I/EXNUC module Exnuc:Bspmath $fixdir
#       where:
#         $PDkey is the Product key (Exnuc)
#         The remaining entries for the product_data file
# )
update_pdataf()
{
PDataT=/usr/tmp/pdat$$
#
  if [ $# -lt 2 ]
  then
    echo "Product Key: \c"
    read IDname
    echo "Product Entry: \c"
    read IDentry
  else
    IDname="$1"
    shift
    IDentryT="$1 $2 $3"               # Save most of the IDentry
  fi

  Location="$4"                       # Get full location

  IDentry="$IDentryT $Location"       # Put the correct location w/ IDentry

  if [ -s "$PData" ]
  then
    sed "/^\"${IDname}\"/d" $PData >$PDataT
    cat $PDataT >$PData
    echo "\"${IDname}\" ${IDentry}" | sed 's/""/"/' >>$PData
    rm $PDataT
  else
    echo "\"${IDname}\" ${IDentry}" | sed 's/""/"/' >$PData
  fi
} # End of update_pdataf
#(FUNCTION NAME: calc_size
# ABSTRACT:
#   The purpose of this function is to determine the total size of the
#   list of numbers.
#
# CALLING SEQUENCE:   calc_size ( $1 )
#
#            where:
#                     $1 is list of numbers
# )
calc_size()
{
  echo $* | awk '{ for (i = NF; i > 0; --i) sum += $i } END { print sum }'
  return 0
} # End of calc_size
# END of Function Definitions

fixdir=$4
Usel=
UselTMP=
TMPSIZE=
TOT_SIZE=
PROCTYPE=
TARGET_OS=`uname -s`

case $TARGET_OS in
CLIX)
   export INGRHOME=${INGRHOME:-/usr/ip32}
   fixdir="/$(echo $fixdir | cut -f2 -d/)/$(echo $DELdir)"
   if [ -x /bin/inqcpuid ]
   then
      DEF_ARCH=`/bin/inqcpuid`
   else
      echo
      echo "/bin/inqcpuid is not found, Please load DELTOOLS"
      echo
      exit 1
   fi
   if [ "$BOM" = "y" ] # if BOM installation; default to processor type
   then
      REPLY=`getanswer "$(getmsg EMEXCPUTYPE)" "${DEF_ARCH}"`
   else                # else ask for user preference of processor type
      echo
      REPLY=`getanswer "What processor type do you want to deliver(C100 or C400)?" "${DEF_ARCH}"`
   fi
   case $REPLY in
   [Cc]100)
     CPUTYPE=c1
     ;;
   [Cc]300)
     CPUTYPE=c1
     ;;
   [Cc]400)
     CPUTYPE=c4
     ;;
   *)
     echo
     echo "Unknown processor type $REPLY"
     echo "Please try again entering a correct processor type (C100 or C400)"
     echo
     exit 1
     ;;
   esac
;; # End of CLIX
SunOS)
   OSver="$(uname -r | cut -c1-3)"
   case $OSver in
   4.1)
     export INGRHOME=${INGRHOME:-/usr/ip32}
     CPUTYPE="s4"
     ;;
   5.[0-9])
     export INGRHOME=${INGRHOME:-/opt/ingr}
     fixdir="$(echo $INGRHOME | cut -f1 -d:)/$(echo $DELdir | cut -f2 -d/ )"
     case `uname -m`
     in
       i86* )
         CPUTYPE="i5"
       ;;
       sun4* )
  	echo
        if [ "$BOM" = "y" ]
        then
            xgl=`getanswer "$(getmsg EMXGL)   (y/n/h)? " "n"`
        else
            while true
            do
              xgl=`getanswer \
                  "Install EXNUC which supports XGL display (y/n) ?" "n"`
              case "$xgl" in
                  y|n ) break;;
                  *) echo "\nInvalid. Try again\n" ;;
              esac
            done
        fi
	if [ "$xgl" = "y" ]
	then
         	CPUTYPE="s6"
	else
		CPUTYPE="s5"
	fi
       ;;
     esac
     ;;
   *)
     echo
     echo "Unsupported SunOS version $OSver"
     echo
     exit 1
     ;;
   esac
;; # End of SunOS
IRIX)
   OSver="$(uname -r | cut -c1)"
   case $OSver in
   5|6)
     export INGRHOME=${INGRHOME:-/opt/ingr}
     fixdir="$(echo $INGRHOME | cut -f1 -d:)/$(echo $DELdir | cut -f2 -d/ )"
     CPUTYPE="m5"
     ;;
   *)
     echo
     echo "Unsupported IRIX version $OSver"
     echo
     exit 1
     ;;
   esac
;; # End of IRIX
*)
   echo
   echo "Unknown TARGET Operation System \"$TARGET_OS\""
   echo
   exit 1
;;
esac  # End of TARGET_OS case

#
#	These are processor dependent.
#
eval archlibSize=\$${CPUTYPE}archlibSize
eval binSize=\$${CPUTYPE}binSize
eval binoptSize=\$${CPUTYPE}binoptSize
eval cfggenSize=\$${CPUTYPE}cfggenSize
eval clixdocSize=\$${CPUTYPE}clixdocSize
eval clixspecSize=\$${CPUTYPE}clixspecSize
eval exprodSize=\$${CPUTYPE}exprodSize
eval exnucSize=\$${CPUTYPE}exnucSize
eval incsunSize=\$${CPUTYPE}incsunSize
eval libSize=\$${CPUTYPE}libSize
eval libomSize=\$${CPUTYPE}libomSize

archlib=${CPUTYPE}archlib
bin=${CPUTYPE}bin
binopt=${CPUTYPE}binopt
cfggen=${CPUTYPE}cfggen
clixdoc=${CPUTYPE}clixdoc
clixspec=${CPUTYPE}clixspec
exprod=${CPUTYPE}exprod
exnuc=${CPUTYPE}exnuc
incsun=${CPUTYPE}incsun
lib=${CPUTYPE}lib
libom=${CPUTYPE}libom

#
#	These are processor independent.  They are made into variables
#	to allow the install script to consistently use $package when
#	refering to package names.
#
binsrc=binsrc
binoptsrc=binoptsrc
config=config
dir=dir
doc=doc
inc=inc
incppl=incppl
msgsrc=msgsrc
spec=spec

TMPDIR=${TMPDIR:-/usr/tmp}

locFS="/"`echo $fixdir | cut -f2 -d"/"`
PData=${INGRHOME}/product_data

echo
echo "${IDtitle} Version ${IDversion}"
echo

#  Begin logging all transactions.
logfile=$TMPDIR/log
>$logfile
echo  >>$logfile
echo "Installing ${IDtitle} Version ${IDversion} `date`" >>$logfile

# BEGIN PROMPT SECTION

  if [ "$VARIANT" = "rt" ]
  then
     case $TARGET_OS in
     CLIX)
        UselTMP="$bin $binoptsrc $config $cfggen $clixdoc $doc $inc"
        TMPSIZE="$binSize $binoptscrSize $configSize $cfggenSize $clixdocSize $docSize $incSize"
     ;;
     SunOS)
        # remove the shlib from SUN list
        UselTMP="$bin $binoptsrc $config $cfggen $lib $doc $inc $incsun"
        TMPSIZE="$binSize $binoptsrcSize $configSize $cfggenSize $libSize $docSize $incSize $incsunSize"
     ;;
     IRIX)
        UselTMP="$bin $binoptsrc $config $cfggen $doc $inc $incsun"
        TMPSIZE="$binSize $binoptsrcSize $configSize $cfggenSize $docSize $incSize $incsunSize"
     ;;
     esac
  fi

  if [ "$VARIANT" = "dp" ]
  then
     case $TARGET_OS in
     CLIX)
        UselTMP="$bin $binsrc $binoptsrc $config $cfggen $clixdoc $doc $exnuc $inc $lib $spec $exprod"
        TMPSIZE="$binSize $binsrcSize $binoptsrcSize $configSize $cfggenSize $clixdocSize  $docSize $exnucSize $incSize $libSize $specSize $exprodSize"
        if [ "$(echo $IDname | cut -c6 )" != "X" ]
        then
           UselTMP="$UselTMP $clixspec"
           TMPSIZE="$TMPSIZE $clixspecSize"
        fi
     ;;
     SunOS)
        UselTMP="$bin $binsrc $binoptsrc $config $cfggen $doc $exnuc $inc $lib $spec $incsun $exprod"
        TMPSIZE="$binSize $binsrcSize $binoptsrcSize $configSize $cfggenSize $docSize $exnucSize $incSize $libSize $specSize $incsunSize $exprodSize"
     ;;
     IRIX)
        UselTMP="$bin $binsrc $binoptsrc $config $cfggen $doc $exnuc $inc $lib $spec $incsun $exprod"
        TMPSIZE="$binSize $binsrcSize $binoptsrcSize $configSize $cfggenSize $docSize $exnucSize $incSize $libSize $specSize $incsunSize $exprodSize"
     ;;
     esac
  fi # End of VARIANT = dp

TMPSIZE=$(calc_size  $TMPSIZE)

if [ "$BOM" = "y" ]
then
  REPLY=`getanswer "$(getmsg EMBASE)   (y/n/h)? " "y"`
else
  echo
  echo "The standard $IDname requires approximately $TMPSIZE blocks on the $locFS file system."
  REPLY=`getanswer "Install the standard ${IDtitle} locally (y/n)" "y"`
fi
if [ "$REPLY" = "y" ]
then
	Usel="$Usel $UselTMP"
	TOT_SIZE="$TMPSIZE $TOT_SIZE"
fi

if [ "$VARIANT" = "dp" ]
then
    echo
    dp_dir=`getanswer "Enter DP product directory" "${fixdir}"`
    if test ! -d $dp_dir
    then
       if mkdir -p $dp_dir
       then
          fixdir=${dp_dir}
       else
          echo "${IDnumber} : ERROR : Unable to create $dp_dir."
          exit 1
       fi
    else
          fixdir=${dp_dir}
    fi
    locFS="/"`echo $fixdir | cut -f2 -d"/"`

    UselTMP="$archlib"
    TMPSIZE="$archlibSize"
    TMPSIZE=$(calc_size  $TMPSIZE)
    echo
    echo "The archives require approximately $TMPSIZE blocks on the $locFS file system."
    REPLY=`getanswer "Install archives in ${fixdir}" "y"`
    if [ "$REPLY" = "y" ]
    then
       Usel="$Usel $UselTMP"
       TOT_SIZE="$TMPSIZE $TOT_SIZE"
    fi

    UselTMP="$libom"
    TMPSIZE="$libomSize"
    echo
    echo "The libOM.a requires approximately $TMPSIZE blocks."
    echo "It is used to link OM executables outside of the EXNUC environment."
    REPLY=`getanswer "Install the libOM.a in ${fixdir} (y/n)" "n"`
    if [ "$REPLY" = "y" ]
    then
       Usel="$Usel $UselTMP"
       TOT_SIZE="$TMPSIZE $TOT_SIZE"
    fi

    # if DP then add in the PPL include files
    UselTMP="$incppl"
    TMPSIZE="$incpplSize"
    TMPSIZE=$(calc_size  $TMPSIZE)

    Usel="$Usel $UselTMP"
    TOT_SIZE="$TMPSIZE $TOT_SIZE"

fi  # End if "dp" ##########

if [ "$(echo $IDname | cut -c6)" != "X" ] # Skip if X
then
if [ "$CPUTYPE" = "i5" ]
then
   continue
elif [ "$TARGET_OS" = "CLIX" -o "$TARGET_OS" = "IRIX" -a "$VARIANT" = "dp" -o "$TARGET_OS" = "SunOS" -a "$VARIANT" = "dp" ]
then
   UselTMP="$binopt"
   TMPSIZE="$binoptSize"
   TMPSIZE=$(calc_size  $TMPSIZE)

   if [ "$BOM" = "y" ]
   then
      REPLY=`getanswer "$(getmsg EMEXTOOLS)   (y/n/h)? " "y"`
   else
      echo
      echo "The optional tools require approximately $TMPSIZE blocks on the $locFS file system."
      REPLY=`getanswer "Install the optional tools locally (y/n)" "y"`
   fi
   if [ "$REPLY" = "y" ]
   then
      Usel="$Usel $UselTMP"
      TOT_SIZE="$TMPSIZE $TOT_SIZE"
   fi
fi # End of if [ (TARGET_OS = CLIX) or (TARGET_OS = IRIX and dp) or (TARGET_OS = SunOS and dp )]
fi # End if [ "$(echo $IDname | cut -c6)" != "X" ] # Skip if X

if [ "$VARIANT" = "rt" ]
then
   UselTMP="$incppl"
   TMPSIZE="$incpplSize"
   TMPSIZE=$(calc_size  $TMPSIZE)

   if [ "$BOM" = "y" ]
   then
      REPLY=`getanswer "$(getmsg EMADVPPL)   (y/n/h)? " "y"`
   else
      echo
      echo "PPL development requires approximately $TMPSIZE blocks on the $locFS file system."
      REPLY=`getanswer "Install the PPL include files locally (y/n)" "n"`
   fi
   if [ "$REPLY" = "y" ]
   then
	  Usel="$Usel $UselTMP"
	  TOT_SIZE="$TMPSIZE $TOT_SIZE"
   fi
fi # End if "rt" ########

UselTMP="$msgsrc"
TMPSIZE="$msgsrcSize"
TMPSIZE=$(calc_size  $TMPSIZE)

if [ "$BOM" = "y" ]
then
  REPLY=`getanswer "$(getmsg EMMSGSRC)   (y/n/h)? " "y"`
else
  echo
  echo "The message source files require approximately $TMPSIZE blocks on the $locFS file system."
  REPLY=`getanswer "Install the message source files locally (y/n)" "y"`
fi
if [ "$REPLY" = "y" ]
then
	Usel="$Usel $UselTMP"
	TOT_SIZE="$TMPSIZE $TOT_SIZE"
fi

# END PROMPT SECTION

if [ "$Usel" != "" ]    # process elements in the select list
then                    # else load nothing if the select list is empty 
  if test ! -d $fixdir
  then
     if mkdir -p $fixdir
     then
        :
     else
        echo "${IDnumber} : ERROR : Unable to create $fixdir."
        exit 1
     fi
  fi

  if [ "$PREPROCESS" = "y" ]
  then
     retstatus=0
     exit $retstatus
  fi

# Inform the user that we're processing
  echo
  echo "Delivering ${IDname} to $fixdir ..."
  echo

  echo 1>>$logfile 2>&1
  echo "Delivering ${IDname} to $fixdir ..." 1>>$logfile 2>&1
  echo 1>>$logfile 2>&1

  space_needed=$(calc_size $TOT_SIZE)
    if Free -t $locFS $space_needed
    then
      :
    else
      echo "${IDnumber} : Insufficent space on $locFS."
      echo "${IDnumber} : $space_needed blocks are required."
      echo "${IDnumber} : Continue [y]? \c"
      read response
      response=${response:-"y"}
      if [ "$response" != "y" ]
      then
        exit 1
      fi
    fi

  cd $fixdir
  echo >>$logfile
  echo "Processing ish.p" >>$logfile 

  getfile ish.p | compress -d | cpio -imud 2>>$logfile
  if test $? != 0
  then
     echo "${IDnumber} : ERROR : getfile error: ish.p."
     exit 1
  fi

  for each_prodfile in $Usel
  do
    echo >>$logfile
    echo "Processing $each_prodfile" >>$logfile 

    getfile ${each_prodfile}.p | compress -d | cpio -imud 2>>$logfile
    if test $? != 0
    then
       echo "${IDnumber} : ERROR : getfile error: ${each_prodfile}.p."
       exit 1
    fi

    chmod 777 ${each_prodfile}.ish
    ./${each_prodfile}.ish 2>>$logfile
    if test $? != 0
    then
       echo "${IDnumber} : ERROR : Execution error: ${each_prodfile}.ish."
       exit 1
    fi
  done

# For DP put the README, remove.sh, & product.def into new directory
  if [ "$VARIANT" = "dp" ]
  then
     if test -f $locFS/tmp/$IDnumber/README
     then
        cp $locFS/tmp/$IDnumber/README      ${fixdir}
     fi
     if test -f $locFS/tmp/$IDnumber/remove.s*
     then
        cp $locFS/tmp/$IDnumber/remove.s*   ${fixdir}
     fi
     if test -f $locFS/tmp/$IDnumber/product.def
     then
        cp $locFS/tmp/$IDnumber/product.def ${fixdir}
     fi
     case $TARGET_OS in
     CLIX)
         cd lib/${CPUTYPE}00/
         for FILE in $(\ls *.a)
         do
             ln -s ${PWD}/${FILE} ${fixdir}/lib/${FILE}
         done
         cd -
         ;;
     esac
  fi # End if "dp" ##########

  if [ "$TARGET_OS" = "IRIX" ] # Fix up dlhelper on IRIX
  then
     if test -f /usr/bin/dlhelper
     then
        rm /usr/bin/dlhelper
     fi
     if test -f ${fixdir}/bin/dlhelper
     then
        chgrp sys  ${fixdir}/bin/dlhelper
        chown root ${fixdir}/bin/dlhelper
        echo "Linking: ${fixdir}/bin/dlhelper to /usr/bin"
        echo "Linking: ${fixdir}/bin/dlhelper to /usr/bin" 1>>$logfile 2>&1
        ln -s ${fixdir}/bin/dlhelper /usr/bin/dlhelper
     fi
  fi

# Check the last 2 characters of IDname for "DP"
  if [ "$(echo ${IDname} | awk '{print substr($0,length($0)-1,length($0))}')" = "DP" ]
  then
     # Remove the "DP" @ end of the IDname
     IDname=$(echo ${IDname} | awk '{print substr($0,1,length($0)-2)}')
  fi

# Put the entry into the product_data
  update_pdataf ${PDkey} I/${IDname} module ${PDkey}:Bspmath ${fixdir}

# Cleanup the $fixdir directory
  rm -f *.ish

  echo >>$logfile
  echo "Finished. $(date)" >>$logfile 
  mv $logfile ${fixdir}/log
else
  echo "Nothing selected $(date)" >>$logfile
fi # End of if [ "$Usel" != "" ] 

if [ "$TARGET_OS" = "SunOS" ] 
then
  rm ${INGRHOME}/lib/libfpstub.so
  ln -s ${fixdir}/lib/libfpstub.so ${INGRHOME}/lib/
fi

exit 0
