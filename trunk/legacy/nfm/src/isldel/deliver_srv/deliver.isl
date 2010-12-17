
touch $1 install.isl postinstall.sh product.def README remove.isl share.isl
find ../../bin ../../config -exec touch $1 {} \;

Deliver ()
{ 
echo
echo "Send Initialize..."
./del_init.isl
echo "Send Initialize..." >> log

echo
echo "Send Server..."
./del_srv.isl
echo "Send Server..." >> log

echo
echo "Send Nfmadmin..."
./del_adm.isl
echo "Send Nfmadmin..." >> log

echo
echo "Send Fileserver..."
./del_fls.isl
echo "Send Fileserver..." >> log


echo
echo "Send DBAserver..."
./del_dbasrv.isl
echo "Send DBAserver..." >> log

echo
echo "Send Utilities..."
./del_uti.isl
echo "Send Utilities..." >> log

echo
echo "Send Document Directory..."
./del_doc.isl
echo "Send Document Directory..." >> log

echo
#cd ../
#rm bin
#cd deliver_srv
}

echo >> log
echo >> log
echo `date` >> log
Deliver

echo "Send Message Files..."
./del_msg.isl
echo "Send Message Files..." >> log

echo "Send Install Script..."
./del_ins.isl
echo "Send Install Script..." >> log

echo "Send Post-Install Script..."
./del_post.isl
echo "Send Post-Install Script..." >> log

