set -k
set -v
if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi


touch $1 install.sh postinstall.sh install.sun product.def README remove.sh     share.sh 
find ../binc100 ../binc400 ../config ../cfg -exec touch $1 {} \;

Deliver ()
{ 
cd ../
ln -s binc$1 bin
cd deliver_ui2

echo
echo "Send Initialize..."
./del_init.sh $1 
echo
echo "Send I/Forms Combined Client/Server Interface..."
./del_fcc.sh $1 
echo
echo "Send I/XForms Combined Client/Server Interface..."
./del_fcx.sh $1 
echo
echo "Send Alphanumeric Combined Client/Server Interface..."
./del_acc.sh $1
echo
echo "Send Workflow Generator..."
./del_wfg.sh $1 
echo
echo "Send dbasrv..."
./del_dbasrv.sh $1 
echo
echo "Send Workflow Generator - X..."
./del_wfx.sh $1 
echo
echo "Send Nfmadmin..."
./del_adm.sh $1 
echo
echo "Send Graphic Client Interface..."
./del_ffi.sh $1 
echo
echo "Send Graphic Client Interface - X..."
./del_ffx.sh $1 
echo
echo "Send Graphic BLUbulkloader Interface..."
./del_fblk.sh $1 
echo
echo "Send Graphic BLUbulkloader Interface - X..."
./del_fblkx.sh $1 
echo
echo "Send Alpha-Numeric Executable..."
./del_alp.sh $1
echo
echo "Send Command Line Executable..."
./del_cli.sh $1 
echo
echo "Send Bulkloader..."
./del_blk.sh $1 
echo
echo "Send Fileserver..."
./del_fls.sh $1 
echo
echo "Send Utilities..."
./del_uti.sh $1 
echo
echo "Send Document Directory..."
./del_doc.sh 
echo
cd ../
rm bin
cd deliver_ui2
}

echo "Deliver C100 Executables (y/n) ? [y] \c"
read c100ans; : ${c100ans:=y}
c100ans=`echo $c100ans | cut -c1-1`

echo "Deliver C400 Executables (y/n) ? [y] \c"
read c400ans; : ${c400ans:=y}
c400ans=`echo $c400ans | cut -c1-1`

if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
  then
    Deliver 100
fi

if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
  then
    Deliver 400
fi

echo "Send Help for Graphic Interface..."
./del_hlp.sh 
echo "Send Help for Graphic BLUbulkloader Interface..."
./del_hlp_BLU.sh 
echo "Send BLUbulkloader Message Files..."
./del_msg_BLU.sh 
echo "Send Message Files..."
./del_msg.sh 
echo "Send Install Script..."
./del_ins.sh 
echo "Send Post-Install Script..."
./del_post.sh 
echo "Send Sun Files..."
