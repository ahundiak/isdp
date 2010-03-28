
SRC
$(GRNUC)/src/co/poly

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/poly.a

SOURCE
 
COniblock.I    COnirotblk.C   DYnspoly.C     DYtriangle.C
COninspoly.C   DYaddptmod.I   DYorthpoly.I
COnipoly.C     DYblock.I      DYrotblk.C
 
#else

#ifndef NT
LIB
$(GRLIB)/lib/poly.o
#else
ARCHIVE
$(GRLIB)/lib/poly.lib
#endif

SOURCE
 
COniblock.I    COnirotblk.C   DYnspoly.C     DYtriangle.C
COninspoly.C   DYaddptmod.I   DYorthpoly.I
COnipoly.C     DYblock.I      DYrotblk.C
 
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
