#
# Copyright Intergraph Corporation
#
# I/NFM Product Installation
#
# Synopsis
#
#    install.sh <srcmedia> <node.usr.pass> <srcdir> <destdir> [takedefaults]
#


# Check to see if there is any server running in the machine that try
# To do newprod I/NFM product.

UNIXDIR=$DESTDIR

if [ ! -d ${UNIXDIR} ]; then mkdir -p ${UNIXDIR}; fi
if [ ! -d ${UNIXDIR} ]; then echo Cannot create ${UNIXDIR}; exit 1; fi

LOGFILE=${UNIXDIR}/log
cat /dev/null > $LOGFILE

# get file partition
fp=`echo $UNIXDIR | cut -f2 -d"/"`
UNIXDIR=/$fp/ip32/nfm

cd ${UNIXDIR}

RISVER="4.3"
Ini_Size=2500
Fcc_Size=11000
Fcx_Size=12000
Acc_Size=9500
Wfg_Size=4500
Wfx_Size=5000
Adm_Size=4500
Ffi_Size=4800
Ffx_Size=5200
Hlp_Size=3000
Alp_Size=3800
Cli_Size=1600
Blk_Size=6500
Fbk_Size=1300
Fbx_Size=1400
Fls_Size=1700
Uti_Size=2000
Msg_Size=625

Fcc_Size=`expr $Ini_Size + $Fcc_Size + $Msg_Size`
Fcx_Size=`expr $Ini_Size + $Fcx_Size + $Msg_Size`
Acc_Size=`expr $Ini_Size + $Acc_Size + $Msg_Size`
Wfg_Size=`expr $Wfg_Size + $Msg_Size`
Wfx_Size=`expr $Wfx_Size + $Msg_Size`
Adm_Size=`expr $Adm_Size + $Msg_Size`
Ffi_Size=`expr $Ffi_Size + $Msg_Size`
Ffx_Size=`expr $Ffx_Size + $Msg_Size`
Alp_Size=`expr $Alp_Size + $Msg_Size`
Cli_Size=`expr $Cli_Size + $Msg_Size`
Blk_Size=`expr $Blk_Size + $Msg_Size`
Fbk_Size=`expr $Fbk_Size + $Msg_Size`
Fbx_Size=`expr $Fbx_Size + $Msg_Size`
Fls_Size=`expr $Fls_Size + $Uti_Size`

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data
TCPMSG="is NOT"

curnfmver=`grep SN01383 /usr/ip32/ingrconfig | cut -f4 -d"#"`

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

Get_Size () { # Get image size
  COMBINED=$1
  UI=$2

  if [ "$COMBINED" = "y" ]
  then
      case $UI in
          FORMS )
              SIZE=$Fcc_Size
              ;;
          XFORMS )
              SIZE=$Fcx_Size
              ;;
          ALPHA )
              SIZE=$Acc_Size
              ;;
          * )
              ;;
      esac
  else
      case $UI in
          FORMS )
              SIZE=$Ffi_Size
              ;;
          XFORMS )
              SIZE=$Ffx_Size
              ;;
          FBLUbulkloader )
              SIZE=$Fbk_Size
              ;;
          XBLUbulkloader )
              SIZE=$Fbx_Size
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
echo "ware is now delivered with I_NFMSRV (SN01382)."
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
echo "Download executables for $CPUID processors . . ." >>$LOGFILE 2>&1

#
# Get responses to prompts
#

#    combinedans => Combined Client-Server Architecture
#    tradans  => Traditional Client-Server Architecture
#    formsans => Forms Software
#    xformsans => X Forms Software
#    alphaans => Alpha Software
#    workflans => Workflow Interface (Nfmwff)
#    xworkflans => X Workflow Interface (Nfmwff)
#    admans  => Administrator Utility (Nfmadmin)
#    hlpans  => Help
#    hlpblkans => HELP (BLUblukloader)
#    clians  => Command Line Interface (Nfmcli)
#    blkans  => Bulkloaders (Nfmbulk, BLU*)
#    formsblkans  => Forms BLUbulkloaders Interface (DataEntry.exe)
#    xformsblkans  => X forms BLUbulkloaders Interface (DataEntryx.exe)
#    flsans  => File server and daemon (NFMfileserver/NFMdaemon)
#    msgans  => Messages configuration
#    msgblkans => Message configuration (BLUbulkloader)
#    riswarn => RIS version warning

