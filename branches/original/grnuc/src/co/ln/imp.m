
SRC
$(GRNUC)/src/co/ln

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/ln.a

SOURCE

COlnangvw.C    COnilinear.C   DYactangln.C   DYhorverln.C
COnilsacta.C   DYangbs3pt.C   DYlinear.C
COniangbs3.C   COnilsmnds.I   DYangleln.C    DYorthline.I
COnihorln.C    DYconstln.C    DYvertline.C
COniinfln.C    COnivertln.C   DYhorizln.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/ln.o
#else
ARCHIVE
$(GRLIB)/lib/ln.lib
#endif

SOURCE
 
COlnangvw.C    COnilinear.C   DYactangln.C   DYhorverln.C
COnian2bs.I    COnilsacta.C   DYangbs3pt.C   DYlinear.C
COniangbs3.C   COnilsmnds.I   DYangleln.C    DYorthline.I
COnihorln.C    COniperbis.I   DYconstln.C    DYvertline.C
COniinfln.C    COnivertln.C   DYhorizln.C
 
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
