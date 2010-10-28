COPT
-DBASE_EMS

SOURCE
OMTparent.C

EXEC
testx

LINKLIB
-lcurses
-lsocket
-lnsl
$EXNUC/lib/exnuc.o
$EXNUC/lib/OMmetas.o

SPEC
$EXNUC/spec
$EXNUC/om/spec

INCLUDE
$EXNUC/include
$EXNUC/om/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
