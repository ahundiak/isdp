#
# Copyright Intergraph Corporation
#
# I/NFMSRV Product Installation
#
# Synopsis
#
#    install.sh <srcmedia> <node.usr.pass> <srcdir> <destdir> [takedefaults]
#

# Since I_NFMSRV can exist with a DESTDIR of /usrx/ip32/nfm,
# we must detect this and ask the user to re-enter with
# 'U' for update to force newprod to read ws_s.prods for 
# the correct DESTDIR.


RUNSERV=`ps -eaf | grep NFMserver | grep -v grep`
if [ "$RUNSERV" ]
 then
  echo "\n Error: NFMserver is running in this machine."
  echo "Unable to complete install.sco.\n"
  exit 3

fi

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
    if [ -f /usr/ip32/ingrconfig ]
    then
        line=""
        line=`grep -n "\#I_NFMSRV\#" /usr/ip32/ingrconfig`
        if [ "$line" != "" ]
        then
        # is $DESTDIR /usrx/ip32/nfm or /usrx/ip32/nfm/i_nfmsrv?
            temp=`echo $DESTDIR | cut -f5 -d"/"`
            if [ "$temp" = "" ]
            then
            # We have detected OLD I_NFMSRV directory format! Warn them and
            # remove current I_NFMSRV entry from 'ingrconfig'
                echo ""
                echo "You appear to have an old version of I_NFMSRV installed. \c"
                echo "Since the directory"
                echo "structure of I_NFMSRV has changed, you must install \c"
                echo "I_NFMSRV using the 'U'"
                echo "command in newprod (update with uppercase U) to force \c"
                echo "the new directory "
                echo "structure to be used.\n"

                # Remove old I/NFM entries in ingrconfig
                sed -e "/\#I_NFMSRV\#/D" /usr/ip32/ingrconfig > /usr/tmp/nfm.tmp
                mv /usr/tmp/nfm.tmp /usr/ip32/ingrconfig >/dev/null 2>&1

                exit 1

            fi
        fi
    fi
fi

UNIXDIR=$DESTDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

LOGFILE=${UNIXDIR}/log
cat /dev/null > $LOGFILE

# get file partition
fp=`echo $UNIXDIR | cut -f2 -d"/"`
UNIXDIR=/$fp/ip32/nfm

cd ${UNIXDIR}

RISVER="5.1"
Ini_Size=2500
Srv_Size=10000
Pcs_Size=5100
Adm_Size=4500
Cvt_Size=3800
Fls_Size=1700
Uti_Size=2000
Msg_Size=625

Srv_Size=`expr $Srv_Size + $Ini_Size + $Msg_Size`
Adm_Size=`expr $Adm_Size + $Msg_Size`
Cvt_Size=`expr $Cvt_Size + $Msg_Size`
Fls_Size=`expr $Fls_Size + $Uti_Size`

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data
TCPMSG="is NOT"

curnfmver=`grep SR0L094AA-0305A /usr/ip32/ingrconfig | cut -f4 -d"#"`

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

  set `df $checkDIR`
  Disk_Space=$4
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

echo "\nThis version of I/NFM is built on RIS ${RISVER} and is compatible"
echo "ONLY with RIS ${RISVER} or later. If you do not have RIS ${RISVER} or"
echo "later loaded on your server and environment machines, DO NOT download"
echo "this version of the I/NFM server software.  "
echo "\nThis version of the I/NFM server software represents major changes and"
echo "enhancements over previous versions. The I/NFM user interface software"
echo "is now delivered with I_NFMUI (SR0L095AA-0305A)."
echo "\nIt is recommended that you remove the product before upgrading. It is"
echo "imperative that all users review the README file that is delivered with"
echo "I/NFM before attempting to use the software.\n"

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
    contans=`getanswer "Do you wish to continue (y/n) ?" "n"`
    case "$contans" in
    [Nn]*)
        exit 1
        ;;
    *)
        ;;
    esac
fi

#
# Get responses to prompts
#

# initialize stuff
flsans=n
msgans=n
riswarn=y

#
#   Do you want the server software?
#
    cant_decide=1
    while test $cant_decide -eq 1
    do
    srvans=`getanswer "Install I/NFM Server software (y/n/h) ?" "y"`
        case "$srvans" in
        [Hh]*)
            echo "\nThe I/NFM Server software makes database \c"
            echo "queries and updates at the"
            echo "users request.  The I/NFM Server software \c"
            echo "requires approximately\n${Srv_Size} blocks.\nRIS \c"
            echo "must be installed before I/NFM can be initialized."
            echo "It is required to be installed on the I/NFM \c"
            echo "Server node.\n"
            ;;
        *)
            cant_decide=0
            if [ "$srvans" = "y" ]
            then
                flsans=y
                msgans=y
                riswarn=y
            fi
            ;;
        esac
    done


    dbasrvans=`getanswer "Install DBASRV (PC DBA/NFM Server) (y/n/h) ?" "y"`

            cant_decide=0
            if [ "$dbasrvans" = "y" ]
            then
                flsans=y
                msgans=y
                riswarn=y
            fi
