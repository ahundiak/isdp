#
#	INTERGRAPH/VAX Delivery Procedures
#
	PRODUCT_ID=SN01383
	PRODUCT_FL=REMOVE
#
# The information in this document is subject to change without
# notice and should not be construed as a commitment by INTERGRAPH
# corporation.
#

echo "$PRODUCT_FL -- $PRODUCT_ID\n"
if [ -z "$IDname" ]
then
        echo ""
        echo ""
        echo "Please use the remove program in the deltools directory"
        echo "to remove this product (i.e. /usr/ip32/deltools/remove)"
        echo "The remove.sh in each directory was intended to be called"
        echo "from the remove program in the deltools directory."
        echo ""
        echo ""
        exit 255
fi

#
# Display information about the product.
#


NFDATA=`grep $PRODUCT_ID /usr/ip32/ingrconfig`
NFNAME=`echo $NFDATA | cut -f2 -d"#"`
NFVER=`echo $NFDATA | cut -f4 -d"#"`
NFDATE=`echo $NFDATA | cut -f5 -d"#"`
NFDIR=`echo $NFDATA | cut -f6 -d"#"`
nfmsrv=`grep SN01382 /usr/ip32/ingrconfig`

echo "\nThis is the product $NFNAME, $PRODUCT_ID, \c"
echo "the Intergraph Network File Manager,"
echo "Version $NFVER, dated $NFDATE.\n"

ffians=n
ffxans=n
fblkans=n
fblkansx=n
alpans=n
clians=n
wfgans=n
wfxans=n
admans=n
blkans=n
flsans=n

#
# Prompt for confirmation on parts of the product.
#

if [ -f /usr/ip32/nfm/bin/Nfmfi ] 
then
echo "Remove the $IDname I/Forms Interface (y/n) ? [y] \c"
read ffians; : ${ffians:=y}
fi

if [ -f /usr/ip32/nfm/bin/Nfmfix ] 
then
echo "Remove the $IDname I/XForms Interface (y/n) ? [y] \c"
read ffxans; : ${ffxans:=y}
fi

if [ -f /usr/ip32/nfm/bin/DataEntry.exe ] 
then
echo "Remove the $IDname I/Forms BLUbulkloader Interface (y/n) ? [y] \c"
read fblkans; : ${fblkans:=y}
fi
if [ -f /usr/ip32/nfm/bin/DataEntryx.exe ] 
then
echo "Remove the $IDname I/XForms BLUbulkload Interface (y/n) ? [y] \c"
read fblkxans; : ${fblkxans:=y}
fi

if [ -f /usr/ip32/nfm/bin/Nfmalpha ] 
then
echo "Remove the $IDname Alphanumeric Interface (y/n) ? [y] \c"
read alpans; : ${alpans:=y}
fi

if [ -f /usr/ip32/nfm/bin/Nfmcli ] 
then
echo "Remove the $IDname Command Line Interface (y/n) ? [y] \c"
read clians; : ${clians:=y}
fi

if [ -f /usr/ip32/nfm/bin/Nfmwff ] 
then
echo "Remove the $IDname I/Forms Workflow Interface (y/n) ? [y] \c"
read wfgans; : ${wfgans:=y}
fi

if [ -f /usr/ip32/nfm/bin/Nfmwffx ] 
then
echo "Remove the $IDname I/XForms Workflow Interface (y/n) ? [y] \c"
read wfxans; : ${wfxans:=y}
fi

# only ask to remove Nfmadmin if I_NFMSRV does not exist

if [ "$nfmsrv" = "" ]
then
   if [ -f /usr/ip32/nfm/bin/Nfmadmin ] 
   then
      echo "Remove the $IDname Administrator Utility (y/n) ? [y] \c"
      read admans; : ${admans:=y}
   fi
fi

if [ -f /usr/ip32/nfm/bin/Nfmbulk ] 
then
echo "Remove the $IDname Bulk Load Utility (y/n) ? [y] \c"
read blkans; : ${blkans:=y}
fi

# only ask to remove NFMfileserver if I_NFMSRV does not exist

if [ "$nfmsrv" = "" ]
then
   if [ -f /usr/ip32/nfm/bin/NFMfileserver ] 
   then
      echo "Remove the $IDname File Server Software (y/n) ? [y] \c"
      read flsans; : ${flsans:=y}
   fi
fi

#
# Do the removing...
#

case $ffians in
y*|Y*)
    ffians="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/Forms Interface"
    rm -r ../bin/Nfmfi                                 >/dev/null 2>&1
    ;;
*)
    ;;
esac


