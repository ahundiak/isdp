if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

/usr/5bin/touch $1 install.sh postinstall.sh product.def README remove.sh share.sh
find ../../bin ../../config -exec touch $1 {} \;

Deliver ()
{ 
echo
echo "Send Initialize..."
./del_init.sh
echo
echo "Send Server..."
./del_srv.sh
echo
echo "Send Nfmadmin..."
./del_adm.sh
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
#cd ../
#rm bin
#cd deliver_srv
}


Deliver

echo "Send Message Files..."
./del_msg.sh
echo "Send Install Script..."
./del_ins.sh
echo "Send Post-Install Script..."
./del_post.sh