# initialize stuff
flsans=n
msgans=n
msgblkans=n
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
                    msgblkans=y
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
        if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
        then
            echo "\nThe I/NFM Graphic Interface is available built on I/Forms or \c"
            echo "I/XForms.\n"
        fi
       
        cant_decide=1
        while test $cant_decide -eq 1
        do
        formsans=`getanswer "Install I/NFM I/Forms ${ARCH} software (y/n/h) ?" "y"`
            case "$formsans" in
            [Hh]*)
                Get_Size $combinedans FORMS
                echo "\nThe I/NFM I/Forms ${ARCH} software is a \c"
                echo "I/Forms-based graphic"
                echo "interface of I/NFM.\n"
                echo "The I/NFM I/Forms ${ARCH} software \c"
                echo "requires approximately\n${SIZE} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$formsans" = "y" ]
                then
                    xformsans=n
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
        xformsans=`getanswer "Install I/NFM I/XForms ${ARCH} software (y/n/h) ?" "n"`
            case "$xformsans" in
            [Hh]*)
                Get_Size $combinedans XFORMS
                echo "\nThe I/NFM I/XForms ${ARCH} software is a \c"
                echo "XWindows graphic interface of I/NFM.\n"
                echo "The I/NFM I/XForms ${ARCH} software \c"
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

        if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
        then
            echo "\nThe I/NFM Workflow Interface is available built on I/Forms or \c"
            echo "I/XForms.\n"
        fi
       
        cant_decide=1
        while test $cant_decide -eq 1
        do
        workflans=`getanswer "Install I/NFM I/Forms Workflow Interface software (y/n/h) ?" "n"`
            case "$workflans" in
            [Hh]*)
                echo "\nThe I/NFM I/Forms Workflow Interface is an I/Forms-based \c"
                echo "utility for creating"
                echo "and modifying user-defined item workflows.  This \c"
                echo "utility may also be"
                echo "used to copy existing workflows.  \c"
                echo "The I/NFM I/Forms Workflow Interface requires approximately \c"
                echo "${Wfg_Size} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$workflans" = "y" ]
                then
                    xworkflans=n
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
        xworkflans=`getanswer "Install I/NFM I/XForms Workflow Interface software (y/n/h) ?" "n"`
            case "$xworkflans" in
            [Hh]*)
                echo "\nThe I/NFM I/XForms Workflow Interface is an I/XForms-based \c"
                echo "utility for creating"
                echo "and modifying user-defined item workflows.  This \c"
                echo "utility may also be"
                echo "used to copy existing workflows.  \c"
                echo "The I/NFM I/XForms Workflow Interface requires approximately \c"
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


        if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
        then
    echo "\nThe I/NFM BLUbulkloader Interface is available built on I/Forms or \c"
            echo "I/XForms.\n"
        fi
       
        cant_decide=1
        while test $cant_decide -eq 1
        do
        formsblkans=`getanswer "Install I/NFM I/Forms BLUbulkloader Interface software (y/n/h) ?" "n"`
            case "$formsblkans" in
            [Hh]*)
                echo "\nThe I/NFM I/Forms BLUbulkloader Interface is an I/Forms-based \c"
                echo "utility for BLUblukloader"
                echo "The I/NFM I/Forms BLUbulkloader Interface requires approximately \c"
                echo "${Fbk_Size} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$formsblkans" = "y" ]
                then
                    xformsblkans=n
                    flsans=y
                    msgblkans=y
                    riswarn=y
                fi
                ;;
            esac
        done

        cant_decide=1
        while test $cant_decide -eq 1
        do
        xformsblkans=`getanswer "Install I/NFM I/XForms BLUbulkloader Interface software (y/n/h) ?" "n"`
            case "$xformsblkans" in
            [Hh]*)
                echo "\nThe I/NFM I/XForms BLUbulkloader Interface is an I/XForms-based \c"
                echo "Utility for Dmands Bulkloader "
                echo "The I/NFM I/XForms BLUbulkloader Interface requires approximately \c"
                echo "${fbx_Size} blocks.\n"
                ;;
            *)
                cant_decide=0
                if [ "$xformsblkans" = "y" ]
                then
                    flsans=y
                    msgblkans=y
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
        blkans=`getanswer "Install I/NFM Bulk Loader (y/n/h) ?" "n"`
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