case $ffxans in
y*|Y*)
    ffxans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/XForms Interface"
    rm -r ../bin/Nfmfix                                >/dev/null 2>&1
    ;;
*)
    ;;
esac


case $fblkans in
y*|Y*)
    fblkans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/Forms BLUbulkloader Interface"
    rm -r ../bin/DataEntry.exe                                >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $fblkxans in
y*|Y*)
    fblkxans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/XForms BLUbulkloader Interface"
    rm -r ../bin/DataEntryx.exe                                >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $alpans in
y*|Y*)
    alpans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) Alphanumeric Interface"
    rm -r ../bin/Nfmalpha                              >/dev/null 2>&1
    rm -r ../config/english/commands/user.dat          >/dev/null 2>&1
    rm -r ../config/english/commands/admin.dat         >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $clians in
y*|Y*)
    clians="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) Command Line Interface"
    rm -r ../bin/Nfmcli                                >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $wfgans in
y*|Y*)
    wfgans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/Forms Workflow Interface"
    rm -r  ../bin/Nfmwff                              >/dev/null 2>&1
    rm -r ../config/english/menus/workflow            >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $wfxans in
y*|Y*)
    wfxans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) I/XForms Workflow Interface"
    rm -r  ../bin/Nfmwffx                             >/dev/null 2>&1
    rm -r ../config/english/menus/workflow            >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $admans in
y*|Y*)
    admans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) Administrator Utility"
    rm -r ../bin/Nfmadmin                            >/dev/null 2>&1
    rm -r ../config/english/commands/env.dat         >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $blkans in
y*|Y*)
    blkans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) Bulk Load Utility"
    rm -r ../bin/Nfmbulk                             >/dev/null 2>&1
    rm -r ../bin/BLUbulkload                         >/dev/null 2>&1
    rm -r ../bin/BLUconfig                           >/dev/null 2>&1
    rm -r ../bin/BLUdataentry                        >/dev/null 2>&1
    rm -r ../config/english/commands/bulk.dat        >/dev/null 2>&1
    ;;
*)
    ;;
esac

case $flsans in
y*|Y*)
    flsans="Y"
    echo "\nRemoving $PRODUCT_ID (I/NFM) File Server Software"
#
#  Stop the I/NFM Daemon and remove files
#
    if [ -f /etc/init.d/nfm ] 
    then
        /etc/init.d/nfm stop_nfm; 
        unlink /etc/init.d/nfm; 
        rm -r /etc/rc2.d/S99nfm                    >/dev/null 2>&1
        rm -r /etc/nfmd.conf                       >/dev/null 2>&1
    fi

    rm -r ../bin/NFMfileserver                        >/dev/null 2>&1
    rm -r ../bin/NFMdaemon                            >/dev/null 2>&1
    rm -r ../bin/Nfmutil                              >/dev/null 2>&1
    rm -r ../bin/VAXutil                              >/dev/null 2>&1
    rm -r ../bin/NFMV_Server                          >/dev/null 2>&1
    rm -r ../bin/get_util.com                         >/dev/null 2>&1
    ;;
*)
    ;;
esac

if [ "$ffians"="Y" -a "$ffxans"="Y" ]
then
    rm -r ../config/english/menus/admin                >/dev/null 2>&1
    rm -r ../config/english/menus/user                 >/dev/null 2>&1
fi

if [ "$ffians"="Y" -a "$ffxans"="Y" -a "$wfgans"="Y" -a "$wfxans"="Y" ]
then
   rm -r ../config/english/icons                      >/dev/null 2>&1
   rm -r ../config/english/forms                      >/dev/null 2>&1
fi

# get file partition
fp=`echo $2 | cut -f2 -d"/"`
deldir=/$fp/ip32/nfm

echo "\n$PRODUCT_FL -- $PRODUCT_ID operation complete.\n"

if [ "$nfmsrv" = "" ]
then
   if [ -d $deldir ] 
   then
       echo "\nWarning: The $deldir directory still exists on this machine."
       echo "Do you wish to remove the $deldir product directory? [y] \c"
       read delans; : ${delans:=y}
       if [ "$delans"="Y" -o "$delans"="y" ]
       then
          cd /usr/tmp
          echo "Removing $deldir ...\n"
          rm -r $deldir                      >/dev/null 2>&1
          if [ -L /usr/ip32/nfm ]
          then
             echo "Removing symbolic link to /usr/ip32/nfm ..."
             rm -fr /usr/ip32/nfm >/dev/null 2>&1
          fi
       fi
   fi
else
   echo "\nI_NFMSRV exists on this machine.\n"
fi

exit 0

