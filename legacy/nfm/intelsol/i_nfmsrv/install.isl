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
#
# Modified for the Sun version - Vasu 29.11.93
#
# Switch 'f' changed to 'l' for the Sun.
RUNSERV=`ps -eal | grep NFMserver | grep -v grep`
if [ "$RUNSERV" ]
 then
  echo "\n Error: NFMserver is running in this machine."
  echo "Unable to complete install.isl.\n"
  exit 3

fi

Check_Space () { # Check Disk Space
  checkDIR=$1
  checkSIZE=$2
  checkPRODUCT=$3  

# Modification for the SunOs.
# The first 5 parameters are headings that get printed so $3 would be actually
# ${11} for the Sun df implementation. Sample shown for a better understanding
# of the problem. - Vasu 13.Feb.94
#
# /bin/df /usr2
# Fileeystem            kbytes    used   avail capacity  Mounted on
# /dev/sd1g             613252  469468   82459    85%    /usr2

   set `/bin/df $checkDIR`
   Disk_Space=${6}   # changed from ${11} for INTELSOL -CN 05/05/95

# set `df $checkDIR`    ** Old code
# Disk_Space=$3         ** Old code

  if [ $Disk_Space -lt $checkSIZE ]
  then
    echo ${checkPRODUCT} requires ${checkSIZE} blocks.
    echo ${checkDIR} has only ${Disk_Space} free blocks.
    exit 1
  fi
}

##################################################################
#           !!!!!!!!!!!!    FTRRT PATCH !!!!!!!!!!!!!!!!!
#
# Now FTRRT is being supplied as a patch with I/NFM Server
#                                              --  Jujare, 12-APR-95
#
# 1. We are providing patch in the form of a compressed file called 
#    as client.ps4 
#
# 2. To give an updated patch of FTRRT, we need to get client.ps4 from
#    the FTRRT people.
#
# 3. Whenever we want to give an updated version of client.ps4, we need
#    to change the New_FTRRT_Ver and FTRRT_Size in the code here.
#
#  
#FTRRT_Dir="${DESTDIR%%/nfm/i_nfmsrv}"
#    FTRRT_Size=2200
#    New_FTRRT_Ver='01.01.00.05'
#    New_FTRRT_Ver_Num=`echo $New_FTRRT_Ver | cut -d. -c1-2,4-5,7-8,10-11`
#    grep "I_FTRRT" $INGRHOME/ingrconfig 1>/dev/null
#    FTRRT_Exists=`echo $?`
# 
#    if [ "$FTRRT_Exists" = "1" ]
#    then
#       echo
#       echo "WARNING !!!!"
#       echo "FTRRT cannot be detected on this machine.  I/NFM will not"
#       echo "run without FTRRT. The FTRRT objects which are required by"
#       echo "I/NFM are now being supplied with I/NFM product as a patch"
#       echo  
#       echo "Do you want to get the latest ($New_FTRRT_Ver) patch of I_FTRRT (y/n) ? [y] \c"
#       read GET_FTR; : ${GET_FTR:=y}
#       if [ "$GET_FTR" =  "y" ]
#       then
#         #Check_Space $FTRRT_Dir $FTRRT_Size "I_FTRRT Software"
#         FTRRT_Dir=$FTRRT_Dir/ftrrt
#       fi
#    else
#       FTRRT_Ver=`grep I_FTRRT $INGRHOME/ingrconfig | cut -f4 -d#`
#       FTRRT_Ver_Num=`echo $FTRRT_Ver | cut -d. -c1-2,4-5,7-8,10-11`
# 
#       if [  "$FTRRT_Ver_Num" -lt "$New_FTRRT_Ver_Num" ]
#       then
#         echo "WARNING !!!!"
#         echo "The Existing I_FTRRT on this Machine ($FTRRT_Ver) seems \
#               to be incompatible with I/NFM. I/NFM requires \
#               I_FTRRT ($New_FTRRT_Ver)"
#         echo "The FTRRT objects which are required by"
#         echo "I/NFM are now being supplied with I/NFM product as a patch"
#         echo "Do you want to get the latest ($New_FTRRT_Ver) patch of I_FTRRT (y/n) ? [y] \c"
#         read GET_FTR; : ${GET_FTR:=y}
#         if [ "$GET_FTR" =  "y" ]
#         then
#           #Check_Space $FTRRT_Dir $FTRRT_Size "I_FTRRT Software"
#           #FTRRT_Dir=`grep I_FTRRT $INGRHOME/ingrconfig | cut -f6 -d#`
#           FTRRT_Dir=$FTRRT_Dir/ftrrt
#         fi
#       fi
#    fi
# 
#    if [ "$FTRRT_Exists" = "1" ]
#    then
#       ftrfound='y'
#    else
#       ftrfound='n'
#    fi
## End of Code for FTRRT Patch
##################################################################



