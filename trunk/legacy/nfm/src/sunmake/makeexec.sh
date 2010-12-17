    LIBDIR=../sunlib
    BINDIR=../sunbin
    SCBINDIR=../sunbin
    TARGSTR=
    OBJEXT=6
    RISLIB=/usr/ip32/ris/rispsuc/lib/sun
    RISPCUCLIB=/usr/ip32/ris/rispsuc/lib/sun

Make_execs ()
{ # function to make executables

echo
echo "build sun version ..."
cd ../version
make -f makefile.sun
cd -

echo
echo "build sun NFMdaemon ..."
make -f nfmdmakesun

echo
echo "build sun NFMfileserver ..."
make -f fsmakesun

echo
echo "build sun NFMserver ..."
make -f nfmsmakesun

echo 
echo "build sun Nfmalpha ..."
/bin/rm SC* > /dev/null 2>&1
make -f alphamakesun

echo
echo "build sun Nfmalphas Combine Client/Server..."
/bin/rm SC* > /dev/null 2>&1
make -f alphasmakesun

echo
echo "build sun Nfminit ..."
/bin/rm SC* > /dev/null 2>&1
make -f initmakesun

echo
echo "build sun Nfmfix ..."
make -f nfixmakesun

echo
echo "build sun Nfmfisx ..."
make -f nfisxmakesun

echo
echo "build sun Nfmadmin ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f adminmakesun

echo
echo "build sun Nfmwffx ..."
make -f wffxmakesun

echo
echo "build sun Nfmbulk ..."
/bin/rm SC* > /dev/null 2>&1
make -f bulkmakesun

echo "build sun Util ..."
make -f utilmakesun

echo
echo "build sun CLI ..."
make -f climakesun

echo
echo "build sun Update Utility ..."
/bin/rm SC* > /dev/null 2>&1
make -f updtmakesun

echo
echo "build sun NFMmonitor ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f monitmakesun

}

echo "Make SUN Executables (y/n) ? [n] \c"
read SUNans; : ${SUNans:=n}
SUNans=`echo $SUNans | cut -c1-1`

if [ "$SUNans" = "y" -o "$SUNans" = "Y" ]
  then
    Make_execs
fi
