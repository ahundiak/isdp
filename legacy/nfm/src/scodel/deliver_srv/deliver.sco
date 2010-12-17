if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

touch $1 install.sco postinstal.sco product.def README remove.sco 
find ../../bin ../../config -exec touch $1 {} \;

Deliver ()
{ 
echo
echo "Send Initialize..."
./del_init.sco
echo
echo "Send Server..."
./del_srv.sco
echo
# echo "Send PC Server..."
# ./del_pcs.sco
echo
echo "Send DBA Server..."
./del_dbasrv.sco
echo
echo "Send Nfmadmin..."
./del_adm.sco
echo
echo "Send Fileserver..."
./del_fls.sco
echo
echo "Send Utilities..."
./del_uti.sco
echo
echo "Send Document Directory..."
./del_doc.sco
echo
}

    Deliver 

echo "Send Message Files..."
./del_msg.sco
echo "Send Install Script..."
./del_ins.sco
echo "Send Post-Install Script..."
./del_post.sco

