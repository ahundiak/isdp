C100_ARGS='CFLAGS=-D__cpu_c100__
    LIBDIR=../libc100
    BINDIR=../binc100
    SCBINDIR=../binc100
    TARGSTR=-Atarg=c100
    OBJEXT=1
    XLIB=/usr2/ip32/xformsdp/xfi/lib/c100/
    RISLIB=/usr2/ip32/ris/rispcuc/lib/c100
    RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c100'

# The SCBINDIR=../binc100 is NOT a mistake!
# For our builds, we can only execute a c100 image.

C400_ARGS='CFLAGS=-D__cpu_c400__
    LIBDIR=../libc400
    BINDIR=../binc400
    SCBINDIR=../binc100
    TARGSTR=-Atarg=c400
    OBJEXT=4
    XLIB=/usr2/ip32/xformsdp/xfi/lib/c400/
    RISLIB=/usr2/ip32/ris/rispcuc/lib/c400
    RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c400'

Make_execs ()
{ # function to make executables

echo
echo "build $1 Nfmfisx ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfisxmakefile
    else
        make $C400_ARGS -f nfisxmakefile
fi

}

echo "Make C100 Executables (y/n) ? [n] \c"
read c100ans; : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 Executables (y/n) ? [y] \c"
read c400ans; : ${c400ans:=y}
c400ans=`echo $c400ans | cut -c1-1`

if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
  then
    Make_execs C100
fi

if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
  then
    Make_execs C400
fi

