if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

touch $1 install.sh postinstall.sh product.def README remove.sh share.sh
find ../binc100 ../binc400 ../config -exec touch $1 {} \;

Deliver ()
{ 
cd ../
ln -s binc$1 bin
cd deliver_srv2

echo
echo "Send Initialize..."
./del_init.sh $1
echo
echo "Send Server..."
./del_srv.sh $1
echo
echo "Send PC Server..."
./del_pcs.sh $1
echo
echo "Send DBA  Server (dbasrv) ..."
./del_dbasrv.sh $1
echo
echo "Send Nfmadmin..."
./del_adm.sh $1
echo
echo "Send Converter..."
./del_cvt.sh $1
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
cd deliver_srv2
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

echo "Send Message Files..."
./del_msg.sh
echo "Send Install Script..."
./del_ins.sh
echo "Send Post-Install Script..."
./del_post.sh