if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
#    if [ -f /usr/ip32/ingrconfig ]
    if [ -f $INGRHOME/ingrconfig ]
    then
        line=""
#        line=`grep -n "\#I_NFMSRV\#" /usr/ip32/ingrconfig`
        line=`grep -n "\#I_NFMSRV\#" $INGRHOME/ingrconfig`
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
#               sed -e "/\#I_NFMSRV\#/D" /usr/ip32/ingrconfig > /usr/tmp/nfm.tmp
                sed -e "/\#I_NFMSRV\#/D" $INGRHOME/ingrconfig > /usr/tmp/nfm.tmp
#               mv /usr/tmp/nfm.tmp /usr/ip32/ingrconfig >/dev/null 2>&1
                mv /usr/tmp/nfm.tmp $INGRHOME/ingrconfig >/dev/null 2>&1

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
#fp=`echo $UNIXDIR | cut -f2 -d"/"`
for i in 1 2 3 4 5
do
   dir=`echo $UNIXDIR | cut -f$i -d"/"`
   if [ "$dir" = "ip32" ]
   then
      let j=$i-1
      fp=`echo $UNIXDIR | cut -f1-$j -d"/"`
      break
   fi
done

UNIXDIR=/$fp/ip32/nfm

cd ${UNIXDIR}

#Flag to check if any of the Server Modules are Installed
Product_Installed=0

RISVER="5.2"
Ini_Size=2500
Srv_Size=10000
Pcs_Size=5100
Adm_Size=4500
# Nfmconvert is no more delivered, as per pwt's request - Jujare 17-May-95
#Cvt_Size=3800
Fls_Size=1700
Uti_Size=2000
Msg_Size=625
Dba_Size=2500

Srv_Size=`expr $Srv_Size + $Ini_Size + $Msg_Size`
Adm_Size=`expr $Adm_Size + $Msg_Size`
# Nfmconvert is no more delivered, as per pwt's request - Jujare 17-May-95
#Cvt_Size=`expr $Cvt_Size + $Msg_Size`
Fls_Size=`expr $Fls_Size + $Uti_Size`

pd=/usr/ip32/product_data
pdtmp=/usr/ip32/Product_Data
TCPMSG="is NOT"

#curnfmver=`grep SN01382 /usr/ip32/ingrconfig | cut -f4 -d"#"`
curnfmver=`grep SN01382 $INGRHOME/ingrconfig | cut -f4 -d"#"`


#
# Give message on importance of README
#

echo "\nThis version of I/NFM is built on RIS ${RISVER} and is compatible"
echo "ONLY with RIS ${RISVER} or later. If you do not have RIS ${RISVER} or"
echo "later loaded on your server and environment machines, DO NOT download"
echo "this version of the I/NFM server software.  "
echo "\nThis version of I/NFM Server software has Year 2000 Fixes. "
#echo "\nThis version of the I/NFM server software represents major changes and"
#echo "enhancements over previous versions. The I/NFM user interface software"
#echo "is now delivered with I_NFMUI (SN01383)."
echo "\nIt is recommended that you remove the product before upgrading. It is"
echo "imperative that all users review the README file that is delivered with"
echo "I/NFM before attempting to use the software.\n"