#
#   If the forms/BLUbulkloader user interface is requested, do you want help?
#
        if [ "$formsblkans" = "y" -o "$xformsblkans" = "y" ]
        then
            cant_decide=1
            while test $cant_decide -eq 1
            do
                if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
                then
                    echo "\nOn-Line Help is available for the BLUbulkloader \c"
                    echo "graphic interfaces via HELPRT."
                    echo "The I/NFM HELPFILE files will be delivered. \c"
                    echo "If this system is a Help server,"
                    echo "the I/NFM HELPFILE files are also available.\n"
                fi

                helpserver=`grep "helpds" /etc/inetd.conf`
                if [ "$helpserver" != "" ]
                then
                    helpserver=y
                    echo "This machine IS a Help server.\n"
                    hlpblkans=`getanswer "Install I/NFM BLUbulkloader On-line Help (y/n/h) ?" "y"`
                    case "$hlpblkans" in
                    [Hh]*)
                        echo "\nThe I/NFM BLUbulkloader Interface has On-Line help \c"
                        echo "available via HELPRT.  This will"
                        echo "require approximately ${Hlp_Size} additional \c"
                        echo "blocks.  \n"
                        ;;
                    *)
                        cant_decide=0
                        ;;
                    esac
                else
                    cant_decide=0
                    helpserver=n
                fi
            done

            if [ "$helpserver" = "n" ]
            then
                echo "This machine IS NOT a Help server.\n"
            fi
        fi  #if forms

    fi  #if combinedans or tradans = y

#
#   If the forms user interface is requested, do you want help?
#
        if [ "$formsans" = "y" -o "$xformsans" = "y" ]
        then
            cant_decide=1
            while test $cant_decide -eq 1
            do
                if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
                then
                    echo "\nOn-Line Help is available for the I/NFM \c"
                    echo "graphic interfaces via HELPRT."
                    echo "The I/NFM HELPINFO files will be delivered. \c"
                    echo "If this system is a Help server,"
                    echo "the I/NFM HELPFILE files are also available.\n"
                fi

                helpserver=`grep "helpds" /etc/inetd.conf`
                if [ "$helpserver" != "" ]
                then
                    helpserver=y
                    echo "This machine IS a Help server.\n"
                    hlpans=`getanswer "Install I/NFM On-line Help (y/n/h) ?" "y"`
                    case "$hlpans" in
                    [Hh]*)
                        echo "\nThe I/NFM Forms Interface has On-Line help \c"
                        echo "available via HELPRT.  This will"
                        echo "require approximately ${Hlp_Size} additional \c"
                        echo "blocks.  \n"
                        ;;
                    *)
                        cant_decide=0
                        ;;
                    esac
                else
                    cant_decide=0
                    helpserver=n
                fi
            done

            if [ "$helpserver" = "n" ]
            then
                echo "This machine IS NOT a Help server.\n"
            fi
        fi  #if forms
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
        if [ "$deliver_c100" = "y" ]
        then
            getfile nfmini.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
        fi
        if [ "$deliver_c400" = "y" ]
        then
            getfile nfmini.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
        fi
        AOK=$?
        if [ "$AOK" != "0" ] ; then exit $AOK; fi
    fi
fi

#
#  Load Combined/Client software
#

