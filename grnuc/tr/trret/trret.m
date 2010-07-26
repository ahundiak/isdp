CC
$(COMPILER)

COPT
$(COMPOPT)

SPEC
$(EXNUC)/spec
$(EXNUC)/exec/spec
$(GRNUC)/go/spec

INCLUDE
$(XFORMSDP)/xfi/include
$(INGRHOME)/include
$(XINC)
#ifdef XGL
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
$(TRANSLATE)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include

OPP
$(EXTARG)/bin/opp $(TR_OPPOPT)

OMCPP
$(EXTARG)/bin/omcpp $(TR_OMCPPOPT)

LIB
$(GRLIB)/lib/trret.o

SOURCE
TRlib.c
TRret.S
TRretimp.I
ret_func.I