if [ "$PREPROCESS" = "Y" -o "$PREPROCESS" = "y" ]
then
while [ "$contans" != "y" -a "$contans" != "n" ]
do
    contans=`getanswer "Do you wish to continue (y/n) ?" "n"`
    case "$contans" in
    [Nn]*)
        exit 1
        ;;
    *)
        ;;
    esac
done
fi

echo "Download executables . . ." >>$LOGFILE 2>&1

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
            if [ "$srvans" = "y" -o "$srvans" = "n" ]
            then
                cant_decide=0
            fi

            if [ "$srvans" = "y" ]
            then
                flsans=y
                msgans=y
                riswarn=y
            fi
            ;;
        esac
    done

#
#   Do you want the Dba server software?
#
    cant_decide=1
    while test $cant_decide -eq 1
    do
    dbasrvans=`getanswer "Install DBASRV (PC DBA/NFM Server) (y/n/h) ?" "y"`
	case "$dbasrvans" in
        [Hh]*)
            echo "\nThe DBASRV Server software is the Interface \c"
            echo "between PC DBA and NFM Server.\c"
	    echo "With the DBA_NFM calls User can query the NFM database.\c"
            echo "It requires approximately\n${Dba_Size} blocks.\nRIS \c"
            echo "must be installed before I/NFM can be initialized."
            echo "It is required to be installed on the I/NFM \c"
            echo "Server node.\n"
            ;;
        *)
            if [ "$dbasrvans" = "y" -o "$dbasrvans" = "n" ]
            then
                cant_decide=0
            fi

            if [ "$dbasrvans" = "y" ]
            then
                flsans=y
                msgans=y
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
            if [ "$admans" = "y" -o "$admans" = "n" ]
            then
                cant_decide=0
            fi

            if [ "$admans" = "y" ]
            then
                msgans=y
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
            if [ "$flsans" = "y" -o "$flsans" = "n" ]
            then
                cant_decide=0
            fi
		flsans=y
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
#    RIS_Exists=`grep "RIS" /usr/ip32/ingrconfig`
    RIS_Exists=`grep "RIS" $INGRHOME/ingrconfig`
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
#  Load DBA Server (dbasrv)
#

if [ "$dbasrvans" = "y" ]
then
    #Check_Space $UNIXDIR $dbasrvans "DBA/NFM Server Software"
    echo Installing DBA/NFM Server Software
    echo Installing DBA/NFM Serve Software >>$LOGFILE 2>&1
    date >>$LOGFILE 2>&1
    getfile nfmdbasrv.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi
    
    Product_Installed=1

    # Remove old dbasrv entry from /etc/inetd.conf 
    if [ -f /etc/inetd.conf ] 
    then 
        line="" 
        line=`grep -n "dbasrv" /etc/inetd.conf` 
        if [ "$line" != "" ] 
        then 
            sed -e "/^dbasrv/D" /etc/inetd.conf > /usr/tmp/nfm.tmp
            mv /usr/tmp/nfm.tmp /etc/inetd.conf >/dev/null 2>&1 
        fi 
        echo "dbasrv stream tcp nowait root /usr/ip32/nfm/bin/dbasrv dbasrv /usr/tmp/dbasrv.log" >> /etc/inetd.conf 

    fi
fi

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
    Product_Installed=1
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
    Product_Installed=1
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
    Product_Installed=1
fi

#
#  Load Message files
#

if test $Product_Installed -eq 1
then
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
#
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

if [ "$flsans" = "y" ]
then
    RCLOCAL="/etc/rc2.d/S99nfm"
    if [ -f ${RCLOCAL} ]
    then
        server_line=`grep -n "NFMdaemon" /etc/rc2.d/S99nfm | \
           sed s/\ \ /\ /g | \
           cut -f1 -d":"`
        new_line="${UNIXDIR}/bin/NFMdaemon &"
        if [ "$server_line" = "" ]
        then
           echo $new_line >> /etc/rc2.d/S99nfm
        else
           echo "${server_line}c\n$new_line\n.\nw" > /usr/tmp/nfm.tmp
           ed /etc/rc2.d/S99nfm < /usr/tmp/nfm.tmp  >/dev/null 2>&1
           rm /usr/tmp/nfm.tmp
        fi
    fi