#  Load I/Forms Combined Client-Server
if [ "$combinedans" = "y" -a "$formsans" = "y" ]
then
    Check_Space $UNIXDIR $Fcc_Size "I/NFM I/Forms Combined Client-Server"
    echo Installing I/NFM I/Forms Combined Client-Server Software
    echo Installing I/NFM I/Forms Combined Client-Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmfcc.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmfcc.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load I/XForms Combined Client-Server
if [ "$combinedans" = "y" -a "$xformsans" = "y" ]
then
    Check_Space $UNIXDIR $Fcx_Size "I/NFM I/XForms Combined Client-Server"
    echo Installing I/NFM I/XForms Combined Client-Server Software
    echo Installing I/NFM I/XForms Combined Client-Server Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmfcx.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmfcx.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
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
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmacc.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmacc.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
# Load Traditional I/NFM User Interfaces
#

#  Load I/Forms Forms UI
if [ "$tradans" = "y" -a "$formsans" = "y" ]
then
    Check_Space $UNIXDIR $Ffi_Size "I/NFM I/Forms User Interface"
    echo Installing I/NFM I/Forms User Interface 
    echo Installing I/NFM I/Forms User Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmffi.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmffi.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load I/XForms Forms UI
if [ "$tradans" = "y" -a "$xformsans" = "y" ]
then
    Check_Space $UNIXDIR $Ffx_Size "I/NFM I/XForms User Interface"
    echo Installing I/NFM I/XForms User Interface 
    echo Installing I/NFM I/XForms User Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmffx.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmffx.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load I/Forms BLUbulkload Forms UI
if [ "$tradans" = "y" -a "$formsblkans" = "y" ]
then
    Check_Space $UNIXDIR $Fbk_Size "I/NFM I/Forms BLUbulkloaderUser Interface"
    echo Installing I/NFM I/Forms BLUbulkloader User Interface 
    echo Installing I/NFM I/Forms BLUbulkloader User Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmfblk.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmfblk.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#  Load I/XForms Forms BLUbulkload UI
if [ "$tradans" = "y" -a "$xformsblkans" = "y" ]
then
    Check_Space $UNIXDIR $Fbx_Size "I/NFM I/XForms User Interface"
    echo Installing I/NFM I/XForms BLUbulkloader User Interface 
    echo Installing I/NFM I/XForms BLUbulkloader User Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmfblkx.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmfblkx.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$tradans" = "y" -a "$alphaans" = "y" ]
then
    Check_Space $UNIXDIR $Alp_Size "I/NFM Alphanumeric User Interface"
    echo Installing I/NFM Alphanumeric Interface
    echo Installing I/NFM Alphanumeric Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmalp.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmalp.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load Help
#
if [ "$hlpans" = "y" ]
then
    Check_Space $UNIXDIR $Hlp_Size "I/NFM On-Line Help"
    echo Installing I/NFM On-Line Help
    echo Installing I/NFM On-Line Help >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmhlp.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi


if [ "$hlpblkans" = "y" ]
then
    Check_Space $UNIXDIR $Hlp_Size "I/NFM On-Line Help"
    echo Installing I/NFM BLUbulkloader On-Line Help
    echo Installing I/NFM BLUbulkloader On-Line Help >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmhlpBLU.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi
#
#  Load I/Forms Workflow Interface
#
if [ "$workflans" = "y" ]
then
    Check_Space $UNIXDIR $Wfg_Size "I/NFM I/Forms Workflow Interface"
    echo Installing I/NFM I/Forms Workflow Interface Software
    echo Installing I/NFM I/Forms Workflow Interface Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmwfg.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmwfg.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#  Load I/XForms Workflow Interface
#
if [ "$xworkflans" = "y" ]
then
    Check_Space $UNIXDIR $Wfg_Size "I/NFM I/XForms Workflow Interface"
    echo Installing I/NFM I/XForms Workflow Interface Software
    echo Installing I/NFM I/XForms Workflow Interface Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmwfx.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmwfx.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$blkans" = "y" ]
