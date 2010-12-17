#
# Copyright Intergraph Corporation
#
# I/NFM Product Installation
#
# Synopsis
#
#    install.sh <srcmedia> <node.usr.scoass> <srcdir> <destdir> [takedefaults]
#

UNIXDIR=$DESTDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

LOGFILE=${UNIXDIR}/log
cat /dev/null > $LOGFILE

# get file partition for ris
RISDIR=`grep "RIS" /usr/ip32/ingrconfig`

# get file partition
fp=`echo $UNIXDIR | cut -f2 -d"/"`
UNIXDIR=/$fp/ip32/nfm

cd ${UNIXDIR}

RISVER="5.1"
Ini_Size=2500
Fcx_Size=12000
Acc_Size=9500
Wfx_Size=5000
Adm_Size=4500
Ffx_Size=5200
Alp_Size=3800
Cli_Size=1740
Blk_Size=6500
Fls_Size=1700
Uti_Size=2000
Dba_Size=10000
Msg_Size=625

Fcx_Size=`expr $Ini_Size + $Fcx_Size + $Msg_Size`
Acc_Size=`expr $Ini_Size + $Acc_Size + $Msg_Size`
Wfx_Size=`expr $Wfx_Size + $Msg_Size`
Adm_Size=`expr $Adm_Size + $Msg_Size`
Ffx_Size=`expr $Ffx_Size + $Msg_Size`
Alp_Size=`expr $Alp_Size + $Msg_Size`
Blk_Size=`expr $Blk_Size + $Msg_Size`
Fls_Size=`expr $Fls_Size + $Uti_Size`
Dba_Size=`expr $Dba_Size + $Msg_Size`

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data

curnfmver=`grep SR0L095AA-0305A /usr/ip32/ingrconfig | cut -f4 -d"#"`

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

Get_Size () { # Get image size
  COMBINED=$1
  UI=$2

  if [ "$COMBINED" = "y" ]
  then
      case $UI in
          XFORMS )
              SIZE=$Fcx_Size
              ;;
          ALPHA )
              SIZE=$Acc_Size
              ;;
          DBA )
              SIZE=$Dba_Size
              ;;
          * )
              ;;
      esac
  else
      case $UI in
          XFORMS )
              SIZE=$Ffx_Size
              ;;
          ALPHA )
              SIZE=$Alp_Size
              ;;
          * )
              ;;
      esac
  fi
}

#
# Give message on importance of README
#

echo "\nThis version of I/NFM is built on RIS ${RISVER} and is compatible"
echo "ONLY with RIS ${RISVER} or later. If you do not have RIS ${RISVER} or"
echo "later loaded on your server and environment machines, DO NOT download"
echo "this version of the I/NFM software.  "
echo "\nThis version of the I/NFM user interface software represents major"
echo "changes and enhancements over previous versions. The I/NFM server soft-"
echo "ware is now delivered with I_NFMSRV (SR0L094AA-0305A)."
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

#    combinedans => Combined Client-Server Architecture
#    tradans  => Traditional Client-Server Architecture
#    xformsans => X Forms Software
#    alphaans => Alpha Software
#    xworkflans => X Workflow Interface (Nfmwff)
#    admans  => Administrator Utility (Nfmadmin)
#    blkans  => Bulkloaders (Nfmbulk)
#    flsans  => File server and daemon (NFMfileserver/NFMdaemon)
#    msgans  => Messages configuration
#    dbaserans => Dba Server
#    riswarn => RIS version warning

# initialize stuff
flsans=n
msgans=n
riswarn=y

#
#   Do you want to bring down the combined client-server architecture?
#
if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
    echo "\nThe I/NFM User Interface software can operate in one of two modes."
    echo "The combined client/server images have the NFMserver software"
    echo "integrated with the client interface software giving the ability"
    echo "to operate as a dedicated I/NFM server. The traditional client"
    echo "software communicates remotely with an NFMserver process.\n"
