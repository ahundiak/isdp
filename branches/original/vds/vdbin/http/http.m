
SOURCE
main.C

EXEC
$VDS/bin/http

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
$VDS/vdxml/VDhttp.o

INCLUDE
$SPX/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