fi

if test $Product_Installed -eq 1
then
	getfile nfmdoc.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
fi

#
# Get postinstall.sh
#
    cd ${UNIXDIR}/i_nfmsrv
    getfile postinst.prod | compress -d | cpio -ivmud >>$LOGFILE 2>&1
    AOK=$?
    if [ "$AOK" != "0" ] ; then exit $AOK; fi


#
#  Make root the owner of the product.
#
#  To ensure correct owner and group  - Jujare 28 FEB 1995
find $UNIXDIR -exec chgrp sys {} \; 

find $UNIXDIR -exec chown root {} \;


# newprod for Solaris is not creating /usr/ip32/nfm directory before 
# postinstall.sh is executed. So creating /usr/ip32/nfm directory and
# linking /usr/ip32/nfm/i_nfmsrv to $(UNIXDIR)/i_nfmsrv. SSRS 11 MAR 94.  
if [ ! -d /usr/ip32/nfm ]; then mkdir -p  /usr/ip32/nfm; fi
if [ ! -d /usr/ip32/nfm ]; then echo Cannot create /usr/ip32/nfm; exit 1; fi

# To solve recursive links problem     --Jujare, 28 FEB 1995
#ln -s $UNIXDIR/i_nfmsrv /usr/ip32/nfm/i_nfmsrv
#
num_1=$( ls -Lid $UNIXDIR      | awk '{print $1}')
num_2=$( ls -Lid /usr/ip32/nfm | awk '{print $1}')
if [ "$num_1" -ne "$num_2" ]
then
  ln -s $UNIXDIR/i_nfmsrv /usr/ip32/nfm/i_nfmsrv
fi

##################################################################
#           !!!!!!!!!!!!    FTRRT PATCH !!!!!!!!!!!!!!!!!
#
# Now FTRRT is being supplied as a patch with I/NFM Server
#                                              --  Jujare, 12-APR-95
#
# 
##
## Get FTRRT Patch Only if the User has Chosen so
##
## User has Chosen to Get FTRRT Patch 
## This is a Big 'if' loop ; See Carefully
#
#if [ "$GET_FTR" =  "y" ]
#then
#
#export PATH=$PATH:$INGRHOME/bin
# 
#if (test ! -d $INGRHOME/tmp)
#then
#mkdir -p $INGRHOME/tmp 2>/dev/null
#fi
#chmod 777 $INGRHOME/tmp
# 
# 
#if [ -f $TMPDIR/product.def ]
#then
#  . $TMPDIR/product.def
#else
#  IDname=junk
#  IDnumber=SR05096
#  IDtitle="I/Full Text Retrieval"
#  DELsize=500
#fi
# 
# 
##UNIX_dir=`dirname $4`/ftrrt
#export UNIX_dir=$FTRRT_Dir
# 
# 
# 
##chmod 777 $UNIX_dir
#LOGFILE=$TMPDIR/log
# 
# 
#if [ "$PREPROCESS" != "y" ]
#then
#  INTRO_MESSAGE="Installing ${IDtitle} (version ${IDversion}) in $DESTDIR"
#else
#  INTRO_MESSAGE="Preprocessing ${IDtitle} (version ${IDversion})"
#  rm -f $LOGFILE
#fi
# 
# 
# 
##REMOVEOLD="n"
##oldftr1=`proddata +%p I_FTRRT`
##oldftr2=`proddata +%p $IDname`
##oftrv=`proddata +%v I_FTRRT`
##echo "oldftr1=$oldftr1"
##echo "oldftr2=$oldftr2"
##if [ "$oldftr1" != "" ] ;then
##  ftrfound=y
##else
##  ftrfound=n
##fi
##if [ "$oldftr2" != "" ] ;then
##  if (test  -d $UNIX_dir)
##  then
##    ftrfound=y
##  else
##    ftrfound=n
##  fi
##else
##  ftrfound=n
##fi
# 
# 
#if (test ! -d $UNIX_dir)
#then
#  mkdir -p $UNIX_dir 2>/dev/null
#fi
#if [ "$ftrfound" != "n" ]
#then
#  if [ "$5" = "-y" ]
#  then
#    REMOVEOLD="y"
#  else
#    REMOVEOLD="h"
#    while [ "$REMOVEOLD" = "h" ]
#    do
#      REMOVEOLD=`getanswer -c "" "Remove version $oftrv of I_FTRRT ? (y/n/h)" y`
#      REMOVEOLD=`echo $REMOVEOLD|tr 'YNH' 'ynh'`
#      if [ "$REMOVEOLD" = "h" ]
#      then
#        echo "It is recommended that the currently installed product be removed"
#        echo "before installing version $IDversion of $IDname. Installing a"
#        echo "product on top of another may result in wasted disk space, especia
#lly"
#        echo "if the installation options change."
#      fi
#    done
#  fi
#fi
# 
# 
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
 