fi

    cant_decide=1
    while test $cant_decide -eq 1
    do
    combinedans=`getanswer "Install I/NFM Combined Client-Server Architecture software (y/n/h) ?" "y"`
        case "$combinedans" in
        [Hh]*)
            echo "\nThe I/NFM Combined Client-Server software is a \c"
            echo "standalone image that gives"
            echo "any I/NFM client workstation the ability to operate \c"
            echo "as a dedicated I/NFM \nserver.  \n"
            ;;
        *)
            cant_decide=0
            if [ "$combinedans" = "y" ]
            then
                ARCH="Combined Client-Server"
                tradans=n
                flsans=y
                msgans=y
                riswarn=y
            fi
            ;;
        esac
    done

    if [ "$combinedans" = "n" ]
    then
#
#   Do you want to bring down the traditional client software?
#
        cant_decide=1
        while test $cant_decide -eq 1
        do
        tradans=`getanswer "Install I/NFM Traditional Client software (y/n/h) ?" "y"`
            case "$tradans" in
            [Hh]*)
                echo "\nThe I/NFM Traditional Client software are \c"
                echo "the standalone requester images that communicate"
                echo "with an I/NFM server process remotely. \c"
                ;;
            *)
                cant_decide=0
                if [ "$tradans" = "y" ]
                then
                    ARCH="Client"
                    combinedans=n
                    flsans=y
                    msgans=y
                    riswarn=y
                fi
                ;;
            esac
        done
    fi  #combinedans = n

    if  [ "$combinedans" = "y" -o "$tradans" = "y" ]
    then
#
#   Do you want to bring down Forms, Alpha, Cli, Wff?
#
        cant_decide=1
        while test $cant_decide -eq 1
        do
        xformsans=`getanswer "Install I/NFM X/Forms ${ARCH} software (y/n/h) ?" "n"`
            case "$xformsans" in
            [Hh]*)
                Get_Size $combinedans XFORMS
                echo "\nThe I/NFM X/Forms ${ARCH} software is a \c"
                echo "XWindows graphic interface of I/NFM.\n"
                echo "The I/NFM X/Forms ${ARCH} software \c"
                echo "requires approximately\n${SIZE} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$xformsans" = "y" ]
                then
                    flsans=y
                    msgans=y
                    riswarn=y
                fi
                ;;
            esac
        done

#
#   Do you want to bring down the CLI user interface software?
#
        cant_decide=1
        while test $cant_decide -eq 1
        do
        clians=`getanswer "Install I/NFM Command Line User Interface (y/n/h) ?" "y"`
            case "$clians" in
            [Hh]*)
                echo "\nThe I/NFM Command Line Interface is a simple \c"
                echo "method of invoking I/NFM"
                echo "commands without a menu driven interface.  \c"
                echo "The Command Line Interface\nrequires \c"
                echo "approximately ${Cli_Size} blocks.  \n"
                ;;
            *)
                cant_decide=0
                if [ "$clians" = "y" ]
                then
                    flsans=y
                    msgans=y
                fi
                ;;
            esac
        done

        cant_decide=1 
        while test $cant_decide -eq 1
        do
        alphaans=`getanswer "Install I/NFM Alphanumeric ${ARCH} software (y/n/h) ?" "y"`
            case "$alphaans" in
            [Hh]*)
                Get_Size $combinedans ALPHA
                echo "\nThe I/NFM Alphanumeric ${ARCH} software is a \c"
                echo "curses-based"
                echo "interface of I/NFM.\n"
                echo "The Alphanumeric ${ARCH} software \c"
                echo "requires approximately\n${SIZE} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$alphaans" = "y" ]
                then
                    flsans=y
                    msgans=y
                    riswarn=y
                fi
                ;;
            esac
        done

        cant_decide=1
        while test $cant_decide -eq 1
        do
        xworkflans=`getanswer "Install I/NFM X/Forms Workflow Interface software (y/n/h) ?" "n"`
            case "$xworkflans" in
            [Hh]*)
                echo "\nThe I/NFM X/Forms Workflow Interface is an X/Forms-based \c"
                echo "utility for creating"
                echo "and modifying user-defined item workflows.  This \c"
                echo "utility may also be"
                echo "used to copy existing workflows.  \c"
                echo "The I/NFM X/Forms Workflow Interface requires approximately \c"
                echo "${Wfx_Size} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$xformsans" = "y" ]
                then
                    flsans=y
                    msgans=y
                    riswarn=y
                fi
                ;;
            esac
        done
