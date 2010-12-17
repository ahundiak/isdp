if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

/usr/5bin/touch $1 install.sh postinstall.sh install.sun product.def README remove.sh remove.sun share.sh nfmfls.sun
find ../../bin ../../config ../../cfg -exec touch $1 {} \;

Deliver ()
{ 
cd ../../
cd sundel/deliver_ui

echo
echo "Send Initialize..."
./del_init.sh
echo
echo "Send Alphanumeric Combined Client/Server Interface..."
./del_acc.sh
echo
echo "Send I/XForms Combined Client/Server Interface..."
./del_fcx.sh
echo
echo "Send Workflow Generator - X..."
./del_wfx.sh
echo
echo "Send Nfmadmin..."
./del_adm.sh
echo
echo "Send Graphic Client Interface - X..."
./del_ffx.sh
echo
echo "Send Alpha-Numeric Executable..."
./del_alp.sh
echo
echo "Send Bulkloader..."
./del_blk.sh
echo
echo "Send Fileserver..."
./del_fls.sh
echo
echo "Send Utilities..."
./del_uti.sh
echo
echo "Send Document Directory..."
./del_doc.sh
echo
cd ../
cd deliver_ui
}

Deliver

echo "Send Help for Graphic Interface..."
./del_hlp.sh
echo "Send Message Files..."
./del_msg.sh
echo "Send Install Script..."
./del_ins.sh
echo "Send Post-Install Script..."
./del_post.sh
