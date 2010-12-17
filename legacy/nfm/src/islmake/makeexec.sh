# 22 Apr 1999 - Art Hundiak
# Changed make to grmake
# Changed $HOME/src to $SRCDIR

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
grmake -f makefile.isl
cd -

echo
echo "build isl SCcpp ..."
cd ../scpp
grmake -f isl.mk
cd -

echo
echo "build isl NFMdaemon ..."
grmake -f nfmdmake.mk

echo
echo "build isl NFMfileserver ..."
grmake -f fsmake.mk

echo
echo "build isl NFMserver ..."
grmake -f nfmsmake.mk

echo 
echo "build isl Nfmalpha ..."
/bin/rm SC* > /dev/null 2>&1
grmake -f alphamake.mk

echo 
echo "build isl Nfmalphas Combine Client/Server..."
/bin/rm SC* > /dev/null 2>&1
grmake -f alphasmake.mk

echo
echo "build isl Nfminit ..."
/bin/rm SC* > /dev/null 2>&1
grmake -f initmake.mk

echo
echo "build isl Nfmfix ..."
grmake -f nfixmake.mk

echo
echo "build isl Nfmfisx ..."
grmake -f nfisxmake.mk

echo
echo "build isl Nfmadmin ..."
/bin/rm SC* > /dev/null 2>&1
grmake $C100_ARGS -f adminmake.mk

echo
echo "build isl Nfmwffx ..."
grmake -f wffxmake.mk

echo
echo "build isl Nfmbulk ..."
/bin/rm SC* > /dev/null 2>&1
grmake -f bulkmake.mk

echo "build isl Util ..."
grmake -f utilmake.mk

echo
echo "build isl CLI ..."
grmake -f climake.mk

echo
echo "build isl Update Utility ..."
/bin/rm SC* > /dev/null 2>&1
grmake -f updtmake.mk

echo
echo "build isl NFMmonitor ..."
/bin/rm SC* > /dev/null 2>&1
grmake $C100_ARGS -f monitmake.mk

echo
echo "Build isl BLUBulkload ..."
if [ ! -d $SRCDIR/BLU/lib ]
then
    mkdir $SRCDIR/BLU/lib
fi
cd $SRCDIR/BLU/utl
grmake -f isl.mk
cd $SRCDIR/BLU/bulkloader
grmake -f isl.mk
cd $SRCDIR/islmake

echo
echo "Build isl dattoclh ..."
cd $SRCDIR/dattoclh
grmake -f isl.mk
cd $SRCDIR/islmake

echo
echo "Build isl Dbasrv ..."
cd $SRCDIR/dbasrv
grmake -f makefile.isl
cd $SRCDIR/dbasrv/dbnuc
grmake -f makefile.isl
cd $SRCDIR/dbasrv/nucleus
grmake -f makefile.isl
cd $SRCDIR/dbasrv/nfm
grmake -f makefile.isl
cd $SRCDIR/dbasrv/stub
grmake -f makefile.isl
cd $SRCDIR/dbasrv
grmake -f combisl.mk

}

#echo "Make Intel Solaris Executables (y/n) ? [n] \c"
#read ISLans; : ${ISLans:=n}
#ISLans=`echo $ISLans | cut -c1-1`

#if [ "$ISLans" = "y" -o "$ISLans" = "Y" ]
#  then
#    Make_execs
#fi

Make_execs