#
#  Do you want the bulkloader?
#    
        cant_decide=1
        while test $cant_decide -eq 1
        do
        blkans=`getanswer "Install I/NFM Alpha BulkLoader Interface software (y/n/h) ?" "n"`
            case "$blkans" in
            [Hh]*)
                echo "\nThe I/NFM Bulk Loader can be used to quickly \c"
                echo "enter a large amount of"
                echo "file information into an I/NFM operating environment.\c"
                echo "  The Bulk Loader requires \napproximately ${Blk_Size}\c"
                echo " blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$blkans" = "y" ]
                then
                    flsans=y
                    msgans=y
                    riswarn=y
                fi
                ;;
            esac
        done
    
#
#  If combined, Do you want the Nfmadmin utility?
#
        if [ "$combinedans" = "y" ]
        then
          cant_decide=1
          while test $cant_decide -eq 1
          do
          admans=`getanswer "Install I/NFM Administrator Utility (y/n/h) ?" "n"`
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
                      riswarn=y
                  fi
                  ;;
              esac
          done
        fi  #if combined
#  If combined, Do you want the DBA Server?
#
#
        if [ "$combinedans" = "y" ]
        then
          cant_decide=1
          while test $cant_decide -eq 1
          do
    dbaserans=`getanswer "Install DBA SERVER (DBA/NFM) (y/n/h) ?" "n"`
             case "$dbaserans" in
             [Hh]*)
                echo "\nThe DBA/NFM Server must reside on all \c"
                echo "machines that will \ncommunicate with DBA/NFM.  \c"
                echo "All network protocol software must be"
                echo "downloaded prior to the DBA/NFM Server.  \c"
                echo "The DBA/NFM Server requires approximately \c"
                echo "${Dba_Size} blocks.\n"
                    ;;
                 *)
                  cant_decide=0
                  if [ "$dbaserans" = "y" ]
                  then
                      msgans=y
                      riswarn=y
                  fi
                  ;;
                esac
          done
      fi
    fi  #if combinedans or tradans = y

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
                echo "The I/NFM Fileserver requires approximately \c"
                echo "${Fls_Size} blocks.\n" 
                ;;
            *)
                cant_decide=0
                msgans=y
               ;;
            esac
        done
    fi  # flsans = n
    

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
        exit 0
fi

#
# Check for the presence of RIS
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
fi

#
# Check for 'nfmadmin' account
#

if [ "$combinedans" = "y" ]
then
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
if [ "$combinedans" = "y" ]
then
    if [ "$formsans" = "y" -o "$xformsans" = "y" -o "$alphaans" = "y" ]
    then
        Check_Space $UNIXDIR $Ini_Size "I/NFM Initialize Software"
        echo Installing I/NFM Initialize Software
        echo Installing I/NFM Initialize Software >>$LOGFILE 2>&1
        date >>$LOGFILE 2>&1
        getfile nfmini.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
        AOK=$?
        if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
fi

#
#  Load Combined/Client software
#
#  Load X/Forms Combined Client-Server
if [ "$combinedans" = "y" -a "$xformsans" = "y" ]
then
    Check_Space $UNIXDIR $Fcx_Size "I/NFM X/Forms Combined Client-Server"
    echo Installing I/NFM X/Forms Combined Client-Server Software
    echo Installing I/NFM X/Forms Combined Client-Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmfcx.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile nfmhlp.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load Alpha Combined Client-Server
