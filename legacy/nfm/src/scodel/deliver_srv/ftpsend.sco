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
    echo "send postinst.prod"
    echo "send nfmmsg.prod"
    echo "send remove.sco"
    echo "send share.sco"
    echo "send install.sco"
    echo "send README"
    echo "send product.def"
    echo "send nfmdoc.prod"
    echo "send nfmuti.prod"
    echo "send nfmfls.prod"
    echo "send nfmadm.prod"
    echo "send nfmpcs.prod"
    echo "send nfmsrv.prod"
    echo "send nfmini.prod"
    echo "quit"
) > /usr/tmp/ftp.in
ftp -i -n < /usr/tmp/ftp.in >/dev/null
