    LIBDIR=../sollib
    BINDIR=../solbin
    SCBINDIR=../solbin
    TARGSTR=
    OBJEXT=6
    RISLIB=/usr/ip32/ris/rispsuc/lib/Sol2
    RISPCUCLIB=/usr/ip32/ris/rispsuc/lib/Sol2

Make_execs ()
{ # function to make executables

echo
echo "build sol version ..."
cd ../version
make -f makefile.sol
cd -

echo
echo "build sol NFMdaemon ..."
make -f nfmdmakesol

echo
echo "build sol NFMfileserver ..."
make -f fsmakesol

echo
echo "build sol NFMserver ..."
make -f nfmsmakesol

echo 
echo "build sol Nfmalpha ..."
/bin/rm SC* > /dev/null 2>&1
make -f alphmakesol

echo 
echo "build sol Nfmalphas Combine Client/Server..."
/bin/rm SC* > /dev/null 2>&1
make -f alphasmakesol

echo
echo "build sol Nfminit ..."
/bin/rm SC* > /dev/null 2>&1
make -f initmakesol

echo
echo "build sol Nfmfix ..."
make -f nfixmakesol

echo
echo "build sol Nfmfisx ..."
make -f nfisxmakesol

echo
echo "build solk Nfmadmin ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f adminmakesol

echo
echo "build sol Nfmwffx ..."
make -f wffxmakesol

echo
echo "build sol Nfmbulk ..."
/bin/rm SC* > /dev/null 2>&1
make -f bulkmakesol

echo "build sol Util ..."
make -f utilmakesol

echo
echo "build sol CLI ..."
make -f climakesol

echo
echo "build sol Update Utility ..."
/bin/rm SC* > /dev/null 2>&1
make -f updmakesol

echo
echo "build sol NFMmonitor ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f monmakesol

}

echo "Make SSL Executables (y/n) ? [n] \c"
read SSLans; : ${SSLans:=n}
SSLans=`echo $SSLans | cut -c1-1`

if [ "$SSLans" = "y" -o "$SSLans" = "Y" ]
  then
    Make_execs
fi
