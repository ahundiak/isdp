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

# The SCBINDIR=../binc100 (below) is NOT a mistake!
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

echo
echo "make $1 nfmfi ..."
cd ../nfmfi
if [ "$1" = "C100" ]
    then
        make $C100_MARGS -f makefile
    else
        make $C400_MARGS -f makefile
fi

echo
echo "make $1 nfmfis ..."
cd ../nfmfis
if [ "$1" = "C100" ]
    then
        make $C100_MARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
    else
        make $C400_MARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE
fi

echo
echo "make $1 nfmfi_x ..."
cd ../nfmfi_x
if [ "$1" = "C100" ]
    then
        make $C100_MARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
    else
        make $C400_MARGS -f makefile XWINDOWS_FLAG=-DXWINDOWS
fi

echo
echo "make $1 nfmfis_x ..."
cd ../nfmfis_x
if [ "$1" = "C100" ]
    then
        make $C100_MARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
    else
        make $C400_MARGS -f makefile COMBINE_FLAG=-DCOMBINED_MAKE XWINDOWS_FLAG=-DXWINDOWS
fi

cd ../make

echo
echo "build $1 Nfmfi ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfimakefile
    else
        make $C400_ARGS -f nfimakefile
fi

echo
echo "build $1 Nfmfis ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfismakefile
    else
        make $C400_ARGS -f nfismakefile
fi

echo
echo "build $1 Nfmfix ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfixmakefile
    else
        make $C400_ARGS -f nfixmakefile
fi

echo
echo "build $1 Nfmfisx ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfisxmakefile
    else
        make $C400_ARGS -f nfisxmakefile
fi

}

echo "Make C100 Nfmfi Executables (y/n) ? [n] \c"
read c100ans; : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 Nfmfi Executables (y/n) ? [y] \c"
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

