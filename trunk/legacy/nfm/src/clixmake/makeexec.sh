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
echo "build $1 version ..."
cd ../version
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi
cd -

echo
echo "build $1 NFMdaemon ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfmdmakefile
    else
        make $C400_ARGS -f nfmdmakefile
fi

echo
echo "build $1 NFMfileserver ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f fsmakefile
    else
        make $C400_ARGS -f fsmakefile
fi

echo
echo "build $1 NFMserver ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f nfmsmakefile
    else
        make $C400_ARGS -f nfmsmakefile
fi

echo 
echo "build $1 Nfmalpha ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f alphmakefile
    else
        make $C400_ARGS -f alphmakefile
fi

echo 
echo "build $1 Nfmalphas Combine Client/Server..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f alsmakefile
    else
        make $C400_ARGS -f alsmakefile
fi

echo
echo "build $1 Nfminit ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f initmakefile
    else
        make $C400_ARGS -f initmakefile
fi

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


echo
echo "build $1 Nfmadmin ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f adminmakefile
    else
        make $C400_ARGS -f adminmakefile
fi

echo
echo "build $1 Nfmwff ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f wffmakefile
    else
        make $C400_ARGS -f wffmakefile
fi

echo
echo "build $1 Nfmwffx ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f wffxmakefile
    else
        make $C400_ARGS -f wffxmakefile
fi

echo
echo "build $1 Nfmbulk ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f bulkmakefile
    else
        make $C400_ARGS -f bulkmakefile
fi

echo
echo "build $1 NFMV_Server ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f v_nfmsmakefile
    else
        make $C400_ARGS -f v_nfmsmakefile
fi

echo
echo "build $1 PC_Server ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f pcmakefile
    else
        make $C400_ARGS -f pcmakefile
fi

echo
echo "build $1 Util ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f utilmakefile
    else
        make $C400_ARGS -f utilmakefile
fi

echo
echo "build $1 CLI ..."
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f climakefile
    else
        make $C400_ARGS -f climakefile
fi

echo
echo "build $1 Converter ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f cvtmakefile
    else
        make $C400_ARGS -f cvtmakefile
fi

echo
echo "build $1 Update Utility ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f updmakefile
    else
        make $C400_ARGS -f updmakefile
fi

echo
echo "build $1 Redline Utility ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f rdlmakefile
    else
        make $C400_ARGS -f rdlmakefile
fi

echo
echo "build $1 NFMmonitor ..."
rm SC* > /dev/null 2>&1
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f monmakefile
    else
        make $C400_ARGS -f monmakefile
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

