#if (test $# = 0)
#        then
#        echo "Need a date stamp argument"
#        exit
#        fi

touch $1 install.isl product.def remove.isl README ../../lib/*

find ../../lib -exec touch $1 {} \;
	
echo "\nDeliver I/NFM Development Platform"

echo "Send Libraries..."
./del_lib.isl
echo
echo "Send Requester Libraries..."
./del_req.isl
echo
echo "Send Server Libraries..."
./del_srv.isl
echo

echo "\nSend Include Files..."
./del_inc.isl
echo
echo "Send Install Script "
./del_ins.isl
