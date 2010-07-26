
cd $MODEL

find ./src* -name '*.S' -exec ln {} spec \;
find ./ve -name '*.S' -exec ln {} spec \;
find ./hsurf -name '*.S' -exec ln {} spec \;

cd $MODEL/config/english/messages/src
necho "\n------------------ config/english/messages/src ---------------------\n"
make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
 then
  make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
  errchk /tmp/bldlog
fi

necho "\n------------------ src_co/slic ---------------------\n"
cd $MODEL/src_co/slic
make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
 then
  make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
  errchk /tmp/bldlog
fi

necho "\n------------------ src_testco/slic ---------------------\n"
cd $MODEL/src_testco/slic
make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
ncat /tmp/bldlog
if [ "$ERRNOTI" = "on" ]
 then
  make -rk CC="$COMPILER" COPT="$COMPOPT" DOPT="$MKDOPT" > /tmp/bldlog 2>&1
  errchk /tmp/bldlog
fi

necho $MAKEFILE

necho "- - - - - - - Running checkspec_all.- - - - - - - "
checkspec_all. > /tmp/bldlog 2>&1
ncat /tmp/bldlog