then
    Check_Space $UNIXDIR $Blk_Size "I/NFM Bulk Load Utility"
    echo Installing I/NFM Bulk Loader
    echo Installing I/NFM Bulk Loader >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmblk.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmblk.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
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
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmadm.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmadm.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$clians" = "y" ]
then
    Check_Space $UNIXDIR $Cli_Size "I/NFM Command Line Interface"
    echo Installing I/NFM Command Line Interface
    echo Installing I/NFM Command Line Interface >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmcli.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmcli.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
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
    getfile nfmmsg.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

if [ "$msgblkans" = "y" ]
then
    Check_Space $UNIXDIR $Msg_Size "I/NFM Message Files"
    echo Installing I/NFM BLUbulkloader Message Files
    echo Installing I/NFM BLUbulkloader Message Files >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmmsgBLU.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1
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
        /etc/init.d/nfm stop_nfm; 
        unlink /etc/init.d/nfm; 
    fi

    echo Installing I/NFM File Server
    echo Installing I/NFM File Server  >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmfls.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmfls.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

    if [ "$deliver_c100" = "y" ]
    then
        getfile nfmuti.p100 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    if [ "$deliver_c400" = "y" ]
    then
        getfile nfmuti.p400 | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    fi
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi

#
#  Link startup script to init.d.
#
    if [ -d /usr/ip32/tcpip ]; then TCPMSG="IS"; fi
    ln /etc/rc2.d/S99nfm /etc/init.d/nfm
    ln /etc/rc2.d/S99nfm /etc/rc0.d/K99nfm
    echo "\nNote: The network product TCP/IP $TCPMSG installed on this system."
fi

#
#  Install the "man" pages if sysvdoc is present
#