if [ "$combinedans" = "y" -a "$alphaans" = "y" ]
then
    Check_Space $UNIXDIR $Acc_Size "I/NFM Alphanumeric Combined Client-Server"
    echo Installing I/NFM Alphanumeric Combined Client-Server Software
    echo Installing I/NFM Alphanumeric Combined Client-Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmacc.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load DBA/NFM Combined Client-Server
if [ "$combinedans" = "y" -a "$dbaserans" = "y" ]
then
    Check_Space $UNIXDIR $Dba_Size "I/NFM I/Forms Combined Client-Server"
    echo Installing DBA/NFM Combined Client-Server Software
    echo Installing DBA/NFM Combined Client-Server Software>>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile dbasrv.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    chmod +s ${UNIXDIR}/bin/dbasrv  >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
#
# Load Traditional I/NFM User Interfaces
#
#  Load X/Forms Forms UI
if [ "$tradans" = "y" -a "$xformsans" = "y" ]
then
    Check_Space $UNIXDIR $Ffx_Size "I/NFM X/Forms User Interface"
    echo Installing I/NFM X/Forms User Interface 
    echo Installing I/NFM X/Forms User Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmffx.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    getfile nfmhlp.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$tradans" = "y" -a "$alphaans" = "y" ]
then
    Check_Space $UNIXDIR $Alp_Size "I/NFM Alphanumeric User Interface"
    echo Installing I/NFM Alphanumeric Interface
    echo Installing I/NFM Alphanumeric Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmalp.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load Command Line Interface
#

if [ "$clians" = "y" ]
then
    Check_Space $UNIXDIR $Cli_Size "I/NFM Command Line Interface"
    echo Installing I/NFM Command Line Interface
    echo Installing I/NFM Command Line Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmcli.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load X/Forms Workflow Interface
#
if [ "$xworkflans" = "y" ]
then
    Check_Space $UNIXDIR $Wfx_Size "I/NFM X/Forms Workflow Interface"
    echo Installing I/NFM X/Forms Workflow Interface Software
    echo Installing I/NFM X/Forms Workflow Interface Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmwfx.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$blkans" = "y" ]
then
    Check_Space $UNIXDIR $Blk_Size "I/NFM Bulk Load Utility"
    echo Installing I/NFM Bulk Loader
    echo Installing I/NFM Bulk Loader >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmblk.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load Separate Utilities
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
#  Install documentation files.
#

getfile nfmdoc.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1

#
# Get postinstall
#
    cd ${UNIXDIR}/i_nfmui
    getfile postinst.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#
#  Make root the owner of the product.
#

find $UNIXDIR -exec chown root {} \;
find $UNIXDIR -exec chgrp sys {} \;

#
#  Put the nfmd.conf file in the right place.
#

if [ -f ${UNIXDIR}/config/nfmd.conf ] 
    then
    cp ${UNIXDIR}/config/nfmd.conf /etc
    fi

curuser=`grep nfmadmin /etc/passwd`
fp=`echo $curuser | cut -f6 -d":"`
cat $fp/clh_info/NFMenv.dat |
while read text
do
  env=`echo $text | cut -f1 -d "" | cut -c6-`
  if [ ! -d $fp/$env/dmd_ftr ]; then
  echo Creating FTR Directory for Environment: $env
  mkdir -p $fp/$env/dmd_ftr; fi
  chmod 777 $fp/$env/dmd_ftr
  chown nfmadmin $fp/$env/dmd_ftr
  find $fp/clh_info -exec chown nfmadmin {} \;
  if [ ! -d $fp/$env/dmd_ftr ];
  then echo Cannot create $fp/$env/dmd_ftr;
  fi
  done
  
echo "\n<<<<<<<<<<<<<<<<<<<<<<<Important Warning>>>>>>>>>>>>>>>>>>>"
echo "\nIf you have RIS version 4.3 or lower,  you will"
echo "need to copy usrx/ip32/nfm/risutil/utl.msg"
echo "to /usrx/ip32/ris/riscli/config/english/messages prior"
echo "to running NFMinit.\n"

exit $retstatus