#
#
#  Do you want the PC software?
#
    cant_decide=1
    while test $cant_decide -eq 1
    do
    pcsans=`getanswer "Install I/NFM PC software (y/n/h) ?" "n"`
        case "$pcsans" in
        [Hh]*)
            echo "\nThe I/NFM PC software contains the PC command line\c"
            echo " interface that is"
            echo "to be pushed to the PC and the PC server which runs \c"
            echo "on the I/NFM Server."
            echo "The PC software requires approximately \c"
            echo "${Pcs_Size} blocks.\n"
            ;;
        *)
            cant_decide=0
            if [ "$pcsans" = "y" ]
            then
                flsans=y
                riswarn=y
            fi
            ;;
        esac
    done


#
#  Do you want the Nfmadmin utility?
#    
    cant_decide=1
    while test $cant_decide -eq 1
    do
    admans=`getanswer "Install I/NFM Administrator Utility (y/n/h) ?" "y"`
        case "$admans" in
        [Hh]*)
            echo "\nThe I/NFM Administrator Utility can be used for \c"
            echo "creating various reports"
            echo "on an I/NFM database and for performing various \c"
            echo "maintenance tasks."
            echo "The Administrator Utility requires approximately\c"
            echo " ${Adm_Size} blocks."
            echo "It must be installed on an I/NFM server node.\n"
            ;;
        *)
            cant_decide=0
            if [ "$admans" = "y" ]
            then
                msgans=y
                flsans=y
                riswarn=y
            fi
            ;;
        esac
    done
    
#
#   If no other software has been requested, do you want the file server?
#
    if [ "$flsans" = "n" ]
    then
       cant_decide=1
       while test $cant_decide -eq 1
       do
           flsans=`getanswer "Install I/NFM File Server and Utility Software (y/n/h) ?" "y"`
           case "$flsans" in
           [Hh]*)
               echo "\nThe I/NFM File Server must reside on all \c"
               echo "machines that will \ncommunicate with I/NFM.  \c"
               echo "All network protocol software must be"
               echo "downloaded prior to the I/NFM Fileserver.  \c"
               echo "The I/NFM Fileserver requires \napproximately \c"
               echo "${Fls_Size} blocks.\n" 
                ;;
            *)
                cant_decide=0
                ;;
            esac
        done
    fi

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
        exit 0
fi

#
# Check for the presence of RIS and 'nfmadmin' login
#

if [ "$riswarn" = "y" ]
then
    RIS_Exists=`grep "RIS" /usr/ip32/ingrconfig`
    if [ "$RIS_Exists" = "" ]
    then 
      echo "WARNING !!!!"
      echo "RIS cannot be detected on this machine.  I/NFM will not"
      echo "initialize or run without RIS.  Please make sure that RIS"
      echo "has been downloaded to this machine."
    fi
    Login_Exists=`grep "nfmadmin" /etc/passwd`
    if [ "$Login_Exists" = "" ]
    then 
      echo "WARNING !!!!"
      echo "\"nfmadmin\" login cannot be detected on this machine.  I/NFM"
      echo "will not operate correctly on this machine without it.  Please"
      echo "create the \"nfmadmin\" account prior to using I/NFM."
    fi

fi

#
#  Now bring down the indicated software cpio files.
#
#  Load I/NFM Initialize.
#

echo " "
if [ "$srvans" = "y" ]
then
    Check_Space $UNIXDIR $Ini_Size "I/NFM Initialize Software"
    echo Installing I/NFM Initialize Software
    echo Installing I/NFM Initialize Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmini.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

echo " "
if [ "$dbasrvans" = "y" ]
then
    Check_Space $UNIXDIR $Dbasrv_Size "DBA/NFM Server Software"
    echo Installing DBA/NFM Server Software
    echo Installing DBA/NFM Serve Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile dbasrv.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    chmod +s ${UNIXDIR}/bin/dbasrv   >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load Server software
#

if [ "$srvans" = "y" ]
then
    Check_Space $UNIXDIR $Srv_Size "I/NFM Server Software"
    echo Installing I/NFM Server Software
    echo Installing I/NFM Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmsrv.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi


#
#  Load PC Software
#

