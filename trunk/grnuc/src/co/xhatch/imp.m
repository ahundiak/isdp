
SRC
$(GRNUC)/src/co/xhatch

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/xhatch.a

SOURCE
 
COniplxhat.I   GRxhgen.I      GRxhgginfo.I   GRxhputdef.I
GRxhaddbdy.I   GRxhgetdef.I   GRxhinit.I     GRxhrembdy.I
GRxhcomp.I     GRxhgetgg.I    GRxhmisc.I     GRxhupdef.I
GRxhcosmpy.C   GRxhggdel.I    GRxhnotify.I   GRnester.I
GRgenxhatch.I  GRxhanalyze.I
 
#else

#ifndef NT
LIB
$(GRLIB)/lib/xhatch.o
#else
ARCHIVE
$(GRLIB)/lib/xhatch.lib
#endif

SOURCE

COniplxhat.I   GRxhgen.I      GRxhgginfo.I   GRxhputdef.I
GRxhaddbdy.I   GRxhgetdef.I   GRxhinit.I     GRxhrembdy.I
GRxhcomp.I     GRxhgetgg.I    GRxhmisc.I     GRxhupdef.I
GRxhcosmpy.C   GRxhggdel.I    GRxhnotify.I   GRnester.I
GRgenxhatch.I  GRxhanalyze.I
 
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
acc -knr

