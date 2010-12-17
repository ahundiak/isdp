C100_MARGS='CPUFLAG=-D__cpu_c100__
  OBJEXT=1
  LIBDIR=../libc100
  BINDIR=../binc100
  TARGSTR=-Atarg=c100'

C400_MARGS='CPUFLAG=-D__cpu_c400__
  OBJEXT=4
  LIBDIR=../libc400
  BINDIR=../binc400
  TARGSTR=-Atarg=c400'

C100_ARGS='CFLAGS=-D__cpu_c100__
    LIBDIR=../libc100
    BINDIR=../binc100
    SCBINDIR=../binc100
    TARGSTR=-Atarg=c100
    OBJEXT=1
    RISLIB=/usr2/ip32/ris/rispcuc/lib/c100
    RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c100'

C400_ARGS='CFLAGS=-D__cpu_c400__
    LIBDIR=../libc400
    BINDIR=../binc400
    SCBINDIR=../binc100
    TARGSTR=-Atarg=c400
    OBJEXT=4
    RISLIB=/usr2/ip32/ris/rispcuc/lib/c400
    RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c400'

Make_execs ()
{ # function to make executables

cd ../pc_server

echo
echo "make $1 pc_server ..."

if [ "$1" = "C100" ]
    then
        make $C100_MARGS -f makefile
    else
        make $C400_MARGS -f makefile
fi

cd ../make

echo
echo "build $1 PCserver ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f pcmakefile
    else
        make $C400_ARGS -f pcmakefile
fi

}

echo "Make C100 PC Server (y/n) ? [n] \c"
read c100ans; : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 PC Server (y/n) ? [y] \c"
read c400ans; : ${c400ans:=y}
c400ans=`echo $c400ans | cut -c1-1`

echo
echo "Run 'fstopc' (y/n) ? [n] \c"
read fsans; : ${fsans:=n}
fsans=`echo $fsans | cut -c1-1`
if [ "$fsans" = "y" -o "$fsans" = "Y" ]
  then
    cd ../pc_server
    echo "fstopc ..."
    fstopc
    cd ../make
fi

if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
  then
    Make_execs C100
fi

if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
  then
    Make_execs C400
fi
