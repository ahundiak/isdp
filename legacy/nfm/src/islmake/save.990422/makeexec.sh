    LIBDIR=../tdlib
    BINDIR=../tdbin
    SCBINDIR=../tdbin
    TARGSTR=
    OBJEXT=6
    RISLIB=/opt/ingr/ris/risdp/lib/Soli
    RISPCUCLIB=/opt/ingr/ris/risdp/lib/Soli

Make_execs ()
{ # function to make executables

echo
echo "build isl version ..."
cd ../version
make -f makefile.isl
cd -

echo
echo "build isl SCcpp ..."
cd ../scpp
make -f isl.mk
cd -

echo
echo "build isl NFMdaemon ..."
make -f nfmdmake.mk

echo
echo "build isl NFMfileserver ..."
make -f fsmake.mk

echo
echo "build isl NFMserver ..."
make -f nfmsmake.mk

echo 
echo "build isl Nfmalpha ..."
/bin/rm SC* > /dev/null 2>&1
make -f alphamake.mk

echo 
echo "build isl Nfmalphas Combine Client/Server..."
/bin/rm SC* > /dev/null 2>&1
make -f alphasmake.mk

echo
echo "build isl Nfminit ..."
/bin/rm SC* > /dev/null 2>&1
make -f initmake.mk

echo
echo "build isl Nfmfix ..."
make -f nfixmake.mk

echo
echo "build isl Nfmfisx ..."
make -f nfisxmake.mk

echo
echo "build isl Nfmadmin ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f adminmake.mk

echo
echo "build isl Nfmwffx ..."
make -f wffxmake.mk

echo
echo "build isl Nfmbulk ..."
/bin/rm SC* > /dev/null 2>&1
make -f bulkmake.mk

echo "build isl Util ..."
make -f utilmake.mk

echo
echo "build isl CLI ..."
make -f climake.mk

echo
echo "build isl Update Utility ..."
/bin/rm SC* > /dev/null 2>&1
make -f updtmake.mk

echo
echo "build isl NFMmonitor ..."
/bin/rm SC* > /dev/null 2>&1
make $C100_ARGS -f monitmake.mk

echo
echo "Build isl BLUBulkload ..."
if [ ! -d $HOME/src/BLU/lib ]
then
    mkdir $HOME/src/BLU/lib
fi
cd $HOME/src/BLU/utl
make -f isl.mk
cd ../bulkloader
make -f isl.mk
cd $HOME/src/islmake

echo
echo "Build isl dattoclh ..."
cd $HOME/src/dattoclh
make -f isl.mk
cd $HOME/src/islmake

echo
echo "Build isl Dbasrv ..."
cd $HOME/src/dbasrv
make -f makefile.isl
cd $HOME/src/dbasrv/dbnuc
make -f makefile.isl
cd $HOME/src/dbasrv/nucleus
make -f makefile.isl
cd $HOME/src/dbasrv/nfm
make -f makefile.isl
cd $HOME/src/dbasrv/stub
make -f makefile.isl
cd $HOME/src/dbasrv
make -f combisl.mk

}

echo "Make Intel Solaris Executables (y/n) ? [n] \c"
read ISLans; : ${ISLans:=n}
ISLans=`echo $ISLans | cut -c1-1`

if [ "$ISLans" = "y" -o "$ISLans" = "Y" ]
  then
    Make_execs
fi
