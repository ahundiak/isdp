
SRC
$(GRNUC)/src/grio/expreval

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/expreval.a

SOURCE
COexpreval.C   COexprio.C     COexprlib.C    COexprules.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/expreval.o
#else
ARCHIVE
$(GRLIB)/lib/expreval.lib
#endif

SOURCE
COexpreval.C   COexprio.C     COexprlib.C    COexprules.C

#endif
 
SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
