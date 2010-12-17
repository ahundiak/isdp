# Fileserver and Daemon

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
/etc/nfmd.conf \
/etc/rc2.d/S99nfm \
bin/NFMfileserver \
bin/NFMdaemon \
bin/Nfmtcpip.sh \
bin/NFMdmdftr.sh \
bin/clhtodat \
-print | cpio -ov | compress > nfmfls.p$1
rcp -p nfmfls.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmfls.p$1

echo 