# 
# 
#INSTALLHELP="n"
#FTSERVERPATH=""
#FTSERVERUSER=""
# 
# 
#if [ "$PREPROCESS" = "y" ]
#then
#  exit 0
#fi
# 
#
#olddir1=`proddata +%p I_FTRRT`
#olddir2=`proddata +%p $IDname`/../ftrrt
#if [ "$olddir1" != "" ]
#then
#  cd $olddir1/bin;
#
#   cd $FTRRT_Dir/bin
#   ./CLdeconfig.sh
#
#  rc=$?
#  cd -
#  if [ $rc -ne 0 ]
#  then
#    echo "CLdeconfig.sh:$rc:I_FTRCL cannot be successfully DECONFIGURED"
#    exit 1
#  fi
#else
# if [ "$olddir2" != "/../ftrrt" ]
# then
#  cd $olddir2/bin;
#  ./CLdeconfig.sh
#  rc=$?
#  cd -
#  if [ $rc -ne 0 ]
#  then
#    echo "CLdeconfig.sh:$rc:I_FTRCL cannot be successfully DECONFIGURED"
#    exit 1
#  fi
# fi
#fi
# 
#  mkdir -p $UNIX_dir 2>/dev/null
# 
#cd $UNIX_dir
# 
#  getfile client.ps4 | compress -d | cpio -imud 2>>$LOGFILE
#  retstatus=$?
#  if [ $retstatus -ne 0 ]
#  then
#    exit $retstatus
#  fi
# 
## If user selected to update the system files
#if [ $UPDATESYSFILES = y ]
#then
#        # Run configure with appropriate command line options
#        Nflag=
#else
#        Nflag=-n
#fi
# 
#export IDnumber
# 
#(cd bin; ./CLconfig.sh $Nflag $FTSERVERPATH $FTSERVERUSER)
# 
#find . -print | xargs chown root
#find . -print | xargs chgrp sys
#
## NFMserver and BLUbulkload expect libFTR.so and libftft.so.010 to be in 
## /opt/ingr/lib 
## 
#(
#   if [ ! -d $INGRHOME/lib ] ;then mkdir -p $INGRHOME/lib ;fi
#   cd $INGRHOME/lib;
#   if [ -f libFTR.so ]
#   then
#     /bin/rm -rf libFTR.so
#   fi
#   ln -s $UNIX_dir/lib/sun4/libFTR.so . 
#
#   if [ -f libftft.so.010 ]
#   then
#     /bin/rm -rf libftft.so.010
#   fi
#   ln -s $UNIX_dir/lib/sun4/libftft.so.010.1  libftft.so.010
#)
#
#fi
#
#
# End of User has Chosen to Get FTRRT Patch 
#
# End of Code added for FTRRT Patch   - Jujare
###################################################################
   
#exit $retstatus
