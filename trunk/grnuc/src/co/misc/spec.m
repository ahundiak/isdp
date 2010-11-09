SRC
$(GRNUC)/src/co/misc

#ifdef IDRAW
LIB
$GRMDS/lib/misc_sp.o

SOURCE

COrclpnt.S

#else

#ifndef NT
LIB
$(GRLIB)/lib/misc_sp.o
#else
ARCHIVE
$(GRLIB)/lib/misc_sp.lib
#endif

SOURCE
#if (!(defined SUNOS5) && !(defined IRIX))
COdmv.S
#endif
COgetcmd.S
COrclpnt.S

#endif
 
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(FORMS)/include
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
