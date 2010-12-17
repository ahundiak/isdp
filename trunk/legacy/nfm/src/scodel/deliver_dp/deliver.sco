if (test $# = 0 )
	then
	echo "Need a date stamp argument"
	exit
	fi

touch $1 install.sco product.def remove.sco README ../../scolib/*

find ../../scolib -exec touch $1 {} \;

echo "\nDeliver I/NFM Development Platform"

echo
echo "Send Libraries..."
./del_lib.sco 
echo
echo "Send Requester Libraries..."
./del_req.sco 
echo
echo "Send Server Libraries..."
./del_srv.sco

echo

echo "\nSend Include Files..."
./del_inc.sco
echo
echo "Send Install Script and SCO Libraries..."
./del_ins.sco

