C100_ARGS='CPUFLAG=-D__cpu_c100__
  OBJEXT=1
  LIBDIR=../libc100
  BINDIR=../libc100
  TARGSTR=-Atarg=c100'

C400_ARGS='CPUFLAG=-D__cpu_c400__
  OBJEXT=4
  LIBDIR=../libc400
  BINDIR=../libc400
  TARGSTR=-Atarg=c400'

Make_libraries ()
{ # function to make libraries

echo
echo "make $1 libmem ..."
cd ../libmem
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libnet ..."
cd ../libnet
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 libsql ..."
cd ../libsql
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

echo
echo "make $1 liberr ..."
cd ../liberr
if [ "$1" = "C100" ]
    then
        make $C100_ARGS -f makefile
    else
        make $C400_ARGS -f makefile
fi

}

echo "Make C100 Libraries (y/n) ? [n] \c"
read c100ans; : ${c100ans:=n}
c100ans=`echo $c100ans | cut -c1-1`

echo "Make C400 Libraries (y/n) ? [y] \c"
read c400ans; : ${c400ans:=y}
c400ans=`echo $c400ans | cut -c1-1`

if [ "$c100ans" = "y" -o "$c100ans" = "Y" ]
  then
    Make_libraries C100
fi

if [ "$c400ans" = "y" -o "$c400ans" = "Y" ]
  then
    Make_libraries C400
fi
