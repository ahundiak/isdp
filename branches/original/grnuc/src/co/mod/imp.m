
SRC
$(GRNUC)/src/co/mod

#ifdef  IDRAW
ARCHIVE
$GRMDS/lib/mod.a

SOURCE

COnidelv.I     COnimovseg.I   DYbadmod.I
COniex1in.I    COniinsert.I   COnipardel.I   DYfixed.I
COniex2in.I    COnisplit.I    DYprojln.I
COniextend.I   COnimodele.I   DY2ptmod.I     DYvertex.C
DYextend.I

#else

#ifndef NT
LIB
$(GRLIB)/lib/mod.o
#else
ARCHIVE
$(GRLIB)/lib/mod.lib
#endif

SOURCE

COnidelv.I     COnifrag.I     COnimovseg.I   DYbadmod.I
COniex1in.I    COniinsert.I   COnipardel.I   DYfixed.I
COniex2in.I    COnimodax.I    COnisplit.I    DYprojln.I
COniextend.I   COnimodele.I   DY2ptmod.I     DYvertex.C
DYextend.I

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
