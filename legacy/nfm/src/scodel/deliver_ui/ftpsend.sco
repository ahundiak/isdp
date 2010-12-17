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
    echo "send product.def"
    echo "send remove.sco"
    echo "send README"
    echo "send share.sco"
    echo "send install.sco"
    echo "send nfmmsg.prod"
    echo "send nfmhlp.prod"
    echo "send nfmdoc.prod"
    echo "send nfmuti.prod"
    echo "send nfmfls.prod"
    echo "send nfmblk.prod"
    echo "send nfmcli.prod"
    echo "send nfmalp.prod"
    echo "send nfmffx.prod"
    echo "send nfmadm.prod"
    echo "send nfmwfx.prod"
    echo "send nfmacc.prod"
    echo "send nfmfcx.prod"
    echo "send nfmini.prod"
    echo "quit"
) > /usr/tmp/ftp.in
ftp -i -n < /usr/tmp/ftp.in >/dev/null
