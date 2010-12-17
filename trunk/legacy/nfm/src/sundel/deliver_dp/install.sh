#
# Copyright Intergraph Corporation
#
# I/NFM Product Installation
#
# Synopsis
#
#    install.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$4

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log

RISVER="4.3"
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

  set `df $checkDIR`
  Disk_Space=$3

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

#
# Give message on importance of README
#

echo "\nWARNING --\n"
echo "This version of the I/NFM Development Platform is dependent on"
echo "RIS ${RISVER} and is compatible ONLY with RIS ${RISVER}.  If you"
echo "do not have RIS ${RISVER} loaded on your server and environment"
echo "machines, DO NOT download this version of I/NFM."
echo ""
#
# Determine what kind of machine we are on
#

case `inqcpuid`
in
  C300 | c300 )
    CPUID="c300"
    deliver_c100="y"
    deliver_c400="n"
    ;;
  C400 | c400 )
    CPUID="c400"
    deliver_c100="n"
    deliver_c400="y"
    ;;
  * )
    CPUID="c100"
    deliver_c100="y"
    deliver_c400="n"
    ;;
esac

#
# Get responses to prompts
#
if [ -d lib ]
then
    echo "\nThe I/NFM Development libraries are now delivered to"
    echo "nfmdp/libc100 and/or nfmdp/libc400."
    rmans=`getanswer "Do you want the old ./lib removed (y/n) ?" "y"`
    case "$rmans" in
    [yY]*)
        rm -r ./lib >>$LOGFILE 2>&1
        ;;
    esac
fi

    cant_decide=1
    while test $cant_decide -eq 1
    do
        c100ans=`getanswer "Install the C100 libraries (y/n) ?" "$deliver_c100"`
        case "$c100ans" in
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        c400ans=`getanswer "Install the C400 libraries (y/n) ?" "$deliver_c400"`
        case "$c400ans" in
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        incans=`getanswer "Install the I/NFM Include Files (y/n/h) ?" "y"`
        case "$incans" in
        [Hh]*)
            echo "\nThe I/NFM Development Platform requires \c"
            echo "several include files"
            echo "for structures, error definitions, etc.\n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        libans=`getanswer "Install the MEM, NET, and SQL Libraries (y/n/h) ?" "y"`
        case "$libans" in
        [Hh]*)
            echo "\nThe I/NFM Development Platform provides a set \c"
            echo "of memory, network,"
            echo "and structured query language tools.  These are \c"
            echo "essential when"
            echo "developing I/NFM server or requester executables.\n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        reqans=`getanswer "Install the I/NFM Requester Libraries (y/n/h) ?" "y"`
        case "$reqans" in
        [Hh]*)
            echo "\nThe I/NFM Requester Libraries are a set of \c"
            echo "functions that can"
            echo "communicate with the I/NFM Server on a \c"
            echo "client/server basis.\n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        serans=`getanswer "Install the I/NFM Server Libraries (y/n/h) ?" "n"`
        case "$serans" in
        [Hh]*)
            echo "\nThe I/NFM Server Libraries are a set of \c"
            echo "functions that can"
            echo "communicate directly with the I/NFM database.\n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

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
  getfile nfminc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
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
  if [ "$c100ans" = "y" ]
  then
      getfile nfmlib.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
  if [ "$c400ans" = "y" ]
  then
      getfile nfmlib.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
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
  if [ "$c100ans" = "y" ]
  then
      getfile nfmreq.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
  if [ "$c400ans" = "y" ]
  then
      getfile nfmreq.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
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
  if [ "$c100ans" = "y" ]
  then
      getfile nfmsrv.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
  if [ "$c400ans" = "y" ]
  then
      getfile nfmsrv.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
  fi
  AOK=$?
  if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

retstatus=$?

#
#  Make root the owner of the product.
#

find $UNIXDIR -exec chown root {} \;
find $UNIXDIR -exec chgrp sys {} \;

exit $retstatus