if [ "$pcsans" = "y" ]
then
    Check_Space $UNIXDIR $Pcs_Size "I/NFM PC Software"
    echo Installing I/NFM PC Client and Server Software
    echo Installing I/NFM PC Client and Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmpcs.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
 fi


#
#  Load Separate Server Utilities
#

if [ "$admans" = "y" ]
then
    Check_Space $UNIXDIR $Adm_Size "I/NFM Administrator Utility"
    echo Installing I/NFM Administrator Utility
    echo Installing I/NFM Administrator Utility >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmadm.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load Message files
#

if [ "$msgans" = "y" ]
then
    Check_Space $UNIXDIR $Msg_Size "I/NFM Message Files"
    echo Installing I/NFM Message Files
    echo Installing I/NFM Message Files >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmmsg.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load I/NFM Fileserver and NFMdaemon
#

if [ "$flsans" = "y" ]
then
    Check_Space $UNIXDIR $Fls_Size "I/NFM File Server"
    if [ ! -d ${UNIXDIR}/utilities ]; then mkdir -p ${UNIXDIR}/utilities; fi
    if [ ! -d ${UNIXDIR}/utilities ]
    then echo Cannot create ${UNIXDIR}/utilities; exit 1; fi
    chmod 777 ${UNIXDIR}/utilities
#
#  Stop the I/NFM Daemon
#
    if [ -f /etc/init.d/nfm ] 
    then
        chmod +x /etc/init.d/nfm
        /etc/init.d/nfm stop_nfm; 
        unlink /etc/init.d/nfm; 
    fi

    echo Installing I/NFM File Server
    echo Installing I/NFM File Server  >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmfls.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    getfile nfmuti.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    ln /etc/rc2.d/S99nfm /etc/init.d/nfm
    ln /etc/rc2.d/S99nfm /etc/rc0.d/K99nfm

fi

#
#  Update server.dat file in inc directory, if it exists
#

if [ "$srvans" = "y" -o "$fccans" = "y" -o "$accans" = "y" ]
then
    INCDIR="/usr/ip32/inc/server.dat"
    if [ -f ${INCDIR} ]
    then
        server_line=`grep -n "NFMV_Server" /usr/ip32/inc/server.dat | \
           sed s/\ \ /\ /g | \
           cut -f1 -d":"`
        new_line="!1556!D!$UNIXDIR/bin/NFMV_Server XNS!nfmadmin!"
        if [ "$server_line" = "" ]
        then
           echo $new_line >> /usr/ip32/inc/server.dat
        else
           echo "${server_line}c\n$new_line\n.\nw" > /usr/tmp/nfm.tmp
           ed /usr/ip32/inc/server.dat < /usr/tmp/nfm.tmp  >/dev/null 2>&1
           rm /usr/tmp/nfm.tmp
        fi
    fi
fi

getfile nfmdoc.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1

#
# Get postinstall.prod
#
    cd ${UNIXDIR}/i_nfmsrv
    getfile postinst.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#
#  Make root the owner of the product.
#

find $UNIXDIR -exec chown root {} \;
find $UNIXDIR -exec chgrp sys {} \;

#
#  Start the I/NFM Daemon if necessary
#  Moved this to postinstall.sh. If installing on a partition
#  other that /usr, the link to /usr/ip32/nfm has not been made and 
#  /etc/init.d/nfm will not be able to find /usr/ip32/nfm/bin/NFMdaemon.
#

#if [ "$flsans" = "y" ] 
#then
#    /etc/init.d/nfm start_nfm;  
#fi

#
#  Run the Nfmupdate utility if necessary
#
echo " "
if [ "$srvans" = "y" ]
then
    ver=`echo $curnfmver | cut -f1 -d"."`
    if [ "$ver" = "03" ]
    then
        ver=`echo $curnfmver | cut -f2 -d"."`
        if [ "$ver" = "00" -o "$ver" = "01" ]
        then
            echo Current Version of I/NFM is $curnfmver
            echo Running I/NFM Update Utility
            echo Running I/NFM Update Utility  >>$LOGFILE 2>&1
            date >>$LOGFILE 2>&1
            /usr/ip32/nfm/bin/Nfmupdate -A -S
        fi
    fi
fi

#
#  Put the nfmd.conf file in the right place.
#

if [ -f ${UNIXDIR}/config/nfmd.conf ]
    then
    cp ${UNIXDIR}/config/nfmd.conf /etc
    fi

echo "\n<<<<<<<<<<<<<<<<<Important Warning>>>>>>>>>>>>>>>>>>>"
echo "\nIf you have RIS version 4.3 or lower,  you will"
echo "need to copy usrx/ip32/nfm/risutil/utl.msg"
echo "to /usrx/ip32/ris/riscli/config/english/messages prior"
echo "to running NFMinit.\n"

exit $retstatus

