INCLUDE
$(INGRHOME)/include
#ifdef X11
$(XINC)
#endif
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
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

COPT
-ga

CC
acc -knr -O3

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

SRC
$(GRNUC)/src/co/adpco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/adpco.o
#else
$(GRLIB)/lib/adpco.lib
#endif

#else


ARCHIVE
$GRMDS/lib/adpco.a

#endif

SOURCE
COsetadpi.I
GRadpconstr.I
GRadpintrcpt.C
GRadpwakeup.I
GRchgadplnwt.C
GRclrtblchg.I
GRcreadp.C
GRcresetadp.C
GRdpsetadp.C
GRdynclrpal.C
GRprocadp.C
GRprocsetadp.C
GRupdadpform.C
GRupdadpgad.C
GRupdalladpf.C
GRupdclrform.C
GRupdsetadp.C
GRupdwtform.C