if [ -d /usr/ip32/sysvdoc/catman/i_man/man1 ]
then 
    ln -s ${UNIXDIR}/config/english/man/* \
        /usr/ip32/sysvdoc/catman/i_man/man1 >>$LOGFILE 2>&1
fi

#
#  If "vman" exists, update the "man" database.
#

if [ -x /usr/ip32/sysvdoc/newpage ]
then 
    /usr/ip32/sysvdoc/newpage ${UNIXDIR}/config/english/man/* 
fi

#
#  Fix Looking Glass rules database so that user can use alpha interface.
#

inqlgexist
if [ $? -eq 0 ]
then
#  Remove existing I/NFM Looking Glass Definitions
    lgrmdefs prog nfm.ftc

    echo "#include <ftdefs.h>" > ${UNIXDIR}/nfm.ftc
    echo "#include <ftdefs.loc.h>" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_ALPHA" >> ${UNIXDIR}/nfm.ftc
    echo "UserPrefCommand(NUC_NFM_ALPHA)" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -\\\"#c/#f -A\\\""\" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"Run I/NFM Alpha Interface - Admin\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -#c/#f\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"Run I/NFM Alpha Interface\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_FI" >> ${UNIXDIR}/nfm.ftc
    echo "UserPrefCommand(NUC_NFM_FI)" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"./Nfmfi -A\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Forms Interface - Admin\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"./Nfmfi\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Forms Interface\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_INIT" >> ${UNIXDIR}/nfm.ftc
    echo "UserPrefCommand(NUC_NFM_INIT)" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -#c/#f\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Initialize\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_UTIL" >> ${UNIXDIR}/nfm.ftc
    echo "UserPrefCommand(NUC_NFM_UTIL)" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -#c/#f\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Utility Interface\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_ADM" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"vterm -x -#c/#f\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Administrator Utility\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    echo "APPEND_COMMANDS TAIL NUC_NFM_WFF" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND ATTRIBUTE:NATIVE \"./Nfmwff\"" >> ${UNIXDIR}/nfm.ftc
    echo "COMMAND_DESCRIPTION \"I/NFM Workflow Interface\"" >> ${UNIXDIR}/nfm.ftc
    echo "END" >> ${UNIXDIR}/nfm.ftc
    lgappcmds ${UNIXDIR}/nfm.ftc
fi

#  This call has to go here or it will cause the installation procedure to
#  think that an error occured.
#

getfile nfmdoc.p | compress -d | cpio -ivmud >>$LOGFILE 2>&1

#
# Get postinstall.sh
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
# Install Help Document
#
if [ "$hlpans" = "y" ]
then
    /usr/bin/installhdoc.sh ${UNIXDIR}/config/english/admin_help/HELPFILE
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    /usr/bin/installhdoc.sh ${UNIXDIR}/config/english/user_help/HELPFILE
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

# Install Help Document For BLUbulkloader
#
if [ "$hlpblkans" = "y" ]
then
    /usr/bin/installhdoc.sh ${UNIXDIR}/cfg/english/help/help_file.hc
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    /usr/bin/installhdoc.sh ${UNIXDIR}/cfg/english/help/help_info
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
fi

#
#   Eliminate files that are no longer necessary.
#

if [ -f /usr/ip32/nfm/bin/NFMstartup ]
then
    rm /usr/ip32/nfm/bin/NFMstartup
fi

if [ -f /usr/ip32/nfm/bin/Nfmdtconvert ]
then
    rm /usr/ip32/nfm/bin/Nfmdtconvert
fi

if [ -f /usr/ip32/nfm/bin/Nfmsaconvert ]
then
    rm /usr/ip32/nfm/bin/Nfmsaconvert
fi

if [ -f /usr/ip32/nfm/bin/get_listen.com ]
then
    rm /usr/ip32/nfm/bin/get_listen.com
fi

# Remove the "old" forms config. Now in /usr/ip32/nfm/config/english/forms
if [ -d /usr/ip32/nfm/config/forms ]
then
    rm -r /usr/ip32/nfm/config/forms
fi

# Remove old entries in /etc/inetd.conf
if [ -f /etc/inetd.conf ]
then
    line=""
    line=`grep -n "NFMserver" /etc/inetd.conf`
    if [ "$line" != "" ]
    then
        sed -e "/^NFMserver/D" -e "/^NFMlistener/D" \
                /etc/inetd.conf > /usr/tmp/nfm.tmp
        mv /usr/tmp/nfm.tmp /etc/inetd.conf >/dev/null 2>&1
    fi
fi

# Remove old entries in /etc/services
if [ -f /etc/services ]
then
    line=""
    line=`grep -n "NFMserver" /etc/services`
    if [ "$line" != "" ]
    then
        sed -e "/NFMserver/D" -e "/NFMlistener/D" \
                /etc/services > /usr/tmp/nfm.tmp
        mv /usr/tmp/nfm.tmp /etc/services >/dev/null 2>&1
    fi
fi

# Remove old entries /usr/ip32/inc/server.dat
if [ -f /usr/ip32/inc/server.dat ]
then
    line=""
    line=`grep -n "NFMlistener" /usr/ip32/inc/server.dat`
    if [ "$line" != "" ]
    then
        sed -e "/NFMlistener/D" /usr/ip32/inc/server.dat > /usr/tmp/nfm.tmp
        mv /usr/tmp/nfm.tmp /usr/ip32/inc/server.dat >/dev/null 2>&1
    fi
fi

# Remove old help directories/files
CONFIGDIR=/usr/ip32/nfm/config/english

if [ -d ${CONFIGDIR}/admin_help/help_graphics ]
then
    rm -r ${CONFIGDIR}/admin_help/help_graphics >/dev/null 2>&1
fi

if [ -d ${CONFIGDIR}/admin_help/help_source ]
then
    rm -r ${CONFIGDIR}/admin_help/help_source >/dev/null 2>&1
fi

if [ -d ${CONFIGDIR}/user_help/help_graphics ]
then
    rm -r ${CONFIGDIR}/user_help/help_graphics >/dev/null 2>&1
fi

if [ -d ${CONFIGDIR}/user_help/help_source ]
then
    rm -r ${CONFIGDIR}/user_help/help_source >/dev/null 2>&1
fi

exit $retstatus
