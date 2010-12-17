if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

/usr/5bin/touch $1 install.sh product.def remove.sh README ../../sunlib/*

echo "\nDeliver I/NFM Development Platform"

echo "Send Libraries..."
./del_lib.sh
echo
echo "Send Requester Libraries..."
./del_req.sh
echo
echo "Send Server Libraries..."
./del_srv.sh
echo

echo "\nSend Include Files..."
./del_inc.sh
echo
echo "Send Install Script "
./del_ins.sh
