# NFM Server

if (test $# = 0)
        then
        echo "Need a CPU argument (100 or 400)"
        exit
        fi

echo "find ..."
cd ..
find \
/etc/rc2.d/S99nfm \
/etc/nfmd.conf \
bin/NFMserver \
bin/NFMV_Server \
bin/convert.sh \
bin/convert.bat \
bin/view_sol.txt \
-print | cpio -ov | compress > nfmsrv.p$1
rcp -p nfmsrv.p$1  nfmcert@moorer:/usr2/nfmcert/clix/i_nfmui/nfmsrv.p$1

echo
