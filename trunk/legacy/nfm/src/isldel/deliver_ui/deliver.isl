#if (test $# = 0)
#        then
#        echo "Need a date stamp argument"
#        exit
#        fi

touch $1 install.isl postinstall.sh install.isl product.def README remove.sh remove.isl share.sh nfmfls.isl
find ../../bin ../../config ../../cfg -exec touch $1 {} \;

Deliver ()
{ 
cd ../..
cd isldel/deliver_ui

echo
echo "Send Initialize..."
./del_init.isl isl
echo
echo "Send I/XForms Combined Client/Server Interface..."
./del_fcx.isl isl
echo
echo "Send Alphanumeric Combined Client/Server Interface..."
./del_acc.isl isl 
echo
echo "Send Workflow Generator - X..."
./del_wfx.isl isl
echo
echo "Send Nfmadmin..."
./del_adm.isl isl
echo
echo "Send Graphic Client Interface - X..."
./del_ffx.isl isl
echo
echo "Send Alpha-Numeric Executable..."
./del_alp.isl isl
echo
echo "Send Command Line Interface..."
./del_cli.isl isl
echo
echo "Send Bulkloader..."
./del_blk.isl isl
echo
echo
echo "Send BLU Bulkloader..."
./del_fblk.isl isl
echo
echo "Send Fileserver..."
./del_fls.isl isl
echo
echo "Send Utilities..."
./del_uti.isl isl
echo
echo "Send Document Directory..."
./del_doc.isl isl
echo
cd ../
cd deliver_ui
}

Deliver

echo "Send Help for Graphic Interface..."
./del_hlp.isl isl
echo "Send Message Files..."
./del_msg.isl isl
echo "Send Install Script..."
./del_ins.isl isl
echo "Send Post-Install Script..."
./del_post.isl isl
