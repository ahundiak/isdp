#
# Copyright Intergraph Corporation
#
# I/NFM Product Installation
#
# Synopsis
#
#    share.sh <node.usr.pass> <VMSDIR> <UNIXDIR> <-y>
#

UNIXDIR=$DESTDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

cd ${UNIXDIR}

LOGFILE=${UNIXDIR}/log
cat /dev/null > $LOGFILE

Alp_Size=2473
For_Size=6486
Hlp_Size=814
Init_Size=2330
Lis_Size=1225
Srv_Size=13037
Uti_Size=1638

UI_Size=`expr $Alp_Size + $For_Size`
SV_Size=`expr $Init_Size + $Srv_Size`
LS_Size=`expr $Lis_Size + $Uti_Size`

pd=$ROOT/usr/ip32/product_data
pdtmp=$ROOT/usr/ip32/Product_Data
TCPMSG="is NOT"

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
# Get responses to prompts
#

if [ "$5" = "-y" ]
then
    srvans=y
    clians=y
    hlpans=n
    lisans=y
else
    cant_decide=1
    while test $cant_decide -eq 1
    do
        echo "Install the I/NFM Server Software (y/n/h) ? [n] \c"
        read srvans; : ${srvans:=n}
        srvans=`echo $srvans | cut -c1-1`
        case "$srvans" in
        [Hh]*)
            echo "\nThe I/NFM Initialize executable requires \c"
            echo "approximately ${Init_Size}"
            echo "blocks.  RIS must be installed before I/NFM \c"
            echo "can be initialized.\n"
            echo "The I/NFM Server executable requires approximately \c"
            echo "${Srv_Size} blocks."
            echo "It is required to be installed on the I/NFM Server \c"
            echo "node.\n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

    cant_decide=1
    while test $cant_decide -eq 1
    do
        echo "Install the I/NFM User Interface Software (y/n/h) ? [y] \c"
        read clians; : ${clians:=y}
        clians=`echo $clians | cut -c1-1`
        case "$clians" in
        [Hh]*)
            echo "\nThe I/NFM Alpha-Numeric Executable requires \c"
            echo "approximately ${Alp_Size}"
            echo "blocks.  \n"
#            echo "The I/NFM Forms User Interface requires \c"
#            echo "approximately ${For_Size}"
#            echo "blocks.  \n"
            ;;
        *)
            cant_decide=0
            ;;
        esac
    done

#    if [ "$clians" = "y" ]
#    then
#        cant_decide=1
#        while test $cant_decide -eq 1
#            do
#            echo "Install I/NFM Help (y/n/h) ? [n] \c"
#            read hlpans; : ${hlpans:=n}
#            hlpans=`echo $hlpans | cut -c1-1`
#            case "$hlpans" in
#                [Hh]*)
#                    echo "\nThe I/NFM forms interface has On-Line help \c"
#                    echo "available.  This will require"
#                    echo "an additional ${Hlp_Size} blocks.  \n"
#                    ;;
#                *)
#                    cant_decide=0
#                    ;;
#                esac
#            done
#        fi

    if [ "$srvans" = "n" -a "$clians" = "n" ]
    then
        cant_decide=1
        while test $cant_decide -eq 1
        do
            echo "Install the I/NFM Fileserver Software (y/n/h) ? [y] \c"
            read lisans; : ${lisans:=y}
            lisans=`echo $lisans | cut -c1-1`
            case "$lisans" in
            [Hh]*)
                echo "\nThe I/NFM Fileserver and I/NFM Daemon \c"
                echo "must reside on all"
                echo "machines that will communicate with I/NFM.  \n"
                echo "If the network protocol is TCP/IP, TCP/IP must"
                echo "be downloaded prior to the I/NFM Fileserver and \c"
                echo "Daemon.\n"
                echo "The I/NFM Fileserver and Daemon require \c"
                echo "approximately "
                echo "${LS_Size} blocks.  You Must Reboot to Utilize \c"
                echo "the I/NFM Fileserver and"
                echo "Daemon.\n"
                ;;
            *)
                cant_decide=0
                ;;
            esac
        done
    fi
fi

#
# Check for the presence of RIS
#

if [ "$srvans" = "y" ]
then
    RIS_Exists=`grep "RIS" $ROOT/usr/ip32/ingrconfig`
    if [ "$RIS_Exists" = "" ]
    then 
      echo "            ******************************************************"
      echo "            *                                                    *"
      echo "            *                     WARNING !!!!                   *"
      echo "            *                                                    *"
      echo "            *   RIS cannot be detected on this machine.  I/NFM   *"
      echo "            *   will not initialize or run without RIS.  Please  *"
      echo "            *   make sure that RIS has been downloaded to this   *"
      echo "            *   machine.                                         *"
      echo "            *                                                    *"
      echo "            ******************************************************"
    fi
