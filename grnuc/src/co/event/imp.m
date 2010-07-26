
SRC
$(GRNUC)/src/co/event

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/event.a

SOURCE
COabscoord.C   COdeltawld.C   COptalong.I
COdeltavw.C    COdistdir.C    COptbt2pt.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/event.o
#else
ARCHIVE
$(GRLIB)/lib/event.lib
#endif

SOURCE
COabscoord.C   COdeltawld.C   COptalong.I
COdeltavw.C    COdistdir.C    COptbt2pt.C
GRMtxPtNot.I   GRPolPtNot.I   COptsalsp.I
COgeneqspt.I   COgenmxpts.C   COpolarpts.C

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
