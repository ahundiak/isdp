#
# Copyright Intergraph Corporation
#
# I/NFM Product Installation
#
# Synopsis
#
#    install.isl <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

if [ -f /bin/mach ]
 then
  SUFF="isl"
else
  SUFF="p"
fi

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

RISVER="5.2"
NLib_Size=1417
RLib_Size=3623
SLib_Size=12375
Inc_Size=241

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

# Karen Tice
  if [ "${SUFF}" = "isl" ]
   then
    set `/usr/5bin/df $checkDIR`
    Disk_Space=${6} # changed from ${11} for INTELSOL , CN - 05070000
  else
#    set `df $checkDIR`
#    Disk_Space=$3
    set `df $checkDIR`
    Disk_Space=${11}
  fi

#  commented out by Karen Tice
#  set `df $checkDIR`
#  Disk_Space=$3

#  if [ $Disk_Space -lt $checkSIZE ]
#  then
#    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
#    echo ${checkDIR} has only ${Disk_Space} free blocks.
#    exit 1
#  fi
}

#
# Give message on importance of README
#

echo
echo "WARNING --"
echo
echo "This version of the I/NFM Development Platform is dependent on"
echo "RIS ${RISVER} and is compatible ONLY with RIS ${RISVER}.  If you"
echo "do not have RIS ${RISVER} loaded on your server and environment"
echo "machines, DO NOT download this version of I/NFM."
echo

#
# Get responses to prompts
#
if [ "$5" = "-y" ]
then
    libans=y
    reqans=y
    serans=n
    incans=y
else
    cant_decide=1
    while test $cant_decide -eq 1
    do
       incans=`getanswer "Install the I/NFM Include Files (y/n/h) ?" "y"`
       case "$incans" in
       [Hh]*)
            echo "The I/NFM Development Platform requires "
            echo "several include files"
            echo "for structures, error definitions, etc."
            ;;
        *)
	if [ "$incans" = "y" -o "$incans" = "n" ]
            then
                cant_decide=0
            fi

            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        libans=`getanswer "Install the MEM, NET, and SQL Libraries (y/n/h) ?" "y"`
        case "$libans" in
        [Hh]*)
            echo "The I/NFM Development Platform provides a set"
            echo "of memory, network,"
            echo "and structured query language tools.  These are "
            echo "essential when"
            echo "developing I/NFM server or requester executables."
            ;;
        *)
	if [ "$libans" = "y" -o "$libans" = "n" ]
            then
                cant_decide=0
            fi

            ;;
        esac
    done

     cant_decide=1
     while test $cant_decide -eq 1
     do
         reqans=`getanswer "Install the I/NFM Requester Libraries (y/n/h) ?" "y"`
         case "$reqans" in
         [Hh]*)
             echo "The I/NFM Requester Libraries are a set of"
             echo "functions that can"
             echo "communicate with the I/NFM Server on a "
             echo "client/server basis."
             ;;
         *)
	if [ "$reqans" = "y" -o "$reqans" = "n" ]
            then
                cant_decide=0
            fi

             ;;
         esac
     done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        serans=`getanswer "Install the I/NFM Server Libraries (y/n/h) ?" "y"`
        case "$serans" in
        [Hh]*)
            echo "The I/NFM Server Libraries are a set of "
            echo "functions that can"
            echo "communicate directly with the I/NFM database."
            ;;
        *)
	if [ "$serans" = "y" -o "$serans" = "n" ]
            then
                cant_decide=0
            fi

            ;;
        esac
    done
fi

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
        exit 0
fi
  
#
# Load I/NFM Include Files
#

echo " "
if [ "$incans" = "y" ]
then
  Check_Space $UNIXDIR $Inc_Size "I/NFM Include Files"
  echo Installing I/NFM Include Files
  echo Installing I/NFM Include Files >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1
  getfile nfminc.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load I/NFM Libraries
#

if [ "$libans" = "y" ]
then
  Check_Space $UNIXDIR $NLib_Size "I/NFM Libraries"
  echo Installing I/NFM Nucleus Libraries
  echo Installing I/NFM Nucleus Libraries >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1
  getfile nfmlib.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load I/NFM Requester Libraries
#

if [ "$reqans" = "y" ]
then
  Check_Space $UNIXDIR $RLib_Size "I/NFM Requester Libraries"
  echo Installing I/NFM Requester Libraries
  echo Installing I/NFM Requester Libraries >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1
  getfile nfmreq.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load I/NFM Server Libraries
#

if [ "$serans" = "y" ]
then
  Check_Space $UNIXDIR $SLib_Size "I/NFM Server Libraries"
  echo Installing I/NFM Server Libraries
  echo Installing I/NFM Server Libraries >>$LOGFILE 2>&1
  date >>$LOGFILE 2>&1
  getfile nfmsrv.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

retstatus=$?

#
#  Make root the owner of the product.
#
#  To ensure correct owner and group -- Jujare 28 FEB 1995
find $UNIXDIR -exec chgrp sys {} \;

find $UNIXDIR -exec chown root {} \;
#find $UNIXDIR -exec chgrp sys {} \;

exit $retstatus






