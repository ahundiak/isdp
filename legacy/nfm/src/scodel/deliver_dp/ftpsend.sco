nodename=$1
username=$2
passwd=$3
location=$4

(
    echo "verbose"
    echo "open $nodename"
    echo "user $username $passwd"
    echo "binary"
    echo "cd $location"
    echo "send nfminc.prod"
    echo "send remove.sco"
    echo "send install.sco"
    echo "send README"
    echo "send product.def"
    echo "send nfmlib.prod"
    echo "send nfmreq.prod"
    echo "send nfmsrv.prod"
    echo "quit"
) > /usr/tmp/ftp.in
ftp -i -n < /usr/tmp/ftp.in >/dev/null
