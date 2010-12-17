# Fileserver and Daemon

#if (test $# = 0)
#        then
#        echo "Need a CPU argument (100 or 400)"
#        exit
#        fi

echo "find ..."
cd ../../
find \
/etc/rc2.d/S99nfm \
/etc/nfmd.conf \
bin/NFMfileserver \
bin/NFMdaemon \
bin/dattoclh \
risutil  \
-print | cpio -ov | compress > nfmfls.prod
rcp -p nfmfls.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmui
rm nfmfls.prod
echo 


