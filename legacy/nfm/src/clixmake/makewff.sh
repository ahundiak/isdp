C100_ARGS='CFLAGS=-D__cpu_c100__
    LIBDIR=../libc100
    BINDIR=../binc100
    SCBINDIR=../binc100
    TARGSTR=-Atarg=c100
    OBJEXT=1
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
    RISLIB=/usr2/ip32/ris/rispcuc/lib/c400
    RISPCUCLIB=/usr2/ip32/ris/rispcuc/lib/c400'

Make_execs ()
{ # function to make executables

echo "build $1 Nfmwff ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f wffmakefile
    else
        make $C400_ARGS -f wffmakefile
fi

echo
echo "build $1 Nfmwff_x ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f wffxmakefile
    else
        make $C400_ARGS -f wffxmakefile
fi

}

echo "Make C100 Workflow Interfaces (y/n) ? [n] \c"
read c100ans; : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 Workflow Interfaces (y/n) ? [y] \c"
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

