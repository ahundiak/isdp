SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/ingrsys
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

LIB
$(GRLIB)/lib/dpvd_sp.o

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/co/dvd

SOURCE
DPvd.S
DPvd_mv.S
DPvd_rdwn.S
DPvd_rv.S
DPvd_tdl.S
DPdsp_tol.S

CC
acc -knr -O3

