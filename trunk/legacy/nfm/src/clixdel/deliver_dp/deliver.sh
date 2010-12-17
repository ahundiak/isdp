if (test $# = 0)
        then
        echo "Need a date stamp argument"
        exit
        fi

touch $1 install.sh product.def remove.sh README sunlib/*

#find ../libc100 ../libc400 -exec touch $1 {} \;

echo "\nDeliver I/NFM Development Platform"

echo "\nC100:"
echo
echo "Send Libraries..."
./del_lib.sh 100
echo
echo "Send Requester Libraries..."
./del_req.sh 100
echo
echo "Send Server Libraries..."
./del_srv.sh 100

echo "\nC400:"
echo
echo "Send Libraries..."
./del_lib.sh 400
echo
echo "Send Requester Libraries..."
./del_req.sh 400
echo
echo "Send Server Libraries..."
./del_srv.sh 400
echo

echo "\nSend Include Files..."
./del_inc.sh
echo
echo "Send Install Script and SUN Libraries..."
./del_ins.sh

