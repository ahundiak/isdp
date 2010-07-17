SOURCE
VSsomeObjcVw.S
VSwnconstrct.I
VSwndisbyoid.I
VSwnfitgadgt.I
VSwngetobjct.I
VSwngnupdate.I
VSwnnotfylis.I
VSwnsetobjct.I

LIB
$STRUCT/lib/vswindow.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$STRUCT/spec

INCLUDE
$EXNUC/include
$BS/include
$GRNUC/include
$MODEL/include
$STRUCT/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


/*
 * "CLIX" : -D switch for operating system
 * "ENV5" : -D switch for windowing system
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
