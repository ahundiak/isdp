set -x
cd $HOME/ems/libxc/src
export INC_PVT=../inc.pvt
export INC_PUB=../include
export BIN=../bin
export LIB=../lib
export TARGET=../target
export LSRC=.
export SRC=.
export DOPT1="-DRUN_X -DX11 -DLITTLE_ENDIAN -DSYSV -DSYS5 -DSVR4 -DSUNOS -DSUNOS5 -DSUNOS58 -Di386 -D__i386 -DINTEL -DUNIX -DSunOS_5x -D__i386__ -DSunOS"
export CC="cc -xO1 -Xc -xCC -W0,-xd -KPIC"
export COPT=-g
grmakemake libxc.m mkfile
grmake -r -k -f mkfile
cc -c namecache.c  $COMPOPT -I$INC_PUB
cc -c XCinit_x86.s $COMPOPT
cd $HOME/ems/libxc/lib
cp ../src/namecache.o  .
cp ../src/XCinit_x86.o .
ar rv libxc.a XCinit_x86.o namecache.o
ar xv libxc.a
ar rv libxc_init.a XCinit_x86.o
ld -z text -G -o libxc.so [a-z]*.o
cp -p libxc_init.a /opt/ingr/lib
cp -p libxc.so     /opt/ingr/lib
cd $HOME/ems/libxc/test
export TEST=.
make
