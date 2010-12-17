    LIBDIR=../scolib
    BINDIR=../scobin
    SCBINDIR=../scobin
    TARGSTR=
    OBJEXT=5
    RISLIB=/usr/ip32/ris/risdp/lib
    RISDPLIB=/usr/ip32/ris/risdp/lib

Make_execs ()
{ # function to make executables

echo
echo "build sco version ..."
cd ../version
make -f makefile.sco
cd -

echo
echo "build sco NFMdaemon ..."
make -f nfmdmakesco

echo
echo "build sco NFMfileserver ..."
make -f fsmakesco

echo
echo "build sco NFMserver ..."
make -f nfmsmakesco

echo 
echo "build sco Nfmalpha ..."
/bin/rm SC* > /dev/null 2>&1
make -f alphamakesco

echo 
echo "build sco Nfmalphas Combine Client/Server..."
/bin/rm SC* > /dev/null 2>&1
make -f alphasmakesco

echo
echo "build sco Nfminit ..."
/bin/rm SC* > /dev/null 2>&1
make -f initmakesco

echo
echo "build sco Nfmfix ..."
make -f nfixmakesco

echo
echo "build sco Nfmfisx ..."
make -f nfisxmakesco

echo
echo "build scok Nfmadmin ..."
/bin/rm SC* > /dev/null 2>&1
make -f adminmakesco

echo
echo "build sco Nfmwffx ..."
make -f wffxmakesco

echo
echo "build sco Nfmbulk ..."
/bin/rm SC* > /dev/null 2>&1
make -f bulkmakesco

echo "build sco Util ..."
make -f utilmakesco

echo
echo "build sco CLI ..."
make -f climakesco

echo
echo "build sco Update Utility ..."
/bin/rm SC* > /dev/null 2>&1
make -f updtmakesco

echo
echo "build sco NFMmonitor ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f monitmakesco

}

echo "Make SCO Executables (y/n) ? [n] \c"
read SCOans; : ${SCOans:=n}
SCOans=`echo $SCOans | cut -c1-1`

if [ "$SCOans" = "y" -o "$SCOans" = "Y" ]
  then
    Make_execs
fi
