if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

touch $1 install.sco postinstal.sco product.def README remove.sco share.sco 
find ../../bin ../../config -exec touch $1 {} \;

Deliver ()
{ 
cd ../../
cd scodel/deliver_ui

echo
echo "Send Initialize..."
./del_init.sco sco 
echo
echo "Send I/XForms Combined Client/Server Interface..."
./del_fcx.sco sco
echo
echo "Send Alphanumeric Combined Client/Server Interface..."
./del_acc.sco sco
echo
echo "Send Workflow Generator - X..."
./del_wfx.sco sco
echo
echo "Send Nfmadmin..."
./del_adm.sco sco
echo
echo "Send Graphic Client Interface - X..."
./del_ffx.sco sco
echo
echo "Send Alpha-Numeric Executable..."
./del_alp.sco sco
echo
echo "Send Command Line Interface..."
./del_cli.sco sco
echo "Send Bulkloader..."
./del_blk.sco sco
echo
echo "Send Fileserver..."
./del_fls.sco sco
echo
echo "Send DBASRV..."
./del_dbasrv.sco sco
echo
echo "Send Utilities..."
./del_uti.sco sco
echo
echo "Send Document Directory..."
./del_doc.sco
echo
cd ../
cd deliver_ui
}

Deliver

echo "Send Message Files..."
./del_msg.sco
echo "Send Help for Graphic Interface...."
./del_hlp.sco
echo "Send Install Script..."
./del_ins.sco
echo "Send Post-Install Script..."
./del_post.sco