fi

#
# Load I/NFM Initialize, server, and workflow generator 
#

echo " "
if [ "$srvans" = "y" ]
then
    lisans="y"
    Check_Space $UNIXDIR $SV_Size "I/NFM Server"

    echo Installing I/NFM Initialize Software
    echo Installing I/NFM Initialize Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfminit.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    echo Installing I/NFM Server Software
    echo Installing I/NFM Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmsrv.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    echo Installing I/NFM Workflow Generator Software
    echo Installing I/NFM Workflow Generator Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmwfg.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#
#  Install the "man" pages if sysvdoc is present
#
    if [ -d $ROOT/usr/ip32/sysvdoc/catman/i_man/man1 ]
    then 
        ln -s ${UNIXDIR}/config/english/man/* \
            $ROOT/usr/ip32/sysvdoc/catman/i_man/man1
        fi
#
#  If "vman" exits, update the "man" database.
#
    if [ -x $ROOT/usr/ip32/sysvdoc/newpage ]
    then 
        $ROOT/usr/ip32/sysvdoc/newpage ${UNIXDIR}/config/english/man/* 
        fi
    fi

#
# Load I/NFM User Interfaces
#

if [ "$clians" = "y" ]
then
    lisans="y"
    Check_Space $UNIXDIR $UI_Size "I/NFM User Interface"

    echo Installing I/NFM Alphanumeric Interface
    echo Installing I/NFM Alphanumeric Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmalp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#    echo Installing I/NFM Forms Interface 
#    echo Installing I/NFM Forms Interface >>$LOGFILE 2>&1
#    date >>$LOGFILE 2>&1
#    getfile nfmfor.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#    getfile nfmfor.p | cpio -ivmud >>$LOGFILE 2>&1
#    AOK=$?
#    if [ "$AOK" != "0" ] ; then exit $AOK; fi
#    fi

#if [ "$hlpans" = "y" ]
#then
#    Check_Space $UNIXDIR $Hlp_Size "I/NFM On-Line Help"

#    echo Installing I/NFM On-Line Help
#    echo Installing I/NFM On-Line Help >>$LOGFILE 2>&1
#    date >>$LOGFILE 2>&1
#    getfile nfmhlp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#    AOK=$?
#    if [ "$AOK" != "0" ] ; then exit $AOK; fi
#    fi

#
# Load I/NFM Listener and Utilities Client
#

if [ "$lisans" = "y" ]
then
    Check_Space $UNIXDIR $LS_Size "I/NFM Fileserver/Daemon"

    if [ ! -d ${UNIXDIR}/utilities ]; then mkdir -p ${UNIXDIR}/utilities; fi
    if [ ! -d ${UNIXDIR}/utilities ]
    then echo Cannot create ${UNIXDIR}/utilities; exit 1; fi

    echo Installing I/NFM Fileserver and Daemon 
    echo Installing I/NFM Fileserver and Daemon >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmlis.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#    getfile nfmuti.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#    AOK=$?
#    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#
#  Fix Looking Glass rules database so that user can use alpha interface.
#

    inqlgexist
    if [ $? -eq 0 ]
        then
        echo "APPEND_COMMANDS TAIL NUC_NFM_ALPHA" > $ROOT/nfm.ftc
        echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -#c/#f\"" >> $ROOT/nfm.ftc
        echo "COMMAND_DESCRIPTION \"Run I/NFM Alpha Interface\"">>$ROOT/nfm.ftc
        echo "END" >> $ROOT/nfm.ftc
        lgappcmds $ROOT/nfm.ftc
        fi
    fi

#
#  Make root the owner of the product.
#

find $UNIXDIR -exec chown root {} \;
find $UNIXDIR -exec chgrp sys {} \;

#

#getfile nfmupd.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
#AOK=$?
#if [ "$AOK" != "0" ]; then exit $AOK; fi
#chown root Update.*
#chgrp sys Update.*

#if [ "$srvans" = "y" -o "$clians" = "y" ]
#then
#    mv Update.srv ${ROOT}/var/ingr/nfm/Update.sh
#    rm Update.lis
#else
#  if [ "$lisans" = "y" ]
#    then
#       mv Update.lis ${ROOT}/var/ingr/nfm/Update.sh
#       rm Update.srv
#    fi
#fi

#
#  Link startup script to init.d.
#

if [ "$srvans" = "y" ]
then
    ln $ROOT/etc/rc2.d/S99nfm $ROOT/etc/init.d/nfm
    fi

exit $retstatus
